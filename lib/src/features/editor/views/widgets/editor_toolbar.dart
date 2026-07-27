/// Top toolbar for the Scene Editor — dark glassmorphism style.
library;

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
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF13131f),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 12)],
      ),
      child: Row(
        children: [
          // ── Back ────────────────────────────────────────────────
          _Btn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack, tooltip: 'Back'),
          const SizedBox(width: 4),

          // ── Title ───────────────────────────────────────────────
          const Text(
            'Scene Editor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),

          const Spacer(),

          // ── Status ──────────────────────────────────────────────
          if (state.statusMessage != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                state.statusMessage!,
                style: TextStyle(
                  color: state.statusMessage!.startsWith('⚠')
                      ? const Color(0xFFff6584)
                      : const Color(0xFF4ade80),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6c63ff)),
              ),
            ),

          // ── Grid toggle ─────────────────────────────────────────
          _ToggleBtn(
            icon: Icons.grid_on_rounded,
            active: state.isGridVisible,
            tooltip: 'Toggle Grid',
            onTap: notifier.toggleGrid,
          ),
          // ── Axes toggle ─────────────────────────────────────────
          _ToggleBtn(
            icon: Icons.my_location_rounded,
            active: state.isAxesVisible,
            tooltip: 'Toggle Axes',
            onTap: notifier.toggleAxes,
          ),
          // ── Snap toggle ─────────────────────────────────────────
          _ToggleBtn(
            icon: Icons.attractions_rounded,
            active: state.isSnapEnabled,
            tooltip: 'Toggle Snap',
            onTap: notifier.toggleSnap,
          ),
          // ── Camera type ─────────────────────────────────────────
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
          // ── Fit scene ───────────────────────────────────────────
          _Btn(
            icon: Icons.center_focus_strong_rounded,
            onTap: notifier.fitScene,
            tooltip: 'Fit Scene',
          ),
          // ── Save ────────────────────────────────────────────────
          _Btn(
            icon: Icons.save_rounded,
            onTap: notifier.saveScene,
            tooltip: 'Save Scene',
          ),
          // ── Export GLB ──────────────────────────────────────────
          _Btn(
            icon: Icons.ios_share_rounded,
            onTap: notifier.exportGLB,
            tooltip: 'Export GLB',
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, color: const Color(0xFFaaaacc), size: 20),
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(
          icon,
          size: 20,
          color: active ? const Color(0xFF6c63ff) : const Color(0xFF555566),
        ),
      ),
    ),
  );
}
