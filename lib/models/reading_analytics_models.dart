import 'package:flutter/material.dart';

/// Supported analytical timeframes
enum AnalyticsTimeframe {
  thisWeek,
  thisMonth,
  allTime,
}

/// Reading time breakdown across distinct standard periods
class ReadingTimeBreakdown {
  final int todaySeconds;
  final int weeklySeconds;
  final int monthlySeconds;
  final int allTimeSeconds;

  const ReadingTimeBreakdown({
    required this.todaySeconds,
    required this.weeklySeconds,
    required this.monthlySeconds,
    required this.allTimeSeconds,
  });

  String formatSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String get todayFormatted => formatSeconds(todaySeconds);
  String get weeklyFormatted => formatSeconds(weeklySeconds);
  String get monthlyFormatted => formatSeconds(monthlySeconds);
  String get allTimeFormatted => formatSeconds(allTimeSeconds);
}

/// Daily aggregated reading record for chart visualizations
class DailyReadingRecord {
  final DateTime date;
  final int minutesRead;
  final int pagesRead;
  final int sessionsCount;
  final int avgWpm;

  const DailyReadingRecord({
    required this.date,
    required this.minutesRead,
    required this.pagesRead,
    required this.sessionsCount,
    required this.avgWpm,
  });

  bool get hasActivity => minutesRead > 0 || pagesRead > 0 || sessionsCount > 0;
}

/// Type of intelligent insight
enum InsightType {
  streak,
  sessionGrowth,
  timingHabit,
  speedComprehensionGuardrail,
  consistency,
  completionPace,
}

/// An actionable, reader-friendly improvement suggestion
class ReadingImprovementInsight {
  final String id;
  final InsightType type;
  final String title;
  final String message;
  final String tip;
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final bool isComprehensionGuardrail;

  const ReadingImprovementInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.tip,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    this.isComprehensionGuardrail = false,
  });
}

