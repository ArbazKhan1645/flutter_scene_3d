import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class AnimationPanel extends StatelessWidget {
  final ModelController controller;
  const AnimationPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final anims = controller.modelAnimations;
      final playing = controller.isAnimationPlaying.value;
      final selected = controller.selectedAnimation.value;

      if (anims.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.animation_rounded,
                  color: Colors.grey[300],
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No animations found',
                style: TextStyle(
                  color: Color(0xFF636E72),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This model has no embedded animations',
                style: TextStyle(color: Color(0xFFB2BEC3), fontSize: 12),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playback controls
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE17055).withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE17055).withOpacity(0.15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlBtn(
                  icon: Icons.stop_rounded,
                  color: const Color(0xFFE17055),
                  onTap: controller.stopAnimation,
                  label: 'Stop',
                ),
                const SizedBox(width: 20),
                _bigPlayBtn(playing, selected, controller),
                const SizedBox(width: 20),
                _controlBtn(
                  icon: Icons.skip_next_rounded,
                  color: const Color(0xFFE17055),
                  onTap: () {
                    if (anims.isNotEmpty) {
                      final idx = anims.indexOf(selected);
                      final next = (idx + 1) % anims.length;
                      controller.playAnimation(anims[next]);
                    }
                  },
                  label: 'Next',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Animation list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: anims.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final anim = anims[i];
                final isSelected = anim == selected;
                return GestureDetector(
                  onTap: () {
                    if (isSelected && playing) {
                      controller.pauseAnimation();
                    } else {
                      controller.playAnimation(anim);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE17055).withOpacity(0.08)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE17055).withOpacity(0.3)
                            : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE17055).withOpacity(0.12)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isSelected && playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: isSelected
                                ? const Color(0xFFE17055)
                                : const Color(0xFF636E72),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            anim,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFE17055)
                                  : const Color(0xFF2D3436),
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected && playing) const _PulsingDot(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _controlBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigPlayBtn(bool playing, String selected, ModelController ctrl) {
    return GestureDetector(
      onTap: () {
        if (playing) {
          ctrl.pauseAnimation();
        } else if (selected.isNotEmpty) {
          ctrl.playAnimation(selected);
        } else if (ctrl.modelAnimations.isNotEmpty) {
          ctrl.playAnimation(ctrl.modelAnimations.first);
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE17055), Color(0xFFD63031)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE17055).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ac);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFE17055),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
