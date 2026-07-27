import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterscene_3d/src/features/viewer/models/viewer_state.dart';
import 'package:flutterscene_3d/src/features/viewer/providers/viewer_provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../editor/providers/editor_provider.dart';

import 'widgets/animation_panel.dart';
import 'widgets/camera_panel.dart';
import 'widgets/color_picker_panel.dart';
import 'widgets/lighting_panel.dart';
import 'widgets/material_panel.dart';
import 'widgets/panels_tab_widget.dart';
import 'widgets/shadow_panel.dart';
import 'widgets/texture_panel.dart';

class ModelViewerScreen extends ConsumerWidget {
  const ModelViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewerState = ref.watch(viewerProvider);
    final notifier = ref.read(viewerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  _buildTopBar(context, ref, viewerState, notifier),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildModelViewer(viewerState, notifier),
                        if (viewerState.isLoading)
                          _buildLoadingOverlay(viewerState),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _buildCameraControls(viewerState, notifier),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildFloatingPanel(context, viewerState, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, WidgetRef ref, ViewerState viewerState, ViewerNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                'FlutterScene 3D',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Text(
                'Professional Model Viewer',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          _editInEditorBtn(context, ref, viewerState),
          const SizedBox(width: 8),
          _topBarAction(
            icon: Icons.folder_open_rounded,
            onTap: notifier.pickModelFromDevice,
            tooltip: 'Open Model',
          ),
          const SizedBox(width: 8),
          _topBarAction(
            icon: Icons.download_rounded,
            onTap: notifier.exportModel,
            tooltip: 'Export Model',
          ),
          const SizedBox(width: 8),
          _topBarAction(
            icon: Icons.photo_camera_rounded,
            onTap: notifier.captureScreenshot,
            tooltip: 'Screenshot',
          ),
        ],
      ),
    );
  }

  Widget _editInEditorBtn(BuildContext context, WidgetRef ref, ViewerState state) {
    return Tooltip(
      message: 'Edit in 3D Scene Editor',
      child: InkWell(
        onTap: () {
          final path = state.selectedModelPath;
          if (path.isNotEmpty) {
            final editorNotifier = ref.read(editorProvider.notifier);
            if (state.isAssetModel) {
              editorNotifier.loadAssetModelIntoScene(path);
            } else {
              editorNotifier.loadCustomModelFile(path);
            }
          }
          Navigator.pushNamed(context, '/editor');
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6c63ff),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'Edit in Editor',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
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

  Widget _buildModelViewer(ViewerState state, ViewerNotifier notifier) {
    return ModelViewer(
      key: ValueKey(state.selectedModelPath),
      src: state.isAssetModel
          ? state.selectedModelPath
          : 'file://${state.selectedModelPath}',
      alt: '3D Model',
      autoRotate: state.autoRotate,
      autoRotateDelay: 0,
      cameraControls: true,
      backgroundColor: Colors.white,
      shadowIntensity: state.shadowIntensity,
      shadowSoftness: state.shadowSoftness,
      environmentImage: state.environmentPreset,
      exposure: state.exposure,
      ar: false,
      interactionPrompt: InteractionPrompt.none,
      javascriptChannels: {
        JavascriptChannel(
          'MaterialChannel',
          onMessageReceived: (msg) => notifier.updateMaterialList(msg.message),
        ),
        JavascriptChannel(
          'TextureListChannel',
          onMessageReceived: (msg) => notifier.updateTextureList(msg.message),
        ),
        JavascriptChannel(
          'AnimationChannel',
          onMessageReceived: (msg) => notifier.updateAnimationList(msg.message),
        ),
        JavascriptChannel(
          'ScreenshotChannel',
          onMessageReceived: (msg) =>
              notifier.saveScreenshotFromBase64(msg.message),
        ),
        JavascriptChannel(
          'ModelLoaded',
          onMessageReceived: (msg) => notifier.onModelLoaded(),
        ),
        JavascriptChannel(
          'LoadProgress',
          onMessageReceived: (msg) {
            final p = double.tryParse(msg.message) ?? 0.0;
            notifier.onLoadingProgress(p);
          },
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
            }
            if (document.readyState === 'loading') {
              document.addEventListener('DOMContentLoaded', attachListeners);
            } else {
              attachListeners();
            }
          })();
        """,
      onWebViewCreated: (WebViewController controller) {
        notifier.setWebViewController(controller);
      },
    );
  }

  Widget _buildLoadingOverlay(ViewerState state) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 20),
            Text(
              'Initializing Model ${(state.loadingProgress * 100).toInt()}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraControls(ViewerState state, ViewerNotifier notifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _camBtn(Icons.refresh_rounded, notifier.resetCamera, 'Reset View'),
        const SizedBox(height: 10),
        _camBtn(
          state.autoRotate
              ? Icons.pause_circle_filled_rounded
              : Icons.play_circle_filled_rounded,
          notifier.toggleAutoRotate,
          'Toggle Auto-Rotate',
          active: state.autoRotate,
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

  Widget _buildFloatingPanel(
    BuildContext context,
    ViewerState state,
    ViewerNotifier notifier,
  ) {
    final size = MediaQuery.of(context).size;
    final isExpanded = state.isPanelExpanded;

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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: notifier.togglePanel,
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
                  BottomTabBar(state: state, notifier: notifier),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            if (isExpanded)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: _getPanelContent(state.activeTab, state, notifier),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getPanelContent(String tab, var state, ViewerNotifier notifier) {
    switch (tab) {
      case 'color':
        return ColorPickerPanel(state: state, notifier: notifier);
      case 'material':
        return MaterialPanel(state: state, notifier: notifier);
      case 'texture':
        return TexturePanel(state: state, notifier: notifier);
      case 'shadow':
        return ShadowPanel(state: state, notifier: notifier);
      case 'lighting':
        return LightingPanel(state: state, notifier: notifier);
      case 'camera':
        return CameraPanel(state: state, notifier: notifier);
      case 'animation':
        return AnimationPanel(state: state, notifier: notifier);
      default:
        return ColorPickerPanel(state: state, notifier: notifier);
    }
  }
}
