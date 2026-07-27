import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/viewer_state.dart';

part 'viewer_provider.g.dart';

@riverpod
class ViewerNotifier extends _$ViewerNotifier {
  WebViewController? _webViewController;

  @override
  ViewerState build() {
    loadAssetModels();
    return const ViewerState();
  }

  // ── WebView initialization ────────────────────────────────────────────────
  void setWebViewController(WebViewController controller) {
    _webViewController = controller;
  }

  // ── Asset model discovery ─────────────────────────────────────────────────
  Future<void> loadAssetModels() async {
    try {
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> models = manifest
          .listAssets()
          .where((k) => k.startsWith('assets/models/') && k.endsWith('.glb'))
          .toList();
      state = state.copyWith(
        assetModels: models.isNotEmpty ? models : ['assets/models/Motorcycle.glb'],
      );
    } catch (e) {
      debugPrint('Error loading asset models: $e');
      state = state.copyWith(assetModels: ['assets/models/Motorcycle.glb']);
    }
  }

  // ── Model selection ───────────────────────────────────────────────────────
  void selectModel(String path, bool isAsset) {
    state = state.copyWith(
      selectedModelPath: path,
      isAssetModel: isAsset,
      isModelLoaded: false,
      isLoading: true,
      loadingProgress: 0.0,
      selectedColor: Colors.transparent,
      hasCustomTexture: false,
      uploadedTexturePath: '',
      modelMaterials: ['All Materials'],
      modelTextures: [],
      modelAnimations: [],
      selectedMaterial: 'All Materials',
      selectedAnimation: '',
      isAnimationPlaying: false,
    );
  }

  void loadModelFromFile(String filePath) {
    selectModel(filePath, false);
  }

