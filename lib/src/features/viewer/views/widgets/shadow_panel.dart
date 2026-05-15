import 'package:flutter/material.dart';
import '../../providers/viewer_provider.dart';

class ShadowPanel extends StatelessWidget {
  final dynamic state;
  final ViewerNotifier notifier;

  const ShadowPanel({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Text(
              'Ground Shadows',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Switch(
              value: state.shadowEnabled,
              onChanged: notifier.toggleShadow,
              activeThumbColor: const Color(0xFFE53935),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSlider(
          'Intensity',
          state.shadowIntensity,
          notifier.updateShadowIntensity,
        ),
        const SizedBox(height: 20),
        _buildSlider(
          'Softness',
          state.shadowSoftness,
          notifier.updateShadowSoftness,
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFE53935), // Slider still uses activeColor but I'll check if it needs changing. Actually Slider usually uses activeColor.
        ),
      ],
    );
  }
}
