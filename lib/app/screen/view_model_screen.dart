import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/widgets/panels/animation_panel.dart';
import 'package:model_viewer/app/widgets/panels/canvas_panel.dart';
import 'package:model_viewer/app/widgets/panels/color_picker_panel.dart';
import 'package:model_viewer/app/widgets/panels/ligthing_panel.dart';
import 'package:model_viewer/app/widgets/panels/material_pannel.dart';
import 'package:model_viewer/app/controller/model_controller.dart';
import 'package:model_viewer/app/widgets/panels/shadow_panel.dart';
import 'package:model_viewer/app/widgets/panels_tab_widegt.dart';
import 'package:model_viewer/app/widgets/panels/texture_panel.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModelViewerScreen extends StatelessWidget {
  const ModelViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ModelController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  _buildTopBar(ctrl),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildModelViewer(ctrl),
                        Obx(
                          () => ctrl.isLoading.value
                              ? _buildLoadingOverlay(ctrl)
                              : const SizedBox.shrink(),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _buildCameraControls(ctrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating panel
            Obx(() => _buildFloatingPanel(context, ctrl)),
          ],
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar(ModelController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Model Viewer - Flutter',
                style: TextStyle(
                  color: Color(0xFF2D3436),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Arbaz Khan Mashwnai',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          _topBarAction(
            icon: Icons.folder_open_rounded,
            onTap: ctrl.pickModelFromDevice,
            tooltip: 'Open Model',
          ),
          const SizedBox(width: 8),
          _topBarAction(
            icon: Icons.download_rounded,
            onTap: ctrl.exportModel,
            tooltip: 'Export Model',
          ),
          const SizedBox(width: 8),
          _topBarAction(
            icon: Icons.photo_camera_rounded,
            onTap: ctrl.captureScreenshot,
            tooltip: 'Screenshot',
          ),
        ],
      ),
    );
  }

  Widget _topBarAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: const Color(0xFF2D3436), size: 20),
          ),
        ),
      ),
    );
  }

  // ── Model viewer ─────────────────────────────────────────────────────────
  Widget _buildModelViewer(ModelController ctrl) {
    return Obx(
      () => ModelViewer(
        key: ValueKey(ctrl.selectedModelPath.value),
        src: ctrl.isAssetModel.value
            ? ctrl.selectedModelPath.value
            : 'file://${ctrl.selectedModelPath.value}',
        alt: '3D Model',
        autoRotate: true,
        autoRotateDelay: 0,
        cameraControls: true,
        backgroundColor: Colors.white,
        shadowIntensity: ctrl.shadowIntensity.value,
        shadowSoftness: ctrl.shadowSoftness.value,
        environmentImage: ctrl.environmentPreset.value,
        exposure: ctrl.exposure.value,
        ar: false,
        interactionPrompt: InteractionPrompt.none,
        javascriptChannels: {
          JavascriptChannel(
            'MaterialChannel',
            onMessageReceived: (msg) => ctrl.updateMaterialList(msg.message),
          ),
          JavascriptChannel(
            'TextureListChannel',
            onMessageReceived: (msg) => ctrl.updateTextureList(msg.message),
          ),
          JavascriptChannel(
            'AnimationChannel',
            onMessageReceived: (msg) => ctrl.updateAnimationList(msg.message),
          ),
          JavascriptChannel(
            'ScreenshotChannel',
            onMessageReceived: (msg) =>
                ctrl.saveScreenshotFromBase64(msg.message),
          ),
          JavascriptChannel(
            'ModelLoaded',
            onMessageReceived: (msg) => ctrl.onModelLoaded(),
          ),
          JavascriptChannel(
            'LoadProgress',
            onMessageReceived: (msg) {
              final p = double.tryParse(msg.message) ?? 0.0;
              ctrl.onLoadingProgress(p);
            },
          ),
          JavascriptChannel(
            'ModelError',
            onMessageReceived: (msg) => ctrl.onModelError(msg.message),
          ),
        },
        relatedJs: r"""
            (function() {
              function attachListeners() {
                const mv = document.querySelector('model-viewer');
                if (!mv) { setTimeout(attachListeners, 200); return; }

                mv.addEventListener('load', function() {
                  if (window.ModelLoaded) ModelLoaded.postMessage('loaded');
                });

                mv.addEventListener('progress', function(e) {
                  const p = (e.detail && e.detail.totalProgress != null)
                    ? e.detail.totalProgress : 0;
                  if (window.LoadProgress) LoadProgress.postMessage(String(p));
                });

                mv.addEventListener('error', function(e) {
                  if (window.ModelError) ModelError.postMessage('Failed to load model');
                });
              }
              if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', attachListeners);
              } else {
                attachListeners();
              }
            })();
          """,
        onWebViewCreated: (WebViewController controller) {
          ctrl.onWebViewCreated(controller);
        },
      ),
    );
  }

  // ── Loading overlay ──────────────────────────────────────────────────────
  Widget _buildLoadingOverlay(ModelController ctrl) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFE53935)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Obx(
              () => Text(
                'Initializing Model ${(ctrl.loadingProgress.value * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF2D3436),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Camera buttons ───────────────────────────────────────────────────────
  Widget _buildCameraControls(ModelController ctrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _camBtn(Icons.refresh_rounded, ctrl.resetCamera, 'Reset View'),
        const SizedBox(height: 10),
        Obx(
          () => _camBtn(
            ctrl.autoRotate.value
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_filled_rounded,
            ctrl.toggleAutoRotate,
            'Toggle Auto-Rotate',
            active: ctrl.autoRotate.value,
          ),
        ),
      ],
    );
  }

  Widget _camBtn(
    IconData icon,
    VoidCallback onTap,
    String tooltip, {
    bool active = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 4,
        shadowColor: Colors.black26,
        color: active ? const Color(0xFFE53935) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: active ? Colors.white : const Color(0xFF2D3436),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // ── Floating panel ───────────────────────────────────────────────────────
  Widget _buildFloatingPanel(BuildContext context, ModelController ctrl) {
    final size = MediaQuery.of(context).size;
    final isExpanded = ctrl.isPanelExpanded.value;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: isExpanded ? size.height * 0.52 : 82,
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle + Tab bar
            GestureDetector(
              onTap: () => ctrl.isPanelExpanded.toggle(),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  BottomTabBar(controller: ctrl),
                  const SizedBox(height: 6),
                ],
              ),
            ),

            // Content
            if (isExpanded)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Obx(() {
                    switch (ctrl.activeTab.value) {
                      case 'color':
                        return ColorPickerPanel(controller: ctrl);
                      case 'material':
                        return MaterialPanel(controller: ctrl);
                      case 'texture':
                        return TexturePanel(controller: ctrl);
                      case 'shadow':
                        return ShadowPanel(controller: ctrl);
                      case 'lighting':
                        return LightingPanel(controller: ctrl);
                      case 'camera':
                        return CameraPanel(controller: ctrl);
                      case 'animation':
                        return AnimationPanel(controller: ctrl);
                      default:
                        return ColorPickerPanel(controller: ctrl);
                    }
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
