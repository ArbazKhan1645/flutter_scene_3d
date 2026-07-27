/// Properties panel — shows transform and material controls for the
/// currently selected object.
library;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/scene_object.dart';
import '../../providers/editor_provider.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final obj      = state.selectedObject;

    if (obj == null) {
      return const _NothingSelected();
    }

    return Container(
      color: const Color(0xFF13131f),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Object name + type ─────────────────────────────────
          Row(
            children: [
              Icon(_typeIcon(obj.type), color: const Color(0xFF6c63ff), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  obj.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            obj.type.toUpperCase(),
            style: const TextStyle(color: Color(0xFF555566), fontSize: 10, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),

          // ── Transform ──────────────────────────────────────────
          _SectionHeader(label: 'TRANSFORM', icon: Icons.open_with_rounded),
          const SizedBox(height: 8),
          _Vec3Row(label: 'Position', x: obj.transform.px, y: obj.transform.py, z: obj.transform.pz),
          const SizedBox(height: 6),
          _Vec3Row(label: 'Rotation', x: obj.transform.rx, y: obj.transform.ry, z: obj.transform.rz),
          const SizedBox(height: 6),
          _Vec3Row(label: 'Scale',    x: obj.transform.sx, y: obj.transform.sy, z: obj.transform.sz),
          const SizedBox(height: 16),

          // ── Material ───────────────────────────────────────────
          _SectionHeader(label: 'MATERIAL', icon: Icons.palette_rounded),
          const SizedBox(height: 12),

          // Color swatch
          _ColorSwatch(hex: obj.color, onTap: () => _openColorPicker(context, obj, notifier)),
          const SizedBox(height: 14),

          // Metalness
          _Slider(
            label: 'Metalness',
            value: obj.metalness,
            onChanged: (v) => notifier.setObjectMetalness(obj.id, v),
          ),
          const SizedBox(height: 10),

          // Roughness
          _Slider(
            label: 'Roughness',
            value: obj.roughness,
            onChanged: (v) => notifier.setObjectRoughness(obj.id, v),
          ),
          const SizedBox(height: 10),

          // Opacity
          _Slider(
            label: 'Opacity',
            value: obj.opacity,
            onChanged: (v) => notifier.setObjectOpacity(obj.id, v),
          ),
          const SizedBox(height: 10),

          // Wireframe
          _BoolRow(
            label  : 'Wireframe',
            value  : obj.wireframe,
            onChanged: (v) => notifier.setObjectWireframe(obj.id, v),
          ),
          const SizedBox(height: 20),

          // ── Actions ────────────────────────────────────────────
          _SectionHeader(label: 'ACTIONS', icon: Icons.settings_rounded),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _ActionBtn(
              icon : Icons.center_focus_strong_rounded,
              label: 'Focus',
              onTap: () => notifier.focusObject(obj.id),
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionBtn(
              icon : Icons.copy_rounded,
              label: 'Duplicate',
              onTap: () => notifier.duplicateObject(obj.id),
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionBtn(
              icon : Icons.delete_outline_rounded,
              label: 'Delete',
              color: const Color(0xFFff6584),
              onTap: () => notifier.deleteObject(obj.id),
            )),
          ]),
        ],
      ),
    );
  }

  void _openColorPicker(
      BuildContext context, SceneObjectMeta obj, EditorNotifier notifier) {
    Color current = _parseHex(obj.color);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1c1c2e),
        title: const Text('Pick Color',
            style: TextStyle(color: Colors.white, fontSize: 15)),
        content: ColorPicker(
          pickerColor: current,
          onColorChanged: (c) {
            current = c;
            final r = (c.r * 255).round();
            final g = (c.g * 255).round();
            final b = (c.b * 255).round();
            final hex =
                '#${r.toRadixString(16).padLeft(2,'0')}'
                '${g.toRadixString(16).padLeft(2,'0')}'
                '${b.toRadixString(16).padLeft(2,'0')}';
            notifier.setObjectColorHex(obj.id, hex);
          },
          pickerAreaHeightPercent: 0.7,
          enableAlpha: false,
          labelTypes: const [],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: Color(0xFF6c63ff))),
          ),
        ],
      ),
    );
  }
}

