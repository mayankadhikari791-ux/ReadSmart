import 'package:flutter/material.dart';

/// The 7 distinct recommendation categories specified in ReadSmart's coaching philosophy.
enum CoachRecommendationCategory {
  speed,
  comprehension,
  consistency,
  distractions,
  vocabulary,
  sessionQuality,
  healthyHabits;

  String get label {
    switch (this) {
      case CoachRecommendationCategory.speed:
        return 'Reading Speed';
      case CoachRecommendationCategory.comprehension:
        return 'Comprehension';
      case CoachRecommendationCategory.consistency:
        return 'Consistency';
      case CoachRecommendationCategory.distractions:
        return 'Distractions';
      case CoachRecommendationCategory.vocabulary:
        return 'Vocabulary';
      case CoachRecommendationCategory.sessionQuality:
        return 'Session Quality';
      case CoachRecommendationCategory.healthyHabits:
        return 'Healthy Habits';
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case CoachRecommendationCategory.speed:
        return Icons.speed_rounded;
      case CoachRecommendationCategory.comprehension:
        return Icons.psychology_rounded;
      case CoachRecommendationCategory.consistency:
        return Icons.calendar_today_rounded;
      case CoachRecommendationCategory.distractions:
        return Icons.do_not_disturb_on_rounded;
      case CoachRecommendationCategory.vocabulary:
        return Icons.translate_rounded;
      case CoachRecommendationCategory.sessionQuality:
        return Icons.timer_outlined;
      case CoachRecommendationCategory.healthyHabits:
        return Icons.spa_rounded;
    }
  }
}

/// Action types that a coaching card can trigger in ReadSmart.
enum CoachActionType {
  startSprint,
  reviewFlashcards,
  testComprehension,
  openDistractionSettings,
  browseLibrary,
  none,
}

/// A personalized recommendation based directly on the user's actual reading metrics.
class CoachRecommendation {
  final String id;
  final CoachRecommendationCategory category;
  final String title;
  final String dataEvidence;
  final String recommendation;
  final String? actionLabel;
  final CoachActionType actionType;
  final bool isComprehensionGuardrail;
  final IconData icon;
  final Color accentColor;

  const CoachRecommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.dataEvidence,
    required this.recommendation,
    this.actionLabel,
    this.actionType = CoachActionType.none,
    this.isComprehensionGuardrail = false,
    required this.icon,
    required this.accentColor,
  });
}

/// Supported simple daily goals.
enum CoachGoalType {
  dailyMinutes,
  dailyPages,
  streak,
  vocabulary,
  finishChapter;

  String get label {
    switch (this) {
      case CoachGoalType.dailyMinutes:
        return 'Read 20 min today';
      case CoachGoalType.dailyPages:
        return 'Read 10 pages today';
      case CoachGoalType.streak:
        return '7-day streak';
      case CoachGoalType.vocabulary:
        return 'Learn 5 new words';
      case CoachGoalType.finishChapter:
        return 'Finish a chapter';
    }
  }
}

/// Simple goal tracking progress toward a reading target.
class CoachGoal {
  final String id;
  final CoachGoalType type;
  final String title;
  final String description;
  final double currentValue;
  final double targetValue;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final bool manualCompleted;

  CoachGoal({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.icon,
    required this.accentColor,
    this.manualCompleted = false,
  });

  bool get isCompleted => manualCompleted || currentValue >= targetValue;

  double get progress {
    if (isCompleted) return 1.0;
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  String get progressLabel {
    if (type == CoachGoalType.finishChapter) {
      return isCompleted ? 'Completed' : 'In Progress';
    }
    final curr = currentValue.toInt();
    final tgt = targetValue.toInt();
    return '$curr / $tgt $unit';
  }

  CoachGoal copyWith({
    double? currentValue,
    bool? manualCompleted,
  }) {
    return CoachGoal(
      id: id,
      type: type,
      title: title,
      description: description,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue,
      unit: unit,
      icon: icon,
      accentColor: accentColor,
      manualCompleted: manualCompleted ?? this.manualCompleted,
    );
  }
}

/// Self-assessed comprehension log for chapter retention.
class ComprehensionLog {
  final String id;
  final String bookTitle;
  final int score; // 0 - 100
  final int ratingStars; // 1 - 5
  final String notes;
  final DateTime timestamp;

  ComprehensionLog({
    required this.id,
    required this.bookTitle,
    required this.score,
    required this.ratingStars,
    required this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookTitle': bookTitle,
        'score': score,
        'ratingStars': ratingStars,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ComprehensionLog.fromJson(Map<String, dynamic> json) => ComprehensionLog(
        id: json['id'] as String,
        bookTitle: json['bookTitle'] as String? ?? 'Untitled Book',
        score: json['score'] as int? ?? 80,
        ratingStars: json['ratingStars'] as int? ?? 4,
        notes: json['notes'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
      );
}

