import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProgressBarWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color trackColor;
  final List<Color>? gradientColors;

  const ProgressBarWidget({
    super.key,
    required this.progress,
    this.height = 6.0,
    this.trackColor = const Color(0xFF2A2A2A),
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final colors = gradientColors ??
        const [
          AppColors.primaryGold,
          AppColors.brightFlame,
        ];

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fillWidth = constraints.maxWidth * clamped;
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: fillWidth,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
