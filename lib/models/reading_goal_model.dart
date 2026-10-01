class ReadingGoal {
  final String id;
  final int dailyMinutesTarget;
  final int annualBooksTarget;
  final int currentDailyMinutes;
  final int completedBooksThisYear;

  ReadingGoal({
    required this.id,
    this.dailyMinutesTarget = 30,
    this.annualBooksTarget = 24,
    this.currentDailyMinutes = 45,
    this.completedBooksThisYear = 12,
  });

  double get dailyGoalProgress =>
      (currentDailyMinutes / dailyMinutesTarget).clamp(0.0, 1.0);

  double get annualGoalProgress =>
      (completedBooksThisYear / annualBooksTarget).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyMinutesTarget': dailyMinutesTarget,
      'annualBooksTarget': annualBooksTarget,
      'currentDailyMinutes': currentDailyMinutes,
      'completedBooksThisYear': completedBooksThisYear,
    };
  }

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    return ReadingGoal(
      id: json['id'] as String,
      dailyMinutesTarget: json['dailyMinutesTarget'] as int? ?? 30,
      annualBooksTarget: json['annualBooksTarget'] as int? ?? 24,
      currentDailyMinutes: json['currentDailyMinutes'] as int? ?? 45,
      completedBooksThisYear: json['completedBooksThisYear'] as int? ?? 12,
    );
  }
}
