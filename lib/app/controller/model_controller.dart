// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
// Simple Completer alias (dart:async)
import 'dart:async' show Completer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:file_picker/file_picker.dart';

// ---------------------------------------------------------------------------
// ModelController
// ---------------------------------------------------------------------------

class ModelController extends GetxController {
  WebViewController? webViewController;

  // ── Core state ────────────────────────────────────────────────────────────
  final Rx<Color> selectedColor = Colors.transparent.obs;
  final RxDouble metalness = 0.5.obs;
  final RxDouble roughness = 0.5.obs;
  final RxBool autoRotate = true.obs;
  final RxBool isModelLoaded = false.obs;
  final RxBool isLoading = true.obs;
  final RxDouble loadingProgress = 0.0.obs;
  final RxString uploadedTexturePath = ''.obs;
  final RxBool hasCustomTexture = false.obs;
  final RxString activeTab = 'color'.obs;
  final RxBool isPanelExpanded = false.obs;

  // ── Model loading ─────────────────────────────────────────────────────────
  final RxString selectedModelPath = 'assets/models/Motorcycle.glb'.obs;
  final RxBool isAssetModel = true.obs;
  final RxList<String> assetModels = <String>[].obs;

  // ── Material & Textures ───────────────────────────────────────────────────
  final RxList<String> modelMaterials = <String>[].obs;
  final RxString selectedMaterial = 'All Materials'.obs;

  /// Textures embedded in the model, populated after load
  final RxList<Map<String, dynamic>> modelTextures =
      <Map<String, dynamic>>[].obs;

  // ── Shadow controls ───────────────────────────────────────────────────────
  final RxBool shadowEnabled = true.obs;
  final RxDouble shadowIntensity = 1.0.obs;
  final RxDouble shadowSoftness = 1.0.obs;

  // ── Lighting / Environment ────────────────────────────────────────────────
  final RxDouble exposure = 1.0.obs;
  final RxString environmentPreset = 'neutral'.obs;
  final RxString customEnvUrl = ''.obs;
  // Available built-in env presets shown in UI
  final List<String> envPresets = [
    'neutral',
    'legacy',
    'commerce',
    'dawn',
    'forest',
    'night',
    'warehouse',
    'sunset',
  ];
  final RxString toneMapper = 'neutral'.obs; // neutral | aces | agx | commerce
  final List<String> toneMappers = ['neutral', 'aces', 'agx', 'commerce'];

  // ── Camera controls ───────────────────────────────────────────────────────
  final RxDouble fieldOfView = 45.0.obs; // degrees
  final RxDouble cameraOrbitTheta = 0.0.obs; // horizontal deg
  final RxDouble cameraOrbitPhi = 75.0.obs; // vertical deg
  final RxDouble cameraOrbitRadius = 105.0.obs; // percent
  final RxDouble interpolationDecay = 50.0.obs; // ms
  final RxBool limitOrbit = false.obs;

  // ── Animations ────────────────────────────────────────────────────────────
  final RxList<String> modelAnimations = <String>[].obs;
  final RxString selectedAnimation = ''.obs;
  final RxBool isAnimationPlaying = false.obs;

