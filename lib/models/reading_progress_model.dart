class ReadingProgress {
  final String id;
  final String bookId;
  final int currentPage;
  final int totalPages;
  final double progressPercentage;
  final DateTime lastReadTimestamp;

  ReadingProgress({
    required this.id,
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
    required this.lastReadTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'progressPercentage': progressPercentage,
      'lastReadTimestamp': lastReadTimestamp.toIso8601String(),
    };
  }

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      lastReadTimestamp: DateTime.parse(json['lastReadTimestamp'] as String),
    );
  }
}
