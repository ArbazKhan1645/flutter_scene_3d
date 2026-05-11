import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class BottomTabBar extends StatelessWidget {
  final ModelController controller;
  const BottomTabBar({super.key, required this.controller});

  static const _tabs = [
    _TabData('color', Icons.palette_rounded, 'Color'),
    _TabData('material', Icons.auto_awesome_rounded, 'Material'),
    _TabData('texture', Icons.image_rounded, 'Textures'),
    _TabData('shadow', Icons.wb_shade_rounded, 'Shadow'),
    _TabData('lighting', Icons.wb_sunny_rounded, 'Lighting'),
    _TabData('camera', Icons.camera_alt_rounded, 'Camera'),
    _TabData('animation', Icons.animation_rounded, 'Animate'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          return Obx(() {
            final tab = _tabs[i];
            final isActive = controller.activeTab.value == tab.key;
            return GestureDetector(
              onTap: () {
                controller.activeTab.value = tab.key;
                if (!controller.isPanelExpanded.value) {
                  controller.isPanelExpanded.value = true;
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFE53935) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: 16,
                      color: isActive ? Colors.white : const Color(0xFF636E72),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Text(
                        tab.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _TabData {
  final String key;
  final IconData icon;
  final String label;
  const _TabData(this.key, this.icon, this.label);
}
