import 'package:flutter/material.dart';
import '../../providers/viewer_provider.dart';

class MaterialPanel extends StatelessWidget {
  final dynamic state;
  final ViewerNotifier notifier;

  const MaterialPanel({
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
          'Active Material',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: state.modelMaterials.map<Widget>((m) {
            final isSelected = state.selectedMaterial == m;
            return ChoiceChip(
              label: Text(m),
              selected: isSelected,
              onSelected: (val) => notifier.setSelectedMaterial(m),
              selectedColor: const Color(0xFFE53935),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
        const Divider(height: 40),
        const Text(
          'Physical Properties',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildSlider(
          'Metalness',
          state.metalness,
          notifier.updateMetalness,
        ),
        const SizedBox(height: 20),
        _buildSlider(
          'Roughness',
          state.roughness,
          notifier.updateRoughness,
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
          activeColor: const Color(0xFFE53935),
        ),
      ],
    );
  }
}
