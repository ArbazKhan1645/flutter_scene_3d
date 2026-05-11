import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class ShadowPanel extends StatelessWidget {
  final ModelController controller;
  const ShadowPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Toggle row ──────────────────────────────────────────────────
          Obx(
            () => _buildToggleRow(
              label: 'Ground Shadow',
              subtitle: 'Enable or disable model shadow',
              value: controller.shadowEnabled.value,
              onChanged: controller.toggleShadow,
              icon: Icons.wb_shade_rounded,
              color: const Color(0xFF6C5CE7),
            ),
          ),

          const SizedBox(height: 24),
          const _SectionLabel('SHADOW PROPERTIES'),
          const SizedBox(height: 14),

          // ── Intensity slider ────────────────────────────────────────────
          Obx(
            () => _buildSlider(
              label: 'Intensity',
              icon: Icons.brightness_6_rounded,
              description: 'Shadow darkness',
              value: controller.shadowIntensity.value,
              color: const Color(0xFF6C5CE7),
              enabled: controller.shadowEnabled.value,
              onChanged: controller.updateShadowIntensity,
            ),
          ),

          const SizedBox(height: 20),

          // ── Softness slider ─────────────────────────────────────────────
          Obx(
            () => _buildSlider(
              label: 'Softness',
              icon: Icons.blur_on_rounded,
              description: 'Shadow edge blur (0 = hard)',
              value: controller.shadowSoftness.value,
              color: const Color(0xFF00CEC9),
              enabled: controller.shadowEnabled.value,
              onChanged: controller.updateShadowSoftness,
            ),
          ),

          const SizedBox(height: 28),
          const _SectionLabel('PRESETS'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _presetBtn('No Shadow', 0.0, 1.0, controller),
              _presetBtn('Soft', 0.5, 0.8, controller),
              _presetBtn('Default', 1.0, 1.0, controller),
              _presetBtn('Hard', 1.0, 0.0, controller),
              _presetBtn('Dramatic', 1.5, 0.2, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF2D3436),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF636E72),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required IconData icon,
    required String description,
    required double value,
    required Color color,
    required bool enabled,
    required Future<void> Function(double) onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF2D3436),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF636E72),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.12),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 3,
              ),
              overlayColor: color.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 2.0,
              onChanged: enabled ? (v) => onChanged(v) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetBtn(
    String label,
    double intensity,
    double softness,
    ModelController ctrl,
  ) {
    return GestureDetector(
      onTap: () {
        ctrl.shadowEnabled.value = intensity > 0;
        ctrl.updateShadowIntensity(intensity);
        ctrl.updateShadowSoftness(softness);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF636E72),
      fontSize: 11,
      letterSpacing: 1.5,
      fontWeight: FontWeight.w800,
    ),
  );
}
