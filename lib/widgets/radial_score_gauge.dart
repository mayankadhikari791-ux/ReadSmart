import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RadialScoreGauge extends StatelessWidget {
  final int score; // 0 to 100
  final double size;

  const RadialScoreGauge({
    super.key,
    required this.score,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(score: score),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int score;

  _GaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 1.25,
      pi * 1.5,
      false,
      trackPaint,
    );

    // Progress arc
    final sweepAngle = (pi * 1.5) * (score / 100.0);
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.primaryGold,
          AppColors.brightFlame,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 1.25,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.score != score;
}