Color _parseHex(String hex) {
  try {
    final s = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$s', radix: 16));
  } catch (_) {
    return const Color(0xFF6c63ff);
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'sphere'  : return Icons.circle_outlined;
    case 'plane'   : return Icons.crop_landscape_rounded;
    case 'cylinder': return Icons.panorama_vertical_rounded;
    case 'cone'    : return Icons.change_history_rounded;
    case 'torus'   : return Icons.donut_large_rounded;
    case 'capsule' : return Icons.inbox_rounded;
    case 'gltf'    : return Icons.view_in_ar_rounded;
    default        : return Icons.crop_square_rounded;
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 12, color: const Color(0xFF6c63ff)),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(
              color: Color(0xFF6c63ff), fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
    ],
  );
}

class _Vec3Row extends StatelessWidget {
  const _Vec3Row({required this.label, required this.x, required this.y, required this.z});
  final String label;
  final double x, y, z;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF888899), fontSize: 10, letterSpacing: 0.8)),
      const SizedBox(height: 4),
      Row(
        children: [
          _Vec3Field(axis: 'X', value: x, color: const Color(0xFFef4444)),
          const SizedBox(width: 6),
          _Vec3Field(axis: 'Y', value: y, color: const Color(0xFF4ade80)),
          const SizedBox(width: 6),
          _Vec3Field(axis: 'Z', value: z, color: const Color(0xFF60a5fa)),
        ],
      ),
    ],
  );
}

class _Vec3Field extends StatelessWidget {
  const _Vec3Field({required this.axis, required this.value, required this.color});
  final String axis;
  final double value;
  final Color  color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0d0d1a),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: color, width: 2)),
      ),
      child: Row(
        children: [
          Text(axis, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value.toStringAsFixed(2),
              style: const TextStyle(color: Color(0xFFccccdd), fontSize: 10),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Slider extends StatelessWidget {
  const _Slider({required this.label, required this.value, required this.onChanged});
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: const TextStyle(color: Color(0xFF888899), fontSize: 11)),
        const Spacer(),
        Text(value.toStringAsFixed(2),
            style: const TextStyle(color: Color(0xFFccccdd), fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight         : 2,
          activeTrackColor    : const Color(0xFF6c63ff),
          inactiveTrackColor  : const Color(0xFF1f1f35),
          thumbColor          : const Color(0xFF6c63ff),
          overlayColor        : const Color(0x226c63ff),
        ),
        child: Slider(value: value, onChanged: onChanged),
      ),
    ],
  );
}

class _BoolRow extends StatelessWidget {
  const _BoolRow({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF888899), fontSize: 11)),
      const Spacer(),
      Switch(
        value         : value,
        onChanged     : onChanged,
        activeThumbColor: const Color(0xFF6c63ff),
        trackColor    : WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF3a3570)
              : const Color(0xFF1f1f35),
        ),
      ),
    ],
  );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.hex, required this.onTap});
  final String hex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _parseHex(hex);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF2a2a40)),
            ),
          ),
          const SizedBox(width: 10),
          Text(hex.toUpperCase(),
              style: const TextStyle(color: Color(0xFFccccdd), fontSize: 12)),
          const Spacer(),
          const Text('tap to change',
              style: TextStyle(color: Color(0xFF444455), fontSize: 10)),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF444455), size: 16),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF6c63ff),
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color : const Color(0xFF1c1c2e),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2a2a40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    ),
  );
}

class _NothingSelected extends StatelessWidget {
  const _NothingSelected();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF13131f),
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded, color: Color(0xFF2a2a40), size: 40),
          SizedBox(height: 12),
          Text('Tap an object to\nselect it',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF444455), fontSize: 12)),
        ],
      ),
    ),
  );
}