  Future<void> pickModelFromDevice() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb', 'gltf'],
      );
      if (result != null && result.files.single.path != null) {
        selectModel(result.files.single.path!, false);
      }
    } catch (e) {
      debugPrint('Error picking model: $e');
    }
  }

  // ── WebView callbacks ─────────────────────────────────────────────────────
  void onModelLoaded() {
    state = state.copyWith(isModelLoaded: true, isLoading: false);
    fetchModelMaterials();
    fetchModelTextures();
    fetchModelAnimations();
    _applyShadow();
    _applyExposure();
    _applyToneMapper();
    _applyCamera();
  }

  void onLoadingProgress(double progress) {
    state = state.copyWith(
      loadingProgress: progress,
      isLoading: progress < 1.0,
    );
  }

  // ── Material, Texture, Animation Fetching ────────────────────────────────
  Future<void> fetchModelMaterials() async {
    if (_webViewController == null) return;
    const js = '''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv || !mv.model) return;
        const names = mv.model.materials.map(m => m.name || 'Unnamed Material');
        MaterialChannel.postMessage(JSON.stringify(names));
      })();
    ''';
    await _webViewController!.runJavaScript(js);
  }

  void updateMaterialList(String jsonList) {
    try {
      final List<dynamic> names = json.decode(jsonList);
      state = state.copyWith(
        modelMaterials: ['All Materials', ...names.cast<String>()],
      );
    } catch (e) {
      debugPrint('Error parsing materials: $e');
    }
  }

  Future<void> fetchModelTextures() async {
    if (_webViewController == null) return;
    const js = r'''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv || !mv.model) return;
        const textures = [];
        mv.model.materials.forEach((mat, mi) => {
          const pbr = mat.pbrMetallicRoughness;
          const slots = [
            { slot: 'baseColor',     tex: pbr.baseColorTexture?.texture },
            { slot: 'metallicRoughness', tex: pbr.metallicRoughnessTexture?.texture },
            { slot: 'normal',        tex: mat.normalTexture?.texture },
            { slot: 'occlusion',     tex: mat.occlusionTexture?.texture },
            { slot: 'emissive',      tex: mat.emissiveTexture?.texture },
          ];
          slots.forEach(s => {
            if (s.tex) {
              textures.push({
                material: mat.name || ('Material ' + mi),
                slot: s.slot,
                name: s.tex.name || s.slot,
                sampler: s.tex.sampler ? JSON.stringify({
                  wrapS: s.tex.sampler.wrapS,
                  wrapT: s.tex.sampler.wrapT,
                  minFilter: s.tex.sampler.minFilter,
                  magFilter: s.tex.sampler.magFilter,
                }) : '{}'
              });
            }
          });
        });
        TextureListChannel.postMessage(JSON.stringify(textures));
      })();
    ''';
    await _webViewController!.runJavaScript(js);
  }

  void updateTextureList(String jsonList) {
    try {
      final List<dynamic> list = json.decode(jsonList);
      state = state.copyWith(modelTextures: list.cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('Error parsing textures: $e');
    }
  }

  Future<void> fetchModelAnimations() async {
    if (_webViewController == null) return;
    const js = '''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv) return;
        const anims = mv.availableAnimations || [];
        AnimationChannel.postMessage(JSON.stringify(anims));
      })();
    ''';
    await _webViewController!.runJavaScript(js);
  }

  void updateAnimationList(String jsonList) {
    try {
      final List<dynamic> anims = json.decode(jsonList);
      state = state.copyWith(modelAnimations: anims.cast<String>());
    } catch (e) {
      debugPrint('Error parsing animations: $e');
    }
  }

  // ── Controls ─────────────────────────────────────────────────────────────
  Future<void> playAnimation(String name) async {
    if (_webViewController == null) return;
    state = state.copyWith(selectedAnimation: name, isAnimationPlaying: true);
    final js = '''
      (function() {
        const mv = document.querySelector('model-viewer');
        mv.animationName = '$name';
        mv.play();
      })();
    ''';
    await _webViewController!.runJavaScript(js);
  }

  Future<void> pauseAnimation() async {
    if (_webViewController == null) return;
    state = state.copyWith(isAnimationPlaying: false);
    await _webViewController!.runJavaScript("document.querySelector('model-viewer').pause();");
  }

  Future<void> stopAnimation() async {
    if (_webViewController == null) return;
    state = state.copyWith(isAnimationPlaying: false, selectedAnimation: '');
    await _webViewController!.runJavaScript(
      "document.querySelector('model-viewer').pause(); document.querySelector('model-viewer').currentTime = 0;",
    );
  }

  Future<void> toggleShadow(bool value) async {
    state = state.copyWith(shadowEnabled: value);
    await _applyShadow();
  }

  Future<void> updateShadowIntensity(double value) async {
    state = state.copyWith(shadowIntensity: value);
    await _applyShadow();
  }

  Future<void> updateShadowSoftness(double value) async {
    state = state.copyWith(shadowSoftness: value);
    await _applyShadow();
  }

  Future<void> _applyShadow() async {
    if (_webViewController == null) return;
    final intensity = state.shadowEnabled ? state.shadowIntensity : 0.0;
    final softness = state.shadowSoftness;
    await _webViewController!.runJavaScript('''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv) return;
        mv.setAttribute('shadow-intensity', '$intensity');
        mv.setAttribute('shadow-softness', '$softness');
      })();
    ''');
  }

  Future<void> updateExposure(double value) async {
    state = state.copyWith(exposure: value);
    await _applyExposure();
  }

  Future<void> _applyExposure() async {
    if (_webViewController == null) return;
    await _webViewController!.runJavaScript(
      "document.querySelector('model-viewer').setAttribute('exposure', '${state.exposure}');",
    );
  }

  Future<void> setEnvironmentPreset(String preset) async {
    state = state.copyWith(environmentPreset: preset);
    if (_webViewController == null) return;
    await _webViewController!.runJavaScript(
      "document.querySelector('model-viewer').setAttribute('environment-image', '$preset');",
    );
  }

  Future<void> setToneMapper(String mapper) async {
    state = state.copyWith(toneMapper: mapper);
    await _applyToneMapper();
  }

  Future<void> _applyToneMapper() async {
    if (_webViewController == null) return;
    await _webViewController!.runJavaScript(
      "document.querySelector('model-viewer').setAttribute('tone-mapping', '${state.toneMapper}');",
    );
  }

  Future<void> updateCameraOrbit({double? theta, double? phi, double? radius}) async {
    state = state.copyWith(
      cameraOrbitTheta: theta ?? state.cameraOrbitTheta,
      cameraOrbitPhi: phi ?? state.cameraOrbitPhi,
      cameraOrbitRadius: radius ?? state.cameraOrbitRadius,
    );
    await _applyCamera();
  }

  Future<void> _applyCamera() async {
    if (_webViewController == null) return;
    final orbit = '${state.cameraOrbitTheta}deg ${state.cameraOrbitPhi}deg ${state.cameraOrbitRadius}%';
    final fov = '${state.fieldOfView}deg';
    final decay = state.interpolationDecay.toInt();
    await _webViewController!.runJavaScript('''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv) return;
        mv.setAttribute('camera-orbit', '$orbit');
        mv.setAttribute('field-of-view', '$fov');
        mv.setAttribute('interpolation-decay', '$decay');
      })();
    ''');
  }

  Future<void> resetCamera() async {
    if (_webViewController == null) return;
    await _webViewController!.runJavaScript(
      "document.querySelector('model-viewer').resetTurntableRotation(); document.querySelector('model-viewer').jumpCameraToGoal();",
    );
    await _applyCamera();
  }

  Future<void> toggleAutoRotate() async {
    state = state.copyWith(autoRotate: !state.autoRotate);
    if (_webViewController == null) return;
    final js = state.autoRotate
        ? "document.querySelector('model-viewer').setAttribute('auto-rotate', '');"
        : "document.querySelector('model-viewer').removeAttribute('auto-rotate');";
    await _webViewController!.runJavaScript(js);
  }

  Future<void> applyColorToModel(Color color) async {
    state = state.copyWith(selectedColor: color);
    if (_webViewController == null || !state.isModelLoaded) return;

    if (color == Colors.transparent) {
      selectModel(state.selectedModelPath, state.isAssetModel);
      return;
    }

    final r = color.r.toStringAsFixed(4);
    final g = color.g.toStringAsFixed(4);
    final b = color.b.toStringAsFixed(4);
    final matName = state.selectedMaterial;

    await _webViewController!.runJavaScript('''
      (async () => {
        const viewer = document.querySelector('model-viewer');
        for (const material of viewer.model.materials) {
          if ('$matName' === 'All Materials' || material.name === '$matName') {
            material.pbrMetallicRoughness.setBaseColorFactor([$r, $g, $b, 1.0]);
          }
        }
      })();
    ''');
  }

  Future<void> updateMetalness(double value) async {
    state = state.copyWith(metalness: value);
    final matName = state.selectedMaterial;
    await _webViewController?.runJavaScript('''
      document.querySelector('model-viewer').model.materials.forEach(m => {
        if ('$matName' === 'All Materials' || m.name === '$matName') {
          m.pbrMetallicRoughness.setMetallicFactor($value);
        }
      });
    ''');
  }

  Future<void> updateRoughness(double value) async {
    state = state.copyWith(roughness: value);
    final matName = state.selectedMaterial;
    await _webViewController?.runJavaScript('''
      document.querySelector('model-viewer').model.materials.forEach(m => {
        if ('$matName' === 'All Materials' || m.name === '$matName') {
          m.pbrMetallicRoughness.setRoughnessFactor($value);
        }
      });
    ''');
  }

  // ── Texture upload ────────────────────────────────────────────────────────
  Future<void> pickAndApplyTexture() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      state = state.copyWith(isLoading: true);

      // Heavy encode off main thread
      final base64Image = await _encodeFileInIsolate(image.path);
      if (base64Image == null) throw Exception('Encode failed');

      final mimeType = image.mimeType ?? 'image/png';
      state = state.copyWith(
        uploadedTexturePath: image.path,
        hasCustomTexture: true,
        isLoading: false,
      );

      await _applyTextureBase64(base64Image, mimeType);
    } catch (e) {
      debugPrint('Failed to apply texture: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _applyTextureBase64(String base64, String mimeType) async {
    if (_webViewController == null || !state.isModelLoaded) return;
    final matName = state.selectedMaterial;
    await _webViewController!.runJavaScript('''
      (async () => {
        const viewer = document.querySelector('model-viewer');
        const dataUrl = 'data:$mimeType;base64,$base64';
        const response = await fetch(dataUrl);
        const blob = await response.blob();
        const objectUrl = URL.createObjectURL(blob);
        const texture = await viewer.createTexture(objectUrl);
        for (const material of viewer.model.materials) {
          if ('$matName' === 'All Materials' || material.name === '$matName') {
            material.pbrMetallicRoughness.baseColorTexture.setTexture(texture);
          }
        }
        URL.revokeObjectURL(objectUrl);
      })();
    ''');
  }

  Future<void> removeTexture() async {
    state = state.copyWith(
      hasCustomTexture: false,
      uploadedTexturePath: '',
    );
    selectModel(state.selectedModelPath, state.isAssetModel);
  }

  void setActiveTab(String tab) => state = state.copyWith(activeTab: tab);
  void togglePanel() => state = state.copyWith(isPanelExpanded: !state.isPanelExpanded);
  void setSelectedMaterial(String mat) => state = state.copyWith(selectedMaterial: mat);

  // ── Utils & Exports ──────────────────────────────────────────────────────
  Future<void> exportModel() async {
    try {
      final dir = await getTemporaryDirectory();
      final outputPath = '${dir.path}/Model_export.glb';

      if (state.isAssetModel) {
        final ByteData data = await rootBundle.load(state.selectedModelPath);
        await _decodeAndSaveInIsolate(base64Encode(data.buffer.asUint8List()), outputPath);
      } else {
        await File(state.selectedModelPath).copy(outputPath);
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(outputPath)],
          subject: '3D Model',
        ),
      );
    } catch (e) {
      debugPrint('Export failed: $e');
    }
  }

  Future<void> captureScreenshot() async {
    if (_webViewController == null || !state.isModelLoaded) return;
    const js = '''
      (async () => {
        const viewer = document.querySelector('model-viewer');
        const blob = await viewer.toBlob({idealAspect: true});
        const reader = new FileReader();
        reader.readAsDataURL(blob);
        reader.onloadend = () => ScreenshotChannel.postMessage(reader.result.split(',')[1]);
      })();
    ''';
    await _webViewController!.runJavaScript(js);
  }

  Future<void> saveScreenshotFromBase64(String base64) async {
    try {
      final dir = await getTemporaryDirectory();
      final outPath = '${dir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final saved = await _decodeAndSaveInIsolate(base64, outPath);
      if (saved != null) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(saved)],
            subject: '3D Screenshot',
          ),
        );
      }
    } catch (e) {
      debugPrint('Save failed: $e');
    }
  }
}

