import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../providers/viewer_provider.dart';

class ColorPickerPanel extends StatelessWidget {
  final dynamic state;
  final ViewerNotifier notifier;

  const ColorPickerPanel({
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
              'Surface Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              state.selectedMaterial,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 10, // Mock preset colors or use from state if available
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final color = Colors.primaries[index % Colors.primaries.length];
              return GestureDetector(
                onTap: () => notifier.applyColorToModel(color),
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: state.selectedColor == color
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        ColorPicker(
          pickerColor: state.selectedColor,
          onColorChanged: notifier.applyColorToModel,
          pickerAreaHeightPercent: 0.7,
          enableAlpha: false,
          displayThumbColor: true,
          paletteType: PaletteType.hsvWithHue,
          labelTypes: const [],
          pickerAreaBorderRadius: BorderRadius.circular(20),
        ),
      ],
    );
  }
}
