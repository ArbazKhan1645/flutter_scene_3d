/// Modeling tools panel — provides CSG Booleans, Mesh Modifiers (Bend, Twist, Taper, Mirror),
/// Material Presets, and Environment Lighting controls.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/editor_provider.dart';

class ModelingToolsPanel extends ConsumerStatefulWidget {
  const ModelingToolsPanel({super.key});

  @override
  ConsumerState<ModelingToolsPanel> createState() => _ModelingToolsPanelState();
}

class _ModelingToolsPanelState extends ConsumerState<ModelingToolsPanel> {
  double _bendAngle = 45.0;
  String _bendAxis  = 'y';
  double _twistAngle = 60.0;
  double _taperScale = 0.5;

  String? _cutterObjectId;

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final selected = state.selectedObject;

    return Container(
      color: const Color(0xFF13131f),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Panel Title ──────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.build_circle_rounded, color: Color(0xFF6c63ff), size: 18),
              SizedBox(width: 8),
              Text(
                '3D MODELING TOOLKIT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1f1f35), height: 1),
          const SizedBox(height: 14),

          // ── 1. MESH MODIFIERS & DEFORMATIONS ─────────────────────
          const _SectionHeader(label: 'MESH MODIFIERS (DEFORM)', icon: Icons.gesture_rounded),
          const SizedBox(height: 8),

          if (selected == null)
            const _NoSelectionHint(message: 'Select an object to apply mesh modifiers')
          else ...[
            // Bend Modifier
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1c1c2e),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2a2a40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Bend Geometry', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      _AxisChip(label: 'X', active: _bendAxis == 'x', onTap: () => setState(() => _bendAxis = 'x')),
                      _AxisChip(label: 'Y', active: _bendAxis == 'y', onTap: () => setState(() => _bendAxis = 'y')),
                      _AxisChip(label: 'Z', active: _bendAxis == 'z', onTap: () => setState(() => _bendAxis = 'z')),
                    ],
                  ),
                  Slider(
                    value: _bendAngle,
                    min: -180, max: 180,
                    activeColor: const Color(0xFF6c63ff),
                    onChanged: (v) => setState(() => _bendAngle = v),
                  ),
                  Row(
                    children: [
                      Text('${_bendAngle.round()}° angle', style: const TextStyle(color: Color(0xFF888899), fontSize: 10)),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6c63ff),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => notifier.bendSelected(_bendAxis, _bendAngle),
                        icon: const Icon(Icons.check, size: 12),
                        label: const Text('Apply Bend', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Twist Modifier
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1c1c2e),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2a2a40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Twist Geometry', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Slider(
                    value: _twistAngle,
                    min: -360, max: 360,
                    activeColor: const Color(0xFF6c63ff),
                    onChanged: (v) => setState(() => _twistAngle = v),
                  ),
                  Row(
                    children: [
                      Text('${_twistAngle.round()}° twist', style: const TextStyle(color: Color(0xFF888899), fontSize: 10)),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6c63ff),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => notifier.twistSelected(_twistAngle),
                        icon: const Icon(Icons.check, size: 12),
                        label: const Text('Apply Twist', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Taper Modifier
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1c1c2e),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2a2a40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Taper Top Scale', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Slider(
                    value: _taperScale,
                    min: 0.0, max: 2.0,
                    activeColor: const Color(0xFF6c63ff),
                    onChanged: (v) => setState(() => _taperScale = v),
                  ),
                  Row(
                    children: [
                      Text('Top ratio: ${_taperScale.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF888899), fontSize: 10)),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6c63ff),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => notifier.taperSelected(_taperScale),
                        icon: const Icon(Icons.check, size: 12),
                        label: const Text('Apply Taper', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Mirror & Alignment Row
            Row(
              children: [
                Expanded(
                  child: _ToolBtn(
                    icon: Icons.flip_rounded,
                    label: 'Flip X',
                    onTap: () => notifier.mirrorSelected('x'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ToolBtn(
                    icon: Icons.flip_rounded,
                    label: 'Flip Y',
                    onTap: () => notifier.mirrorSelected('y'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ToolBtn(
                    icon: Icons.flip_rounded,
                    label: 'Flip Z',
                    onTap: () => notifier.mirrorSelected('z'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ToolBtn(
                    icon: Icons.vertical_align_bottom_rounded,
                    label: 'Align Ground',
                    onTap: notifier.alignSelectedToGround,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // ── 2. CSG BOOLEAN CUT / SUBTRACT ────────────────────────
          const _SectionHeader(label: 'BOOLEAN CUTOUTS (WHEEL ARCHES & SLOTS)', icon: Icons.content_cut_rounded),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1c1c2e),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2a2a40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected == null
                      ? '1. Select the base target (e.g. Car Body Box)'
                      : 'Target Object: ${selected.name}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: _cutterObjectId,
                  isExpanded: true,
                  hint: const Text('2. Pick Cutter Object (e.g. Cylinder)', style: TextStyle(color: Color(0xFF888899), fontSize: 11)),
                  dropdownColor: const Color(0xFF1c1c2e),
                  items: state.sceneObjects
                      .where((o) => o.id != selected?.id)
                      .map((o) => DropdownMenuItem(
                            value: o.id,
                            child: Text(o.name, style: const TextStyle(color: Colors.white, fontSize: 11)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _cutterObjectId = v),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff6584),
                    minimumSize: const Size(double.infinity, 34),
                  ),
                  onPressed: (selected != null && _cutterObjectId != null)
                      ? () {
                          notifier.booleanSubtract(selected.id, _cutterObjectId!);
                          setState(() => _cutterObjectId = null);
                        }
                      : null,
                  icon: const Icon(Icons.content_cut_rounded, size: 14),
                  label: const Text('Subtract / Cut Out', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 3. MATERIAL PRESETS ──────────────────────────────────
          const _SectionHeader(label: 'MATERIAL PRESETS', icon: Icons.palette_rounded),
          const SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              _PresetChip(label: 'Car Paint', color: const Color(0xFFd62828), onTap: () => notifier.setMaterialPreset('car_paint')),
              _PresetChip(label: 'Glass',     color: const Color(0x66ffffff), onTap: () => notifier.setMaterialPreset('glass')),
              _PresetChip(label: 'Chrome',    color: const Color(0xFFe0e0e0), onTap: () => notifier.setMaterialPreset('chrome')),
              _PresetChip(label: 'Neon Glow', color: const Color(0xFF00f0ff), onTap: () => notifier.setMaterialPreset('neon')),
              _PresetChip(label: 'Gold',      color: const Color(0xFFffd700), onTap: () => notifier.setMaterialPreset('gold')),
              _PresetChip(label: 'Matte',     color: const Color(0xFF6c63ff), onTap: () => notifier.setMaterialPreset('matte')),
              _PresetChip(label: 'Wood',      color: const Color(0xFF8b5a2b), onTap: () => notifier.setMaterialPreset('wood')),
            ],
          ),
          const SizedBox(height: 20),

          // ── 4. ENVIRONMENT & LIGHTING PRESETS ─────────────────────
          const _SectionHeader(label: 'ENVIRONMENT LIGHTING', icon: Icons.light_mode_rounded),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(child: _EnvBtn(label: 'Studio',    icon: Icons.wb_sunny_rounded,    onTap: () => notifier.setEnvironmentPreset('studio'))),
              const SizedBox(width: 6),
              Expanded(child: _EnvBtn(label: 'Sunset',    icon: Icons.brightness_4_rounded,onTap: () => notifier.setEnvironmentPreset('sunset'))),
              const SizedBox(width: 6),
              Expanded(child: _EnvBtn(label: 'Cyberpunk', icon: Icons.flash_on_rounded,    onTap: () => notifier.setEnvironmentPreset('cyberpunk'))),
              const SizedBox(width: 6),
              Expanded(child: _EnvBtn(label: 'Daylight',  icon: Icons.wb_cloudy_rounded,   onTap: () => notifier.setEnvironmentPreset('daylight'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 13, color: const Color(0xFF6c63ff)),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6c63ff),
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _AxisChip extends StatelessWidget {
  const _AxisChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6c63ff) : const Color(0xFF13131f),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF888899), fontSize: 10, fontWeight: FontWeight.bold)),
    ),
  );
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1c2e),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2a2a40)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6c63ff)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Color(0xFFccccdd), fontSize: 9), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1c1c2e),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2a2a40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Color(0xFFccccdd), fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

class _EnvBtn extends StatelessWidget {
  const _EnvBtn({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1c2e),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2a2a40)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: const Color(0xFFffd700)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Color(0xFFccccdd), fontSize: 9)),
        ],
      ),
    ),
  );
}

class _NoSelectionHint extends StatelessWidget {
  const _NoSelectionHint({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1c1c2e),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(message, style: const TextStyle(color: Color(0xFF666677), fontSize: 11), textAlign: TextAlign.center),
  );
}
