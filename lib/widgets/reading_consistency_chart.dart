import 'package:flutter/material.dart';
import '../models/reading_analytics_models.dart';
import '../theme/app_colors.dart';

class ReadingConsistencyChart extends StatelessWidget {
  final List<DailyReadingRecord> records;
  final double consistencyScore;

  const ReadingConsistencyChart({
    super.key,
    required this.records,
    required this.consistencyScore,
  });

  @override
  Widget build(BuildContext context) {
    final activeDaysCount = records.where((r) => r.pagesRead > 0 || r.minutesRead > 0).length;
    final totalDays = records.length;
    final percentage = (consistencyScore * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primaryGold, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$percentage% Active',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '$activeDaysCount of $totalDays days active',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Day matrix grid
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: records.map((r) {
            final hasRead = r.pagesRead > 0 || r.minutesRead > 0;
            final isHighVolume = r.minutesRead >= 30 || r.pagesRead >= 20;

            Color boxColor;
            if (isHighVolume) {
              boxColor = AppColors.primaryGold;
            } else if (hasRead) {
              boxColor = AppColors.primaryGold.withValues(alpha: 0.45);
            } else {
              boxColor = Colors.white.withValues(alpha: 0.06);
            }

            return Tooltip(
              message: '${r.date.month}/${r.date.day}: ${r.minutesRead}m, ${r.pagesRead} pages',
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: hasRead
                        ? AppColors.primaryGold.withValues(alpha: 0.6)
                        : Colors.transparent,
                    width: 0.5,
                  ),
                ),
                child: hasRead
                    ? const Center(
                        child: Icon(Icons.check, size: 12, color: Colors.black),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildLegendItem(Colors.white.withValues(alpha: 0.06), 'Missed'),
            const SizedBox(width: 10),
            _buildLegendItem(AppColors.primaryGold.withValues(alpha: 0.45), 'Read'),
            const SizedBox(width: 10),
            _buildLegendItem(AppColors.primaryGold, 'Goal Met'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}

