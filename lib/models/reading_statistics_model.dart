class ReadingStatistics {
  final String id;
  final int streakDays;
  final int totalPagesRead;
  final int totalReadingMinutes;
  final int booksCompleted;
  final int averageWpm;
  final List<double> weeklyWpmHistory;
  final int userReadingScore;

  ReadingStatistics({
    required this.id,
    required this.streakDays,
    required this.totalPagesRead,
    required this.totalReadingMinutes,
    required this.booksCompleted,
    required this.averageWpm,
    required this.weeklyWpmHistory,
    required this.userReadingScore,
  });

  String get formattedReadingTime {
    final h = totalReadingMinutes ~/ 60;
    final m = totalReadingMinutes % 60;
    return '${h}h ${m}min';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streakDays': streakDays,
      'totalPagesRead': totalPagesRead,
      'totalReadingMinutes': totalReadingMinutes,
      'booksCompleted': booksCompleted,
      'averageWpm': averageWpm,
      'weeklyWpmHistory': weeklyWpmHistory,
      'userReadingScore': userReadingScore,
    };
  }

  factory ReadingStatistics.fromJson(Map<String, dynamic> json) {
    return ReadingStatistics(
      id: json['id'] as String,
      streakDays: json['streakDays'] as int? ?? 7,
      totalPagesRead: json['totalPagesRead'] as int? ?? 847,
      totalReadingMinutes: json['totalReadingMinutes'] as int? ?? 332,
      booksCompleted: json['booksCompleted'] as int? ?? 2,
      averageWpm: json['averageWpm'] as int? ?? 280,
      weeklyWpmHistory: (json['weeklyWpmHistory'] as List<dynamic>?)
              ?.map((v) => (v as num).toDouble())
              .toList() ??
          [215.0, 230.0, 248.0, 260.0, 272.0, 285.0, 295.0],
      userReadingScore: json['userReadingScore'] as int? ?? 78,
    );
  }
}
