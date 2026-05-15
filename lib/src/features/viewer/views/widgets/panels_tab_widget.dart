import 'package:flutter/material.dart';
import '../../providers/viewer_provider.dart';

class BottomTabBar extends StatelessWidget {
  final dynamic state;
  final ViewerNotifier notifier;

  const BottomTabBar({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabItem('color', Icons.color_lens_rounded, 'Color'),
          _tabItem('material', Icons.layers_rounded, 'Materials'),
          _tabItem('texture', Icons.texture_rounded, 'Textures'),
          _tabItem('animation', Icons.movie_filter_rounded, 'Anims'),
          _tabItem('lighting', Icons.wb_sunny_rounded, 'Light'),
          _tabItem('shadow', Icons.nights_stay_rounded, 'Shadow'),
          _tabItem('camera', Icons.videocam_rounded, 'Camera'),
        ],
      ),
    );
  }

  Widget _tabItem(String id, IconData icon, String label) {
    final isActive = state.activeTab == id;
    return GestureDetector(
      onTap: () => notifier.setActiveTab(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE53935) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
