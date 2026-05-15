import 'package:flutter/material.dart';
import '../../providers/viewer_provider.dart';

class CameraPanel extends StatelessWidget {
  final dynamic state;
  final ViewerNotifier notifier;

  const CameraPanel({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Camera Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildSlider(
          'Field of View',
          state.fieldOfView,
          (val) => notifier.updateCameraOrbit(theta: val), // Corrected callback
          min: 10,
          max: 90,
        ),
        const SizedBox(height: 20),
        _buildSlider(
          'Orbit Phi',
          state.cameraOrbitPhi,
          (val) => notifier.updateCameraOrbit(phi: val),
          min: 0,
          max: 180,
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged, {double min = 0, double max = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: const Color(0xFFE53935),
        ),
      ],
    );
  }
}
