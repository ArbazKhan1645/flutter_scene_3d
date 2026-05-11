import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class LightingPanel extends StatelessWidget {
  final ModelController controller;
  const LightingPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Exposure ───────────────────────────────────────────────────
          const _SectionLabel('EXPOSURE'),
          const SizedBox(height: 12),
          Obx(
            () => _buildSlider(
              label: 'Scene Exposure',
              icon: Icons.wb_sunny_rounded,
              description: 'Controls overall brightness',
              value: controller.exposure.value,
              min: 0.0,
              max: 4.0,
              color: const Color(0xFFFDCB6E),
              onChanged: controller.updateExposure,
              displayValue: controller.exposure.value.toStringAsFixed(2),
            ),
          ),

          const SizedBox(height: 28),

          // ── Tone Mapper ────────────────────────────────────────────────
          const _SectionLabel('TONE MAPPER'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.toneMappers
                .map((t) => _toneChip(t, controller))
                .toList(),
          ),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.2)),
            ),
            child: const Text(
              'Neutral — best color accuracy\nACES — filmic, high contrast\nAgX — modern cinematic\nCommerce — clean product look',
              style: TextStyle(
                color: Color(0xFF636E72),
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Environment Presets ────────────────────────────────────────
          const _SectionLabel('ENVIRONMENT PRESET'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.envPresets
                .map((e) => _envChip(e, controller))
                .toList(),
          ),

          const SizedBox(height: 20),

          // ── Custom HDR URL ─────────────────────────────────────────────
          const _SectionLabel('CUSTOM ENVIRONMENT URL'),
          const SizedBox(height: 10),
          _CustomEnvField(controller: controller),
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
    required Future<void> Function(double) onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
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

  Widget _toneChip(String tone, ModelController ctrl) {
    return Obx(() {
      final selected = ctrl.toneMapper.value == tone;
      const color = Color(0xFFFDCB6E);
      return GestureDetector(
        onTap: () => ctrl.setToneMapper(tone),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : Colors.grey[200]!),
          ),
          child: Text(
            tone.toUpperCase(),
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF2D3436),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    });
  }

  Widget _envChip(String env, ModelController ctrl) {
    return Obx(() {
      final selected = ctrl.environmentPreset.value == env;
      const color = Color(0xFF00B894);
      return GestureDetector(
        onTap: () => ctrl.setEnvironmentPreset(env),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? color : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : Colors.grey[200]!),
          ),
          child: Text(
            env,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF2D3436),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
}

class _CustomEnvField extends StatefulWidget {
  final ModelController controller;
  const _CustomEnvField({required this.controller});
  @override
  State<_CustomEnvField> createState() => _CustomEnvFieldState();
}

class _CustomEnvFieldState extends State<_CustomEnvField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'https://example.com/env.hdr',
              hintStyle: const TextStyle(
                color: Color(0xFFB2BEC3),
                fontSize: 12,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: const Color(0xFF00B894),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () =>
                widget.controller.setCustomEnvironmentUrl(_ctrl.text.trim()),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
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