  // ── Hotspot / Annotations ─────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> hotspots = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAssetModels();
  }

  // ── Preset colors ─────────────────────────────────────────────────────────
  final List<Color> presetColors = [
    Colors.transparent,
    const Color(0xFFCC0000),
    const Color(0xFF1565C0),
    const Color(0xFF2E7D32),
    const Color(0xFF212121),
    const Color(0xFFFFFFFF),
    const Color(0xFFFF6F00),
    const Color(0xFF6A1B9A),
    const Color(0xFF00695C),
    const Color(0xFFAA8800),
    const Color(0xFF37474F),
    const Color(0xFFBF360C),
    const Color(0xFF0D47A1),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Asset model discovery
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> loadAssetModels() async {
    try {
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
        rootBundle,
      );
      final List<String> models = manifest
          .listAssets()
          .where((k) => k.startsWith('assets/models/') && k.endsWith('.glb'))
          .toList();
      assetModels.value = models.isNotEmpty
          ? models
          : ['assets/models/Motorcycle.glb'];
    } catch (e) {
      debugPrint('Error loading asset models: $e');
      assetModels.value = ['assets/models/Motorcycle.glb'];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Model selection / reset
  // ─────────────────────────────────────────────────────────────────────────
  void selectModel(String path, bool isAsset) {
    selectedModelPath.value = path;
    isAssetModel.value = isAsset;
    isModelLoaded.value = false;
    isLoading.value = true;
    loadingProgress.value = 0.0;

    selectedColor.value = Colors.transparent;
    hasCustomTexture.value = false;
    uploadedTexturePath.value = '';
    modelMaterials.clear();
    modelTextures.clear();
    modelAnimations.clear();
    selectedMaterial.value = 'All Materials';
    selectedAnimation.value = '';
    isAnimationPlaying.value = false;
  }

  Future<void> pickModelFromDevice() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb', 'gltf'],
      );
      if (result != null && result.files.single.path != null) {
        selectModel(result.files.single.path!, false);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick model: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WebView callbacks
  // ─────────────────────────────────────────────────────────────────────────
  void onWebViewCreated(WebViewController controller) {
    webViewController = controller;
  }

  void onModelLoaded() {
    isModelLoaded.value = true;
    isLoading.value = false;
    fetchModelMaterials();
    fetchModelTextures();
    fetchModelAnimations();
    _applyShadow();
    _applyExposure();
    _applyToneMapper();
    _applyCamera();
  }

  void onLoadingProgress(double progress) {
    loadingProgress.value = progress;
    if (progress >= 1.0) isLoading.value = false;
  }

  void onModelError(String error) {
    isLoading.value = false;
    Get.snackbar('Error', error);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Material fetch
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchModelMaterials() async {
    if (webViewController == null) return;
    const js = '''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv || !mv.model) return;
        const names = mv.model.materials.map(m => m.name || 'Unnamed Material');
        MaterialChannel.postMessage(JSON.stringify(names));
      })();
    ''';
    await webViewController!.runJavaScript(js);
  }

  void updateMaterialList(String jsonList) {
    try {
      final List<dynamic> names = json.decode(jsonList);
      modelMaterials.value = ['All Materials', ...names.cast<String>()];
    } catch (e) {
      debugPrint('Error parsing materials: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Texture fetch — reads embedded textures from glTF scene graph
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchModelTextures() async {
    if (webViewController == null) return;
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
    await webViewController!.runJavaScript(js);
  }

  void updateTextureList(String jsonList) {
    try {
      final List<dynamic> list = json.decode(jsonList);
      modelTextures.value = list.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error parsing textures: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Animation fetch & control
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchModelAnimations() async {
    if (webViewController == null) return;
    const js = '''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv) return;
        const anims = mv.availableAnimations || [];
        AnimationChannel.postMessage(JSON.stringify(anims));
      })();
    ''';
    await webViewController!.runJavaScript(js);
  }

  void updateAnimationList(String jsonList) {
    try {
      final List<dynamic> anims = json.decode(jsonList);
      modelAnimations.value = anims.cast<String>();
    } catch (e) {
      debugPrint('Error parsing animations: $e');
    }
  }

  Future<void> playAnimation(String name) async {
    if (webViewController == null) return;
    selectedAnimation.value = name;
    isAnimationPlaying.value = true;
    final js =
        '''
      (function() {
        const mv = document.querySelector('model-viewer');
        mv.animationName = '$name';
        mv.play();
      })();
    ''';
    await webViewController!.runJavaScript(js);
  }

  Future<void> pauseAnimation() async {
    if (webViewController == null) return;
    isAnimationPlaying.value = false;
    await webViewController!.runJavaScript(
      "document.querySelector('model-viewer').pause();",
    );
  }

  Future<void> stopAnimation() async {
    if (webViewController == null) return;
    isAnimationPlaying.value = false;
    selectedAnimation.value = '';
    await webViewController!.runJavaScript(
      "document.querySelector('model-viewer').pause(); document.querySelector('model-viewer').currentTime = 0;",
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shadow controls
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> toggleShadow(bool value) async {
    shadowEnabled.value = value;
    await _applyShadow();
  }

  Future<void> updateShadowIntensity(double value) async {
    shadowIntensity.value = value;
    await _applyShadow();
  }

  Future<void> updateShadowSoftness(double value) async {
    shadowSoftness.value = value;
    await _applyShadow();
  }

  Future<void> _applyShadow() async {
    if (webViewController == null) return;
    final intensity = shadowEnabled.value ? shadowIntensity.value : 0.0;
    final softness = shadowSoftness.value;
    final js =
        '''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv) return;
        mv.setAttribute('shadow-intensity', '$intensity');
        mv.setAttribute('shadow-softness', '$softness');
      })();
    ''';
    await webViewController!.runJavaScript(js);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lighting / Environment
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateExposure(double value) async {
    exposure.value = value;
    await _applyExposure();
  }

  Future<void> _applyExposure() async {
    if (webViewController == null) return;
    await webViewController!.runJavaScript(
      "document.querySelector('model-viewer').setAttribute('exposure', '${exposure.value}');",
    );
  }

  Future<void> setEnvironmentPreset(String preset) async {
    environmentPreset.value = preset;
    if (webViewController == null) return;
    await webViewController!.runJavaScript(
      "document.querySelector('model-viewer').setAttribute('environment-image', '$preset');",
    );
  }

  Future<void> setCustomEnvironmentUrl(String url) async {
    customEnvUrl.value = url;
    environmentPreset.value = 'custom';
    if (webViewController == null || url.isEmpty) return;
    await webViewController!.runJavaScript(
      "document.querySelector('model-viewer').setAttribute('environment-image', '$url');",
    );
  }

  Future<void> setToneMapper(String mapper) async {
    toneMapper.value = mapper;
    await _applyToneMapper();
  }

  Future<void> _applyToneMapper() async {
    if (webViewController == null) return;
    await webViewController!.runJavaScript(
      "document.querySelector('model-viewer').setAttribute('tone-mapping', '${toneMapper.value}');",
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Camera controls
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateFieldOfView(double deg) async {
    fieldOfView.value = deg;
    await _applyCamera();
  }

  Future<void> updateCameraOrbit({
    double? theta,
    double? phi,
    double? radius,
  }) async {
    if (theta != null) cameraOrbitTheta.value = theta;
    if (phi != null) cameraOrbitPhi.value = phi;
    if (radius != null) cameraOrbitRadius.value = radius;
    await _applyCamera();
  }

  Future<void> updateInterpolationDecay(double ms) async {
    interpolationDecay.value = ms;
    await _applyCamera();
  }

  Future<void> _applyCamera() async {
    if (webViewController == null) return;
    final orbit =
        '${cameraOrbitTheta.value}deg ${cameraOrbitPhi.value}deg ${cameraOrbitRadius.value}%';
    final fov = '${fieldOfView.value}deg';
    final decay = interpolationDecay.value.toInt();
    final js =
        '''
      (function() {
        const mv = document.querySelector('model-viewer');
        if (!mv) return;
        mv.setAttribute('camera-orbit', '$orbit');
        mv.setAttribute('field-of-view', '$fov');
        mv.setAttribute('interpolation-decay', '$decay');
      })();
    ''';
    await webViewController!.runJavaScript(js);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Color
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> applyColorToModel(Color color) async {
    selectedColor.value = color;
    if (webViewController == null || !isModelLoaded.value) return;

    if (color == Colors.transparent) {
      final current = selectedModelPath.value;
      final isAsset = isAssetModel.value;
      selectModel(current, isAsset);
      return;
    }

    final r = (color.red / 255).toStringAsFixed(4);
    final g = (color.green / 255).toStringAsFixed(4);
    final b = (color.blue / 255).toStringAsFixed(4);
    final matName = selectedMaterial.value;

    final js =
        '''
      (async () => {
        const viewer = document.querySelector('model-viewer');
        for (const material of viewer.model.materials) {
          if ('$matName' === 'All Materials' || material.name === '$matName') {
            material.pbrMetallicRoughness.setBaseColorFactor([$r, $g, $b, 1.0]);
          }
        }
      })();
    ''';
    await webViewController!.runJavaScript(js);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Metalness / Roughness
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateMetalness(double value) async {
    metalness.value = value;
    final matName = selectedMaterial.value;
    await webViewController?.runJavaScript('''
      document.querySelector('model-viewer').model.materials.forEach(m => {
        if ('$matName' === 'All Materials' || m.name === '$matName') {
          m.pbrMetallicRoughness.setMetallicFactor($value);
        }
      });
    ''');
  }

  Future<void> updateRoughness(double value) async {
    roughness.value = value;
    final matName = selectedMaterial.value;
    await webViewController?.runJavaScript('''
      document.querySelector('model-viewer').model.materials.forEach(m => {
        if ('$matName' === 'All Materials' || m.name === '$matName') {
          m.pbrMetallicRoughness.setRoughnessFactor($value);
        }
      });
    ''');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Texture upload — isolate for base64 encode
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> pickAndApplyTexture() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      Get.snackbar(
        'Processing',
        'Encoding texture...',
        duration: const Duration(seconds: 2),
      );

      // Heavy encode off main thread
      final base64Image = await _encodeFileInIsolate(image.path);
      if (base64Image == null) throw Exception('Encode failed');

      final mimeType = image.mimeType ?? 'image/png';
      uploadedTexturePath.value = image.path;
      hasCustomTexture.value = true;

      await _applyTextureBase64(base64Image, mimeType);
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply texture: $e');
    }
  }

  Future<void> _applyTextureBase64(String base64, String mimeType) async {
    if (webViewController == null || !isModelLoaded.value) return;
    final matName = selectedMaterial.value;
    final js =
        '''
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
    ''';
    await webViewController!.runJavaScript(js);
  }

  Future<void> removeTexture() async {
    hasCustomTexture.value = false;
    uploadedTexturePath.value = '';
    selectModel(selectedModelPath.value, isAssetModel.value);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Camera helpers
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> toggleAutoRotate() async {
    autoRotate.value = !autoRotate.value;
    if (webViewController == null) return;
    final js = autoRotate.value
        ? "document.querySelector('model-viewer').setAttribute('auto-rotate', '');"
        : "document.querySelector('model-viewer').removeAttribute('auto-rotate');";
    await webViewController!.runJavaScript(js);
  }

  Future<void> resetCamera() async {
    if (webViewController == null) return;
    await webViewController!.runJavaScript(
      "document.querySelector('model-viewer').resetTurntableRotation(); document.querySelector('model-viewer').jumpCameraToGoal();",
    );
    // Re-apply saved orbit
    await _applyCamera();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Export & Screenshot — isolate for file I/O
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> exportModel() async {
    try {
      final dir = await getTemporaryDirectory();
      final outputPath = '${dir.path}/Model_export.glb';

      if (isAssetModel.value) {
        final ByteData data = await rootBundle.load(selectedModelPath.value);
        // Write bytes in isolate
        await _decodeAndSaveInIsolate(
          base64Encode(data.buffer.asUint8List()),
          outputPath,
        );
      } else {
        await File(selectedModelPath.value).copy(outputPath);
      }
      await Share.shareXFiles([XFile(outputPath)], subject: '3D Model');
    } catch (e) {
      Get.snackbar('Error', 'Export failed: $e');
    }
  }

  Future<void> captureScreenshot() async {
    if (webViewController == null || !isModelLoaded.value) return;
    const js = '''
      (async () => {
        const viewer = document.querySelector('model-viewer');
        const blob = await viewer.toBlob({idealAspect: true});
        const reader = new FileReader();
        reader.readAsDataURL(blob);
        reader.onloadend = () => ScreenshotChannel.postMessage(reader.result.split(',')[1]);
      })();
    ''';
    await webViewController!.runJavaScript(js);
  }

  Future<void> saveScreenshotFromBase64(String base64) async {
    try {
      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';

      // Decode + save in isolate
      final saved = await _decodeAndSaveInIsolate(base64, outPath);
      if (saved != null) {
        await Share.shareXFiles([XFile(saved)], subject: '3D Screenshot');
      }
    } catch (e) {
      Get.snackbar('Error', 'Save failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Utils
  // ─────────────────────────────────────────────────────────────────────────
  String colorToHex(Color color) {
    if (color == Colors.transparent) return 'ORIGINAL';
    return '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Isolate helpers — heavy base64 / file I/O off the main thread
// ---------------------------------------------------------------------------

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

/// Entry point for decode+save isolate
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
  final isolate = await Isolate.spawn(
    _decodeAndSaveIsolate,
    receivePort.sendPort,
  );
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
