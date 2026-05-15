import 'package:flutter/material.dart';
import '../../providers/viewer_provider.dart';

class LightingPanel extends StatelessWidget {
  final dynamic state;
  final ViewerNotifier notifier;

  const LightingPanel({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final presets = [
      'neutral', 'legacy', 'commerce', 'dawn', 'forest', 'night', 'warehouse', 'sunset'
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Environment Exposure',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Slider(
          value: state.exposure,
          min: 0,
          max: 2,
          onChanged: notifier.updateExposure,
          activeColor: const Color(0xFFE53935),
        ),
        const Divider(height: 40),
        const Text(
          'Environment Preset',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemCount: presets.length,
          itemBuilder: (context, index) {
            final p = presets[index];
            final isSelected = state.environmentPreset == p;
            return GestureDetector(
              onTap: () => notifier.setEnvironmentPreset(p),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE53935) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  p.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
