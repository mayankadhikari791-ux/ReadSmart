import 'package:flutter/material.dart';
import '../models/reading_analytics_models.dart';
import '../theme/app_colors.dart';

enum AnalyticsChartType {
  readingTime,
  pagesRead,
}

class AnalyticsTimeChart extends StatelessWidget {
  final List<DailyReadingRecord> records;
  final AnalyticsChartType chartType;
  final int goalDailyTarget; // e.g. 30 minutes or 20 pages

  const AnalyticsTimeChart({
    super.key,
    required this.records,
    this.chartType = AnalyticsChartType.readingTime,
    this.goalDailyTarget = 30,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: const Text(
          'No reading activity recorded yet',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    final isTime = chartType == AnalyticsChartType.readingTime;
    final unit = isTime ? 'm' : 'p';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: CustomPaint(
            painter: _AnalyticsBarChartPainter(
              records: records,
              isTime: isTime,
              goalTarget: goalDailyTarget,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: records.map((r) {
            final dayLetter = _dayLetter(r.date.weekday);
            final value = isTime ? r.minutesRead : r.pagesRead;
            return Column(
              children: [
                Text(
                  value > 0 ? '$value$unit' : '-',
                  style: TextStyle(
                    color: value >= goalDailyTarget
                        ? AppColors.primaryGold
                        : AppColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: value >= goalDailyTarget
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dayLetter,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  static String _dayLetter(int weekday) {
    switch (weekday) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      case 7:
        return 'S';
      default:
        return '';
    }
  }
}

class _AnalyticsBarChartPainter extends CustomPainter {
  final List<DailyReadingRecord> records;
  final bool isTime;
  final int goalTarget;

  _AnalyticsBarChartPainter({
    required this.records,
    required this.isTime,
    required this.goalTarget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    final values = records.map((r) => isTime ? r.minutesRead : r.pagesRead).toList();
    final maxValue = (values.reduce((a, b) => a > b ? a : b).clamp(goalTarget, 120)).toDouble();

    // Subtle horizontal gridlines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (1.0 - (i / 3.0));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Goal Target Dashed Line
    final goalY = (size.height * (1.0 - (goalTarget / maxValue))).clamp(0.0, size.height);
    final goalPaint = Paint()
      ..color = AppColors.primaryGold.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, goalY),
        Offset(startX + dashWidth, goalY),
        goalPaint,
      );
      startX += dashWidth + dashSpace;
    }

    final barCount = records.length;
    final totalSpacing = size.width * 0.45;
    final barWidth = ((size.width - totalSpacing) / barCount).clamp(10.0, 32.0);
    final gap = (size.width - (barWidth * barCount)) / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final val = values[i];
      final heightRatio = (val / maxValue).clamp(0.0, 1.0);
      final barHeight = (size.height * heightRatio).clamp(val > 0 ? 6.0 : 2.0, size.height);
      final x = i * (barWidth + gap);
      final y = size.height - barHeight;

      final isGoalMet = val >= goalTarget;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(5),
      );

      final barPaint = Paint();
      if (val == 0) {
        barPaint.color = Colors.white.withValues(alpha: 0.08);
      } else if (isGoalMet) {
        barPaint.shader = LinearGradient(
          colors: [
            AppColors.primaryGold,
            AppColors.secondaryAmber.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect.outerRect);
      } else {
        barPaint.color = AppColors.primaryGold.withValues(alpha: 0.35);
      }

      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsBarChartPainter oldDelegate) => true;
}

