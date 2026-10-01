import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ReadingSpeedChart extends StatelessWidget {
  final List<double> weeklyWpm;
  final List<String> days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  const ReadingSpeedChart({
    super.key,
    required this.weeklyWpm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: CustomPaint(
            painter: _SpeedChartPainter(weeklyWpm: weeklyWpm),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            final isToday = index == days.length - 1;
            return Text(
              days[index],
              style: TextStyle(
                color: isToday ? AppColors.primaryGold : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SpeedChartPainter extends CustomPainter {
  final List<double> weeklyWpm;

  _SpeedChartPainter({required this.weeklyWpm});

  @override
  void paint(Canvas canvas, Size size) {
    if (weeklyWpm.isEmpty) return;

    const minY = 180.0;
    const maxY = 320.0;
    final rangeY = maxY - minY;

    // Draw horizontal dashed gridlines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 3; i++) {
      final y = size.height - (i * (size.height / 3));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Generate Points
    final stepX = size.width / (weeklyWpm.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < weeklyWpm.length; i++) {
      final x = i * stepX;
      final normalizedY = (weeklyWpm[i] - minY) / rangeY;
      final y = size.height - (normalizedY * size.height);
      points.add(Offset(x, y));
    }

    // Fill Gradient Path
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (var pt in points) {
      fillPath.lineTo(pt.dx, pt.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primaryGold.withValues(alpha: 0.35),
          AppColors.primaryGold.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line Path
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = AppColors.primaryGold
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Draw data circles & highlight current day
    final dotPaint = Paint()..color = AppColors.primaryGold;
    final dotWhite = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;
      if (isLast) {
        // Glowing halo for today
        canvas.drawCircle(
          points[i],
          9,
          Paint()..color = AppColors.primaryGold.withValues(alpha: 0.3),
        );
        canvas.drawCircle(points[i], 5.5, dotPaint);
        canvas.drawCircle(points[i], 2.5, dotWhite);
      } else {
        canvas.drawCircle(points[i], 3.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedChartPainter oldDelegate) => true;
}
