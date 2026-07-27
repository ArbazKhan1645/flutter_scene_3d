/// Transform toolbar — floating buttons for Translate / Rotate / Scale modes
/// plus quick primitive creation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/editor_provider.dart';

class TransformToolbar extends ConsumerWidget {
  const TransformToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final mode     = state.transformMode;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131f),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1f1f35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Transform modes ─────────────────────────────────────
          _ModeBtn(
            icon   : Icons.open_with_rounded,
            label  : 'Move',
            active : mode == 'translate',
            onTap  : () => notifier.setTransformMode('translate'),
            shortcut: 'G',
          ),
          _Divider(),
          _ModeBtn(
            icon   : Icons.rotate_right_rounded,
            label  : 'Rotate',
            active : mode == 'rotate',
            onTap  : () => notifier.setTransformMode('rotate'),
            shortcut: 'R',
          ),
          _Divider(),
          _ModeBtn(
            icon   : Icons.zoom_out_map_rounded,
            label  : 'Scale',
            active : mode == 'scale',
            onTap  : () => notifier.setTransformMode('scale'),
            shortcut: 'S',
          ),
          Container(height: 1, color: const Color(0xFF252540), margin: const EdgeInsets.symmetric(vertical: 4)),
          // ── Focus / Reset ───────────────────────────────────────
          _ModeBtn(
            icon   : Icons.center_focus_strong_rounded,
            label  : 'Focus',
            active : false,
            onTap  : notifier.focusSelected,
            shortcut: 'F',
          ),
          _Divider(),
          _ModeBtn(
            icon   : Icons.refresh_rounded,
            label  : 'Reset',
            active : false,
            onTap  : notifier.resetCamera,
            shortcut: '',
          ),
        ],
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  const _ModeBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.shortcut,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final String shortcut;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: shortcut.isNotEmpty ? '$label  [$shortcut]' : label,
    preferBelow: false,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6c63ff).withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? const Color(0xFF6c63ff) : const Color(0xFF555566),
        ),
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: const Color(0xFF1a1a2e), margin: const EdgeInsets.symmetric(horizontal: 8));
}

// ── Primitives toolbar ────────────────────────────────────────────────────────

class PrimitivesBar extends ConsumerWidget {
  const PrimitivesBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(editorProvider.notifier);

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF13131f),
        border: Border(top: BorderSide(color: Color(0xFF1f1f35))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Text('Add',
                  style: TextStyle(color: Color(0xFF555566), fontSize: 11, letterSpacing: 1)),
            ),
            _PrimBtn(icon: Icons.crop_square_rounded, label: 'Cube',     onTap: notifier.createCube),
            _PrimBtn(icon: Icons.circle_outlined,     label: 'Sphere',   onTap: notifier.createSphere),
            _PrimBtn(icon: Icons.crop_landscape_rounded, label: 'Plane', onTap: notifier.createPlane),
            _PrimBtn(icon: Icons.panorama_vertical_rounded, label: 'Cylinder', onTap: notifier.createCylinder),
            _PrimBtn(icon: Icons.change_history_rounded, label: 'Cone',   onTap: notifier.createCone),
            _PrimBtn(icon: Icons.donut_large_rounded,    label: 'Torus',  onTap: notifier.createTorus),
            _PrimBtn(icon: Icons.inbox_rounded,          label: 'Capsule',onTap: notifier.createCapsule),
            Container(width: 1, height: 40, color: const Color(0xFF1f1f35), margin: const EdgeInsets.symmetric(horizontal: 8)),
            _LightBtn(icon: Icons.wb_sunny_rounded,         label: 'Ambient',     onTap: notifier.addAmbientLight),
            _LightBtn(icon: Icons.wb_twilight_rounded,      label: 'Directional', onTap: notifier.addDirectionalLight),
            _LightBtn(icon: Icons.highlight_rounded,        label: 'Point',       onTap: notifier.addPointLight),
            _LightBtn(icon: Icons.flashlight_on_rounded,    label: 'Spot',        onTap: notifier.addSpotLight),
            _LightBtn(icon: Icons.nights_stay_rounded,      label: 'Hemisphere',  onTap: notifier.addHemisphereLight),
          ],
        ),
      ),
    );
  }
}

class _PrimBtn extends StatelessWidget {
  const _PrimBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Add $label',
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1c1c2e),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2a2a40)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6c63ff), size: 18),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(color: Color(0xFF888899), fontSize: 9),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class _LightBtn extends StatelessWidget {
  const _LightBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Add $label Light',
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1c1c2e),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2a2a40)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFffd700), size: 18),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(color: Color(0xFF888899), fontSize: 9),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