// ── Isolate Helpers ─────────────────────────────────────────────────────────
void _decodeAndSaveIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  receivePort.listen((msg) async {
    if (msg is Map) {
      try {
        final bytes = base64Decode(msg['base64'] as String);
        final file = File(msg['path'] as String);
        file.writeAsBytesSync(bytes);
        sendPort.send({'path': file.path, 'error': null});
      } catch (e) {
        sendPort.send({'path': null, 'error': e.toString()});
      }
    }
  });
}

/// Entry point for encode isolate
void _encodeIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  receivePort.listen((msg) {
    if (msg is Map) {
      final String path = msg['path'];
      try {
        final bytes = File(path).readAsBytesSync();
        sendPort.send({'base64': base64Encode(bytes), 'error': null});
      } catch (e) {
        sendPort.send({'base64': null, 'error': e.toString()});
      }
    }
  });
}

Future<String?> _encodeFileInIsolate(String filePath) async {
  final receivePort = ReceivePort();
  final isolate = await Isolate.spawn(_encodeIsolate, receivePort.sendPort);
  final completer = Completer<String?>();
  late SendPort workerSend;
  receivePort.listen((msg) {
    if (msg is SendPort) {
      workerSend = msg;
      workerSend.send({'path': filePath});
    } else if (msg is Map) {
      receivePort.close();
      isolate.kill();
      completer.complete(msg['base64'] as String?);
    }
  });
  return completer.future;
}

Future<String?> _decodeAndSaveInIsolate(String base64, String outPath) async {
  final receivePort = ReceivePort();
  final isolate = await Isolate.spawn(_decodeAndSaveIsolate, receivePort.sendPort);
  final completer = Completer<String?>();
  receivePort.listen((msg) {
    if (msg is SendPort) {
      msg.send({'base64': base64, 'path': outPath});
    } else if (msg is Map) {
      receivePort.close();
      isolate.kill();
      completer.complete(msg['path'] as String?);
    }
  });
  return completer.future;
}
