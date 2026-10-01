import 'package:flutter/material.dart';
import '../models/reading_analytics_models.dart';
import '../theme/app_colors.dart';

class IntelligentInsightsCard extends StatelessWidget {
  final List<ReadingImprovementInsight> insights;

  const IntelligentInsightsCard({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: insights.map((insight) => _buildInsightTile(insight)).toList(),
    );
  }

  Widget _buildInsightTile(ReadingImprovementInsight insight) {
    final isGuardrail = insight.isComprehensionGuardrail;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGuardrail
            ? const Color(0xFF23180D)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGuardrail
              ? AppColors.brightFlame.withValues(alpha: 0.5)
              : insight.accentColor.withValues(alpha: 0.3),
          width: isGuardrail ? 1.4 : 1.0,
        ),
        boxShadow: isGuardrail
            ? [
                BoxShadow(
                  color: AppColors.brightFlame.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(insight.icon, color: insight.accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: TextStyle(
                        color: isGuardrail ? AppColors.brightFlame : AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: insight.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        insight.badgeText,
                        style: TextStyle(
                          color: insight.accentColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (insight.tip.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: insight.accentColor, width: 3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 ',
                    style: TextStyle(fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      insight.tip,
                      style: const TextStyle(
                        color: AppColors.textWarmParchment,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

