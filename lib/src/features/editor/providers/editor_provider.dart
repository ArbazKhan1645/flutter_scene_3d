/// Riverpod [Notifier] that drives the offline 3-D Scene Editor.
///
/// Every public method on this class maps 1-to-1 with a window.Editor.*
/// call in the Three.js editor (assets/web/js/editor.js).
///
/// Flutter → JS  :  _run('Editor.method(args)')
/// JS → Flutter  :  JavascriptChannel 'FlutterBridge' → _onBridgeMessage
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/editor_state.dart';
import '../models/scene_object.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

/// Global provider for the scene editor.
final editorProvider = NotifierProvider<EditorNotifier, EditorState>(
  EditorNotifier.new,
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class EditorNotifier extends Notifier<EditorState> {
  WebViewController? _controller;

  // ── Build ──────────────────────────────────────────────────────
  @override
  EditorState build() {
    _discoverAssetModels();
    return const EditorState();
  }

  // ── WebView wiring ─────────────────────────────────────────────────────────

  /// Call this once when the [WebViewWidget]'s controller is ready.
  void setWebViewController(WebViewController controller) {
    _controller = controller;
  }

  /// Builds and returns a fully configured [WebViewController] that hosts
  /// the Three.js scene editor served from Flutter assets.
  WebViewController buildEditorController() {
    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF16162a))
      ..addJavaScriptChannel(
          'FlutterBridge', onMessageReceived: _onBridgeMessage)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (e) =>
            debugPrint('[EditorWebView] error: ${e.description}'),
      ))
      ..loadFlutterAsset('assets/web/index.html');

    _controller = ctrl;
    return ctrl;
  }

  // ── JS bridge (JS → Flutter) ───────────────────────────────────────────────

  void _onBridgeMessage(JavaScriptMessage msg) {
    try {
      final map  = jsonDecode(msg.message) as Map<String, dynamic>;
      final type = map['type'] as String? ?? '';
      final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? {};

      switch (type) {
        case 'editorReady':
          state = state.copyWith(isEditorReady: true, isLoading: false);
          break;

        case 'sceneUpdated':
          final scene = SceneData.fromMap(data);
          // Refresh selected meta if still present
          SceneObjectMeta? sel;
          if (state.selectedObjectId != null) {
            try {
              sel = scene.objects
                  .firstWhere((o) => o.id == state.selectedObjectId);
            } catch (_) {}
          }
          state = state.copyWith(
            sceneObjects   : scene.objects,
            sceneLights    : scene.lights,
            selectedObject : sel,
          );
          break;

        case 'objectSelected':
          final metaMap = (data['meta'] as Map?)?.cast<String, dynamic>() ?? data;
          final tMap    = (data['transform'] as Map?)?.cast<String, dynamic>();
          var meta      = SceneObjectMeta.fromMap(metaMap);
          if (tMap != null) meta = meta.copyWith(transform: SceneTransform.fromMap(tMap));
          state = state.copyWith(
            selectedObjectId: meta.id,
            selectedObject  : meta,
            activePanel     : 'properties',
          );
          break;

        case 'objectDeselected':
          state = state.copyWith(clearSelected: true);
          break;

        case 'objectDeleted':
          if (data['id'] == state.selectedObjectId) {
            state = state.copyWith(clearSelected: true);
          }
          break;

        case 'objectTransformChanged':
          final tMap = (data['transform'] as Map?)?.cast<String, dynamic>();
          if (tMap != null && state.selectedObject != null) {
            state = state.copyWith(
              selectedObject: state.selectedObject!.copyWith(
                transform: SceneTransform.fromMap(tMap),
              ),
            );
          }
          break;

        case 'sceneSaved':
          final json = data['json'] as String? ?? '';
          state = state.copyWith(
            savedSceneJson: json,
            statusMessage : 'Scene saved ✓',
          );
          _autoHideStatus();
          break;

        case 'sceneLoaded':
          state = state.copyWith(
            isLoading     : false,
            statusMessage : 'Scene loaded ✓',
          );
          _autoHideStatus();
          break;

        case 'sceneCleared':
          state = state.copyWith(
            sceneObjects    : [],
            clearSelected   : true,
            statusMessage   : 'Scene cleared',
          );
          _autoHideStatus();
          break;

        case 'exportComplete':
          final b64    = data['base64'] as String? ?? '';
          final format = data['format'] as String? ?? 'glb';
          _saveAndShareExport(b64, format);
          break;

        case 'transformModeChanged':
          final mode = data['mode'] as String? ?? 'translate';
          state = state.copyWith(transformMode: mode);
          break;

        case 'cameraTypeChanged':
          final t = data['type'] as String? ?? 'perspective';
          state = state.copyWith(cameraType: t);
          break;

        case 'error':
          debugPrint('[EditorJS] ${data['message']}');
          state = state.copyWith(
            isLoading    : false,
            statusMessage: '⚠ ${data['message']}',
          );
          _autoHideStatus();
          break;

        default:
          debugPrint('[EditorBridge] unknown type: $type');
      }
    } catch (e) {
      debugPrint('[EditorBridge] parse error: $e  raw: ${msg.message}');
    }
  }

  // ── Primitives ─────────────────────────────────────────────────────────────

  Future<void> createCube()     => _run("Editor.createCube('{}')");
  Future<void> createSphere()   => _run("Editor.createSphere('{}')");
  Future<void> createPlane()    => _run("Editor.createPlane('{}')");
  Future<void> createCylinder() => _run("Editor.createCylinder('{}')");
  Future<void> createCone()     => _run("Editor.createCone('{}')");
  Future<void> createTorus()    => _run("Editor.createTorus('{}')");
  Future<void> createCapsule()  => _run("Editor.createCapsule('{}')");

  // ── Object management ──────────────────────────────────────────────────────

  Future<void> selectObject(String id)        => _run("Editor.selectObject('$id')");
  Future<void> deselectObject()               => _run('Editor.deselectObject()');
  Future<void> deleteObject(String id)        => _run("Editor.deleteObject('$id')");
  Future<void> duplicateObject(String id)     => _run("Editor.duplicateObject('$id')");
  Future<void> focusObject(String id)         => _run("Editor.focusObject('$id')");
  Future<void> clearScene()                   => _run('Editor.clearScene()');

  Future<void> renameObject(String id, String name) {
    final safeName = name.replaceAll("'", r"\'");
    return _run("Editor.renameObject('$id', '$safeName')");
  }

  Future<void> toggleObjectVisibility(String id, bool visible) {
    return _run("Editor.setObjectVisible('$id', $visible)");
  }

  // ── Transform ──────────────────────────────────────────────────────────────

  Future<void> setTransformMode(String mode) {
    state = state.copyWith(transformMode: mode);
    return _run("Editor.setTransformMode('$mode')");
  }

  Future<void> toggleSnap() {
    final next = !state.isSnapEnabled;
    state = state.copyWith(isSnapEnabled: next);
    return _run('Editor.setSnap($next)');
  }

  // ── Material ───────────────────────────────────────────────────────────────

  Future<void> setObjectColorHex(String id, String hex) {
    return _run("Editor.setObjectColorHex('$id', '$hex')");
  }

  Future<void> setObjectMetalness(String id, double v) {
    return _run('Editor.setObjectMetalness("$id", $v)');
  }

  Future<void> setObjectRoughness(String id, double v) {
    return _run('Editor.setObjectRoughness("$id", $v)');
  }

  Future<void> setObjectOpacity(String id, double v) {
    return _run('Editor.setObjectOpacity("$id", $v)');
  }

  Future<void> setObjectWireframe(String id, bool enabled) {
    return _run('Editor.setObjectWireframe("$id", $enabled)');
  }

  // ── Lights ─────────────────────────────────────────────────────────────────

  Future<void> addAmbientLight()     => _run("Editor.addAmbientLight('{}')");
  Future<void> addDirectionalLight() => _run("Editor.addDirectionalLight('{}')");
  Future<void> addPointLight()       => _run("Editor.addPointLight('{}')");
  Future<void> addSpotLight()        => _run("Editor.addSpotLight('{}')");
  Future<void> addHemisphereLight()  => _run("Editor.addHemisphereLight('{}')");
  Future<void> deleteLight(String id)=> _run("Editor.deleteLight('$id')");

  Future<void> setLightIntensity(String id, double v) {
    return _run("Editor.setLightIntensity('$id', $v)");
  }

  Future<void> setLightColor(String id, String hex) {
    return _run("Editor.setLightColor('$id', '$hex')");
  }

  // ── Camera ─────────────────────────────────────────────────────────────────

  Future<void> resetCamera()    => _run('Editor.resetCamera()');
  Future<void> fitScene()       => _run('Editor.fitScene()');
  Future<void> focusSelected()  => _run('Editor.focusSelected()');

  Future<void> setCameraType(String type) {
    state = state.copyWith(cameraType: type);
    return _run("Editor.setCameraType('$type')");
  }

  // ── Grid & helpers ─────────────────────────────────────────────────────────

  Future<void> toggleGrid() {
    final next = !state.isGridVisible;
    state = state.copyWith(isGridVisible: next);
    return _run('Editor.setGridVisible($next)');
  }

  Future<void> toggleAxes() {
    final next = !state.isAxesVisible;
    state = state.copyWith(isAxesVisible: next);
    return _run('Editor.setAxesVisible($next)');
  }

  // ── Scene persistence ──────────────────────────────────────────────────────

  Future<void> saveScene()            => _run('Editor.saveScene()');

  Future<void> loadSceneFromJson(String json) {
    state = state.copyWith(isLoading: true);
    final escaped = json.replaceAll('\\', '\\\\').replaceAll('`', r'\`');
    return _run('Editor.loadScene(`$escaped`)');
  }

  Future<void> reloadSavedScene() {
    if (state.savedSceneJson == null) return Future.value();
    return loadSceneFromJson(state.savedSceneJson!);
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> exportGLB() {
    state = state.copyWith(isLoading: true, statusMessage: 'Exporting GLB…');
    return _run('Editor.exportGLB()');
  }

  Future<void> _saveAndShareExport(String base64, String format) async {
    try {
      final bytes  = base64Decode(base64);
      final dir    = await getTemporaryDirectory();
      final path   = '${dir.path}/scene_export.${format.toLowerCase()}';
      await File(path).writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], subject: '3D Scene Export'),
      );
      state = state.copyWith(
        isLoading    : false,
        statusMessage: 'Export ready ✓',
      );
    } catch (e) {
      debugPrint('[EditorExport] $e');
      state = state.copyWith(isLoading: false, statusMessage: '⚠ Export failed');
    }
    _autoHideStatus();
  }

  // ── Asset model loading ────────────────────────────────────────────────────

  Future<void> _discoverAssetModels() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final models   = manifest
          .listAssets()
          .where((k) => k.startsWith('assets/models/') &&
              (k.endsWith('.glb') || k.endsWith('.gltf')))
          .toList();
      state = state.copyWith(assetModels: models);
    } catch (e) {
      debugPrint('[EditorAssets] $e');
    }
  }

  /// Loads a GLB from Flutter's asset bundle into the Three.js scene.
  Future<void> loadAssetModelIntoScene(String assetPath) async {
    if (_controller == null) return;
    state = state.copyWith(isLoading: true, statusMessage: 'Loading model…');
    try {
      final data   = await rootBundle.load(assetPath);
      final bytes  = data.buffer.asUint8List();
      final b64    = base64Encode(bytes);
      final name   = assetPath.split('/').last.replaceAll('.glb', '').replaceAll('.gltf', '');
      await _run("Editor.loadModelFromBase64('$b64', '$name', '{}')");
      state = state.copyWith(isLoading: false, statusMessage: '$name added ✓');
      _autoHideStatus();
    } catch (e) {
      debugPrint('[EditorAssets] load error: $e');
      state = state.copyWith(isLoading: false, statusMessage: '⚠ Load failed');
      _autoHideStatus();
    }
  }

  // ── Panel navigation ───────────────────────────────────────────────────────

  void setActivePanel(String panel) =>
      state = state.copyWith(activePanel: panel);

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _run(String js) async {
    if (_controller == null) return;
    try {
      await _controller!.runJavaScript(js);
    } catch (e) {
      debugPrint('[EditorRun] $e  js: $js');
    }
  }

  Timer? _statusTimer;
  void _autoHideStatus() {
    _statusTimer?.cancel();
    _statusTimer = Timer(const Duration(seconds: 3), () {
      state = state.copyWith(clearStatus: true);
    });
  }
}
