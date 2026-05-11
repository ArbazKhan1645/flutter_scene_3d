import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class MaterialPanel extends StatelessWidget {
  final ModelController controller;

  const MaterialPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Surface Finish',
            style: TextStyle(
              color: Color(0xFF2D3436),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),

          // Metalness
          _buildSliderRow(
            label: 'Reflectivity',
            icon: Icons.blur_on_rounded,
            description: 'Metallic reflection intensity',
            valueObs: controller.metalness,
            onChanged: controller.updateMetalness,
            color: const Color(0xFF0984E3),
          ),

          const SizedBox(height: 20),

          // Roughness
          _buildSliderRow(
            label: 'Glossiness',
            icon: Icons.waves_rounded,
            description: 'Surface smoothness & shine',
            valueObs: controller.roughness,
            onChanged: controller.updateRoughness,
            color: const Color(0xFF00B894),
          ),

          const SizedBox(height: 30),

          const Text(
            'MATERIAL PRESETS',
            style: TextStyle(
              color: Color(0xFF636E72),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _presetChip('High Gloss', 0.9, 0.1, controller),
              _presetChip('Matte Finish', 0.0, 0.8, controller),
              _presetChip('Chrome', 1.0, 0.05, controller),
              _presetChip('Satin Silk', 0.5, 0.4, controller),
              _presetChip('Brushed', 0.8, 0.5, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required IconData icon,
    required String description,
    required RxDouble valueObs,
    required Future<void> Function(double) onChanged,
    required Color color,
  }) {
    return Column(
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
            Column(
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
            const Spacer(),
            Obx(
              () => Text(
                '${(valueObs.value * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.1),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 3,
              ),
              overlayColor: color.withOpacity(0.1),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: valueObs.value,
              min: 0.0,
              max: 1.0,
              onChanged: (v) => onChanged(v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _presetChip(
    String label,
    double met,
    double rough,
    ModelController ctrl,
  ) {
    return GestureDetector(
      onTap: () {
        ctrl.updateMetalness(met);
        ctrl.updateRoughness(rough);
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
