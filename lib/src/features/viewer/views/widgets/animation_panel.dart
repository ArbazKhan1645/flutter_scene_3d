import 'package:flutter/material.dart';
import '../../providers/viewer_provider.dart';

class AnimationPanel extends StatelessWidget {
  final dynamic state;
  final ViewerNotifier notifier;

  const AnimationPanel({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    if (state.modelAnimations.isEmpty) {
      return const Center(
        child: Text('No animations available for this model'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Animations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...state.modelAnimations.map<Widget>((anim) {
          final isSelected = state.selectedAnimation == anim;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE53935).withValues(alpha: 0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFE53935) : Colors.transparent,
              ),
            ),
            child: ListTile(
              title: Text(
                anim,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFE53935) : Colors.black,
                ),
              ),
              trailing: Icon(
                isSelected && state.isAnimationPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: isSelected ? const Color(0xFFE53935) : Colors.grey,
              ),
              onTap: () {
                if (isSelected && state.isAnimationPlaying) {
                  notifier.pauseAnimation();
                } else {
                  notifier.playAnimation(anim);
                }
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
