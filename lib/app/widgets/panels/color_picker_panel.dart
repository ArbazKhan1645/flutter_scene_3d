import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class ColorPickerPanel extends StatelessWidget {
  final ModelController controller;

  const ColorPickerPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Paint Selection',
                style: TextStyle(
                  color: Color(0xFF2D3436),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: controller.selectedColor.value.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    controller
                        .colorToHex(controller.selectedColor.value)
                        .toUpperCase(),
                    style: TextStyle(
                      color:
                          controller.selectedColor.value == Colors.transparent
                          ? Colors.grey
                          : controller.selectedColor.value,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Material Selector
          const Text(
            'TARGET MATERIAL',
            style: TextStyle(
              color: Color(0xFF636E72),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedMaterial.value,
                  isExpanded: true,
                  icon: const Icon(Icons.layers_outlined, size: 20),
                  style: const TextStyle(
                    color: Color(0xFF2D3436),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: controller.modelMaterials.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null)
                      controller.selectedMaterial.value = newValue;
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'POPULAR PRESETS',
            style: TextStyle(
              color: Color(0xFF636E72),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.presetColors.map((color) {
                final isSelected =
                    controller.selectedColor.value.value == color.value;
                return GestureDetector(
                  onTap: () => controller.applyColorToModel(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color == Colors.transparent ? Colors.white : color,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE53935)
                            : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFE53935).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: color == Colors.transparent
                        ? const Icon(
                            Icons.refresh_rounded,
                            color: Colors.grey,
                            size: 20,
                          )
                        : isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: _contrastColor(color),
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'CUSTOM COLOR',
            style: TextStyle(
              color: Color(0xFF636E72),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => _showColorPickerDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Obx(
                    () => Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:
                            controller.selectedColor.value == Colors.transparent
                            ? Colors.white
                            : controller.selectedColor.value,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Mix Custom Paint',
                    style: TextStyle(
                      color: Color(0xFF2D3436),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.colorize_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    Color tempColor = controller.selectedColor.value == Colors.transparent
        ? Colors.white
        : controller.selectedColor.value;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Custom Paint',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            colorPickerWidth: 280,
            enableAlpha: false,
            labelTypes: const [ColorLabelType.hex],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF636E72)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              controller.applyColorToModel(tempColor);
              Get.back();
            },
            child: const Text('Apply Color'),
          ),
        ],
      ),
    );
  }

  Color _contrastColor(Color bg) {
    if (bg == Colors.transparent) return Colors.black;
    final luminance =
        (0.299 * bg.red + 0.587 * bg.green + 0.114 * bg.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
