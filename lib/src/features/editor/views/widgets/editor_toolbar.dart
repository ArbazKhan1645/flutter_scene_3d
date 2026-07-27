/// Top toolbar for the Scene Editor — dark glassmorphism style.
/// Redesigned with responsive scrolling / two rows to guarantee Export, Save, Screenshot,
/// Shadows, and Custom Import are always visible on mobile and narrow screens.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/editor_provider.dart';

class EditorToolbar extends ConsumerWidget {
  const EditorToolbar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131f),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Row 1: App Header, Status & Primary Actions (Save, Export, Share) ──
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _Btn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack, tooltip: 'Back'),
                const SizedBox(width: 4),

                const Text(
                  '3D Editor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(width: 8),

                // Status message
                if (state.statusMessage != null)
                  Expanded(
                    child: Text(
                      state.statusMessage!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: state.statusMessage!.startsWith('⚠')
                            ? const Color(0xFFff6584)
                            : const Color(0xFF4ade80),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const Spacer(),

                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6c63ff)),
                    ),
                  ),

                // ── PROMINENT EXPORT & SAVE BUTTONS ─────────────────
                _PillBtn(
                  icon: Icons.save_rounded,
                  label: 'Save',
                  color: const Color(0xFF2a2a40),
                  textColor: Colors.white,
                  onTap: notifier.saveScene,
                  tooltip: 'Save Scene JSON',
                ),
                const SizedBox(width: 6),
                _PillBtn(
                  icon: Icons.ios_share_rounded,
                  label: 'Export GLB',
                  color: const Color(0xFF6c63ff),
                  textColor: Colors.white,
                  onTap: notifier.exportGLB,
                  tooltip: 'Export & Share GLB Model',
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFF1f1f35)),

          // ── Row 2: Secondary View Controls (Scrollable row) ─────────────────
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Import Custom File Button
                  _IconTextBtn(
                    icon: Icons.file_upload_rounded,
                    label: 'Import Model',
                    onTap: notifier.importCustomModelFromDevice,
                    tooltip: 'Import custom .glb/.gltf from storage',
                  ),
                  _VDivider(),

                  // Screenshot Share
                  _IconTextBtn(
                    icon: Icons.camera_alt_rounded,
                    label: 'Snapshot',
                    onTap: notifier.takeScreenshot,
                    tooltip: 'Take 3D Screenshot & Share',
                  ),
                  _VDivider(),

                  // Grid toggle
                  _ToggleBtn(
                    icon: Icons.grid_on_rounded,
                    active: state.isGridVisible,
                    tooltip: 'Toggle Ground Grid',
                    onTap: notifier.toggleGrid,
                  ),
                  // Axes toggle
                  _ToggleBtn(
                    icon: Icons.my_location_rounded,
                    active: state.isAxesVisible,
                    tooltip: 'Toggle XYZ Axes',
                    onTap: notifier.toggleAxes,
                  ),
                  // Snap toggle
                  _ToggleBtn(
                    icon: Icons.attractions_rounded,
                    active: state.isSnapEnabled,
                    tooltip: 'Toggle Grid Snap',
                    onTap: notifier.toggleSnap,
                  ),
                  // Shadows toggle
                  _ToggleBtn(
                    icon: Icons.wb_shade_rounded,
                    active: state.shadowsEnabled,
                    tooltip: 'Toggle Realtime Shadows',
                    onTap: notifier.toggleShadows,
                  ),
                  _VDivider(),

                  // Camera perspective toggle
                  _ToggleBtn(
                    icon: state.cameraType == 'perspective'
                        ? Icons.videocam_rounded
                        : Icons.grid_3x3_rounded,
                    active: false,
                    tooltip: state.cameraType == 'perspective'
                        ? 'Switch to Orthographic'
                        : 'Switch to Perspective',
                    onTap: () => notifier.setCameraType(
                      state.cameraType == 'perspective' ? 'orthographic' : 'perspective',
                    ),
                  ),
                  // Fit scene
                  _Btn(
                    icon: Icons.center_focus_strong_rounded,
                    onTap: notifier.fitScene,
                    tooltip: 'Fit All Objects in View',
                  ),
                  // Clear scene
                  _Btn(
                    icon: Icons.delete_sweep_rounded,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1c1c2e),
                          title: const Text('Clear Scene?', style: TextStyle(color: Colors.white, fontSize: 16)),
                          content: const Text('Remove all objects from the scene?', style: TextStyle(color: Color(0xFF888899))),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Color(0xFFff6584)))),
                          ],
                        ),
                      );
                      if (confirm == true) unawaited(notifier.clearScene());
                    },
                    tooltip: 'Clear Entire Scene',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  const _PillBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

class _IconTextBtn extends StatelessWidget {
  const _IconTextBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6c63ff), size: 15),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFccccdd), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Icon(icon, color: const Color(0xFFaaaacc), size: 18),
      ),
    ),
  );
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.tooltip,
  });
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Icon(
          icon,
          size: 18,
          color: active ? const Color(0xFF6c63ff) : const Color(0xFF555566),
        ),
      ),
    ),
  );
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 18,
    color: const Color(0xFF2a2a40),
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );
}
