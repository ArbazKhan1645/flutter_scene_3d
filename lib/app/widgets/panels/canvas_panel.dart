import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class CameraPanel extends StatelessWidget {
  final ModelController controller;
  const CameraPanel({super.key, required this.controller});

  static const _color = Color(0xFF0984E3);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Reset button ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: _ActionBtn(
              label: 'Reset Camera View',
              icon: Icons.center_focus_strong_rounded,
              color: _color,
              onTap: controller.resetCamera,
            ),
          ),

          const SizedBox(height: 24),
          const _SectionLabel('FIELD OF VIEW'),
          const SizedBox(height: 12),

          Obx(
            () => _buildSlider(
              label: 'FOV',
              icon: Icons.camera_rounded,
              description: 'Vertical field of view in degrees',
              value: controller.fieldOfView.value,
              min: 10,
              max: 120,
              color: _color,
              displayValue: '${controller.fieldOfView.value.toInt()}°',
              onChanged: controller.updateFieldOfView,
            ),
          ),

          const SizedBox(height: 24),
          const _SectionLabel('CAMERA ORBIT'),
          const SizedBox(height: 12),

          // Horizontal (theta)
          Obx(
            () => _buildSlider(
              label: 'Horizontal Rotation',
              icon: Icons.rotate_right_rounded,
              description: 'Left / right orbit angle',
              value: controller.cameraOrbitTheta.value,
              min: -180,
              max: 180,
              color: _color,
              displayValue: '${controller.cameraOrbitTheta.value.toInt()}°',
              onChanged: (v) => controller.updateCameraOrbit(theta: v),
            ),
          ),

          const SizedBox(height: 16),

          // Vertical (phi)
          Obx(
            () => _buildSlider(
              label: 'Vertical Angle',
              icon: Icons.rotate_left_rounded,
              description: 'Up / down orbit angle',
              value: controller.cameraOrbitPhi.value,
              min: 0,
              max: 180,
              color: const Color(0xFF6C5CE7),
              displayValue: '${controller.cameraOrbitPhi.value.toInt()}°',
              onChanged: (v) => controller.updateCameraOrbit(phi: v),
            ),
          ),

          const SizedBox(height: 16),

          // Radius
          Obx(
            () => _buildSlider(
              label: 'Distance',
              icon: Icons.zoom_out_map_rounded,
              description: 'Camera distance from model (%)',
              value: controller.cameraOrbitRadius.value,
              min: 50,
              max: 200,
              color: const Color(0xFF00B894),
              displayValue: '${controller.cameraOrbitRadius.value.toInt()}%',
              onChanged: (v) => controller.updateCameraOrbit(radius: v),
            ),
          ),

          const SizedBox(height: 24),
          const _SectionLabel('INTERPOLATION DECAY'),
          const SizedBox(height: 12),

          Obx(
            () => _buildSlider(
              label: 'Smoothness',
              icon: Icons.linear_scale_rounded,
              description: 'Camera movement easing (higher = slower/smoother)',
              value: controller.interpolationDecay.value,
              min: 10,
              max: 500,
              color: const Color(0xFFFDCB6E),
              displayValue: '${controller.interpolationDecay.value.toInt()}ms',
              onChanged: controller.updateInterpolationDecay,
            ),
          ),

          const SizedBox(height: 24),
          const _SectionLabel('QUICK PRESETS'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _presetBtn('Front', 0, 90, 100, controller),
              _presetBtn('Side', 90, 75, 100, controller),
              _presetBtn('Top', 0, 10, 100, controller),
              _presetBtn('Diagonal', 45, 60, 120, controller),
              _presetBtn('Close Up', 0, 75, 70, controller),
            ],
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
    required double min,
    required double max,
    required Color color,
    required String displayValue,
    required Future<void> Function(double) onChanged,
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
              displayValue,
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
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: (v) => onChanged(v),
          ),
        ),
      ],
    );
  }

  Widget _presetBtn(
    String label,
    double theta,
    double phi,
    double radius,
    ModelController ctrl,
  ) {
    return GestureDetector(
      onTap: () =>
          ctrl.updateCameraOrbit(theta: theta, phi: phi, radius: radius),
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

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
