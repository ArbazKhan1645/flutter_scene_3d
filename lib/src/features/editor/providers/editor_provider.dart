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

import 'package:file_picker/file_picker.dart';
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

  Uint8List? _pendingModelBytes;
  String? _pendingModelName;

  // ── JS bridge (JS → Flutter) ───────────────────────────────────────────────

  void _onBridgeMessage(JavaScriptMessage msg) {
    try {
      final map  = jsonDecode(msg.message) as Map<String, dynamic>;
      final type = map['type'] as String? ?? '';
      final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? {};

      switch (type) {
        case 'editorReady':
          state = state.copyWith(isEditorReady: true, isLoading: false);
          if (_pendingModelBytes != null && _pendingModelName != null) {
            final bytes = _pendingModelBytes!;
            final name = _pendingModelName!;
            _pendingModelBytes = null;
            _pendingModelName = null;
            _sendBase64Chunked(bytes, name);
          }
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

        case 'loadProgress':
          final pct = (data['progress'] as num?)?.toInt() ?? 0;
          final name = data['name'] as String? ?? 'Model';
          state = state.copyWith(
            loadProgress: pct,
            statusMessage: pct < 100 ? 'Loading $name ($pct%)…' : '$name loaded ✓',
            isLoading: pct < 100,
          );
          if (pct >= 100) _autoHideStatus();
          break;

        case 'screenshotReady':
          final b64 = data['base64'] as String? ?? '';
          _saveAndShareScreenshot(b64);
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

  // ── Scene Controls & Utils ────────────────────────────────────────────────
  Future<void> setBackgroundColor(String hex) {
    state = state.copyWith(bgColor: hex);
    return _run("Editor.setBackground('$hex')");
  }

  Future<void> toggleShadows() {
    final next = !state.shadowsEnabled;
    state = state.copyWith(shadowsEnabled: next);
    return _run('Editor.setShadowsEnabled($next)');
  }

  Future<void> takeScreenshot() {
    state = state.copyWith(isLoading: true, statusMessage: 'Capturing screenshot…');
    return _run('Editor.takeScreenshot()');
  }

  Future<void> _saveAndShareScreenshot(String base64Str) async {
    try {
      final bytes = base64Decode(base64Str);
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/screenshot_${DateUtils.dateOnly(DateTime.now()).millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], subject: '3D Scene Screenshot'),
      );
      state = state.copyWith(isLoading: false, statusMessage: 'Screenshot shared ✓');
    } catch (e) {
      debugPrint('[EditorScreenshot] $e');
      state = state.copyWith(isLoading: false, statusMessage: '⚠ Screenshot failed');
    }
    _autoHideStatus();
  }

  // ── Asset & Custom Model loading ───────────────────────────────────────────

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

  Future<void> _queueOrLoadModel(Uint8List bytes, String name) async {
    if (!state.isEditorReady || _controller == null) {
      debugPrint('[EditorProvider] Editor not ready yet, queuing model: $name');
      _pendingModelBytes = bytes;
      _pendingModelName = name;
    } else {
      await _sendBase64Chunked(bytes, name);
    }
  }

  /// Loads a GLB from Flutter's asset bundle into the Three.js scene (universal Web + Mobile).
  Future<void> loadAssetModelIntoScene(String assetPath) async {
    state = state.copyWith(isLoading: true, statusMessage: 'Loading model…');
    try {
      final name = assetPath.split('/').last.replaceAll('.glb', '').replaceAll('.gltf', '');
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      await _queueOrLoadModel(bytes, name);
      state = state.copyWith(isLoading: false, statusMessage: '$name added ✓');
      _autoHideStatus();
    } catch (e) {
      debugPrint('[EditorAssets] load error: $e');
      state = state.copyWith(isLoading: false, statusMessage: '⚠ Load failed');
      _autoHideStatus();
    }
  }

  /// Pick a custom GLB/GLTF model from device storage and import into the 3D scene.
  Future<void> importCustomModelFromDevice() async {
    state = state.copyWith(isImporting: true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb', 'gltf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final name = file.name.replaceAll('.glb', '').replaceAll('.gltf', '');
        state = state.copyWith(isLoading: true, statusMessage: 'Importing $name…');

        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }

        if (bytes != null) {
          await _queueOrLoadModel(bytes, name);
        }
        state = state.copyWith(isLoading: false, isImporting: false, statusMessage: '$name imported ✓');
        _autoHideStatus();
      } else {
        state = state.copyWith(isImporting: false);
      }
    } catch (e) {
      debugPrint('[CustomImport] $e');
      state = state.copyWith(isImporting: false, statusMessage: '⚠ Import failed');
      _autoHideStatus();
    }
  }

  /// Load a custom .glb / .gltf file from local file path into the 3D editor.
  Future<void> loadCustomModelFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final name = filePath.split('/').last.split(Platform.pathSeparator).last.replaceAll('.glb', '').replaceAll('.gltf', '');
        state = state.copyWith(isLoading: true, statusMessage: 'Loading $name…');
        await _queueOrLoadModel(bytes, name);
        state = state.copyWith(isLoading: false, statusMessage: '$name loaded ✓');
        _autoHideStatus();
      }
    } catch (e) {
      debugPrint('[LoadCustomFile] $e');
      state = state.copyWith(isLoading: false, statusMessage: '⚠ Load failed');
      _autoHideStatus();
    }
  }

  /// Send Base64 in safe 300KB chunks to prevent JS IPC / string length crashes.
  Future<void> _sendBase64Chunked(Uint8List bytes, String name) async {
    final b64 = base64Encode(bytes);
    const chunkSize = 300000;
    await _run('Editor.clearModelChunks()');

    for (var i = 0; i < b64.length; i += chunkSize) {
      final end = (i + chunkSize < b64.length) ? i + chunkSize : b64.length;
      final chunk = b64.substring(i, end);
      final pct = ((end / b64.length) * 100).toInt();
      state = state.copyWith(statusMessage: 'Sending $name ($pct%)…');
      await _run("Editor.appendModelChunk('$chunk')");
    }

    await _run("Editor.finishChunkedModel('$name', '{}')");
  }

  // ── 3D MESH MODIFIERS & MODELING SUITE ────────────────────────────────────

  Future<void> bendSelected(String axis, double angleDeg) {
    if (state.selectedObjectId == null) return Future.value();
    return _run("Editor.bendObject('${state.selectedObjectId}', '$axis', $angleDeg)");
  }

  Future<void> twistSelected(double angleDeg) {
    if (state.selectedObjectId == null) return Future.value();
    return _run("Editor.twistObject('${state.selectedObjectId}', $angleDeg)");
  }

  Future<void> taperSelected(double topScale) {
    if (state.selectedObjectId == null) return Future.value();
    return _run("Editor.taperObject('${state.selectedObjectId}', $topScale)");
  }

  Future<void> mirrorSelected(String axis) {
    if (state.selectedObjectId == null) return Future.value();
    return _run("Editor.mirrorObject('${state.selectedObjectId}', '$axis')");
  }

  Future<void> alignSelectedToGround() {
    if (state.selectedObjectId == null) return Future.value();
    return _run("Editor.alignToGround('${state.selectedObjectId}')");
  }

  Future<void> setMaterialPreset(String preset) {
    if (state.selectedObjectId == null) return Future.value();
    return _run("Editor.setMaterialPreset('${state.selectedObjectId}', '$preset')");
  }

  Future<void> setEnvironmentPreset(String preset) {
    return _run("Editor.setEnvironmentPreset('$preset')");
  }

  Future<void> booleanSubtract(String targetId, String cutterId) {
    return _run("Editor.booleanSubtract('$targetId', '$cutterId')");
  }

  Future<void> groupObjects(List<String> ids) {
    final jsonIds = jsonEncode(ids);
    return _run("Editor.groupObjects($jsonIds)");
  }

  Future<void> ungroupObject(String groupId) {
    return _run("Editor.ungroupObject('$groupId')");
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
