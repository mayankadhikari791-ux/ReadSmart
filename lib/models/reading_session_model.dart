class ReadingSession {
  final String id;
  final String bookId;
  final String bookTitle;
  final int durationSeconds;
  final int pagesRead;
  final int readingSpeedWpm;
  final DateTime timestamp;
  final int? startPage;
  final int? endPage;
  final String? notes;

  ReadingSession({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.durationSeconds,
    required this.pagesRead,
    required this.readingSpeedWpm,
    required this.timestamp,
    this.startPage,
    this.endPage,
    this.notes,
  });

  /// Formatted duration string e.g. "24:15" or "1:05:20"
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Transparent metric: Pages per hour
  double get pagesPerHour {
    if (durationSeconds <= 0 || pagesRead <= 0) return 0.0;
    return (pagesRead / (durationSeconds / 3600.0));
  }

  String get formattedPagesPerHour {
    if (pagesPerHour <= 0) return '0.0 pph';
    return '${pagesPerHour.toStringAsFixed(1)} pph';
  }

  /// Transparent metric: Average seconds spent per page
  double get secondsPerPage {
    if (pagesRead <= 0) return 0.0;
    return durationSeconds / pagesRead.toDouble();
  }

  /// Transparent metric: formatted time spent per page (e.g. "1m 45s" or "45s")
  String get averageTimePerPage {
    if (pagesRead <= 0 || durationSeconds <= 0) return 'N/A';
    final sec = secondsPerPage.round();
    final m = sec ~/ 60;
    final s = sec % 60;
    if (m > 0) {
      return '${m}m ${s.toString().padLeft(2, '0')}s';
    }
    return '${s}s';
  }

  /// Explainable WPM estimate based on standard ~250 words per page
  int estimatedWpm({int wordsPerPage = 250}) {
    if (durationSeconds <= 0 || pagesRead <= 0) return 0;
    final minutes = durationSeconds / 60.0;
    return ((pagesRead * wordsPerPage) / minutes).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'durationSeconds': durationSeconds,
      'pagesRead': pagesRead,
      'readingSpeedWpm': readingSpeedWpm,
      'timestamp': timestamp.toIso8601String(),
      if (startPage != null) 'startPage': startPage,
      if (endPage != null) 'endPage': endPage,
      if (notes != null) 'notes': notes,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      bookId: json['bookId'] as String? ?? 'unknown_book',
      bookTitle: json['bookTitle'] as String? ?? 'General Session',
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      pagesRead: json['pagesRead'] as int? ?? 0,
      readingSpeedWpm: json['readingSpeedWpm'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      startPage: json['startPage'] as int?,
      endPage: json['endPage'] as int?,
      notes: json['notes'] as String?,
    );
  }
}
