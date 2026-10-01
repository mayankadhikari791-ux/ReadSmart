import 'package:flutter/material.dart';
import '../models/coach_models.dart';
import '../theme/app_colors.dart';

class CoachGoalCard extends StatelessWidget {
  final CoachGoal goal;
  final VoidCallback? onToggle;

  const CoachGoalCard({
    super.key,
    required this.goal,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = goal.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? goal.accentColor.withValues(alpha: 0.5)
              : AppColors.darkBorder,
          width: isDone ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: goal.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  goal.icon,
                  color: goal.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        color: isDone ? Colors.white : AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: isDone ? TextDecoration.none : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (goal.type == CoachGoalType.finishChapter)
                IconButton(
                  icon: Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isDone ? AppColors.successGreen : AppColors.textMuted,
                    size: 26,
                  ),
                  tooltip: isDone ? 'Mark Incomplete' : 'Mark Chapter Finished',
                  onPressed: onToggle,
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.successGreen.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isDone ? 'Done' : '${(goal.progress * 100).toInt()}%',
                    style: TextStyle(
                      color: isDone ? AppColors.successGreen : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.progressLabel,
                style: TextStyle(
                  color: isDone ? goal.accentColor : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                'Target: ${goal.targetValue.toInt()} ${goal.unit}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? AppColors.successGreen : goal.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

