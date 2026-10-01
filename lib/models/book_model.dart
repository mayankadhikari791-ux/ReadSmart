import 'package:flutter/material.dart';

enum BookFormat {
  ebook,
  physical,
}

enum BookStatus {
  reading,
  completed,
  saved,
  unread,
}

class Book {
  final String id;
  final String title;
  final String author;
  final int totalPages;
  int currentPage;
  final BookFormat format;
  BookStatus status;
  final String lastReadTime;
  final List<Color> coverGradient;
  final double rating;
  final String? excerpt;
  /// Absolute path to a PDF file on disk (null for non-PDF books)
  final String? filePath;
  final DateTime? lastOpenedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.totalPages,
    required this.currentPage,
    this.format = BookFormat.ebook,
    this.status = BookStatus.reading,
    this.lastReadTime = 'Just now',
    required this.coverGradient,
    this.rating = 4.8,
    this.excerpt,
    this.filePath,
    this.lastOpenedAt,
  });

  bool get isPdf => filePath != null && filePath!.toLowerCase().endsWith('.pdf');

  bool get isWantToRead => status == BookStatus.saved;
  bool get isReading => status == BookStatus.reading;
  bool get isCompleted => status == BookStatus.completed;
  bool get isUnread => status == BookStatus.unread;
  bool get isPhysical => format == BookFormat.physical;
  bool get isEbook => format == BookFormat.ebook;

  String get formattedBookType => isPhysical ? 'Physical Book' : 'Uploaded E-book';

  String get formattedStatus {
    switch (status) {
      case BookStatus.reading:
        return 'Currently Reading';
      case BookStatus.completed:
        return 'Completed';
      case BookStatus.saved:
        return 'Want to Read';
      case BookStatus.unread:
        return 'Not Started';
    }
  }

  String get formattedLastOpened {
    if (lastOpenedAt == null) return lastReadTime;
    final now = DateTime.now();
    final diff = now.difference(lastOpenedAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastOpenedAt!.day}/${lastOpenedAt!.month}/${lastOpenedAt!.year}';
  }

  double get progressPercentage =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;

  int get progressPercentInt => (progressPercentage * 100).toInt();

  int get remainingPages => (totalPages - currentPage).clamp(0, totalPages);

  String get estimatedDaysRemaining {
    if (remainingPages == 0) return 'Completed';
    final estDays = (remainingPages / 25).ceil();
    return '$estDays days';
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
    BookFormat? format,
    BookStatus? status,
    String? lastReadTime,
    List<Color>? coverGradient,
    double? rating,
    String? excerpt,
    String? filePath,
    DateTime? lastOpenedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      format: format ?? this.format,
      status: status ?? this.status,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      coverGradient: coverGradient ?? this.coverGradient,
      rating: rating ?? this.rating,
      excerpt: excerpt ?? this.excerpt,
      filePath: filePath ?? this.filePath,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'format': format.name,
      'status': status.name,
      'lastReadTime': lastReadTime,
      'coverGradient': coverGradient.map((c) => c.value).toList(),
      'rating': rating,
      'excerpt': excerpt,
      'filePath': filePath,
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final gradientValues = (json['coverGradient'] as List<dynamic>?)
            ?.map((val) => Color(val as int))
            .toList() ??
        const [Color(0xFFE8A020), Color(0xFF78350F)];

    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
      format: BookFormat.values.firstWhere(
        (f) => f.name == json['format'],
        orElse: () => BookFormat.ebook,
      ),
      status: BookStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BookStatus.reading,
      ),
      lastReadTime: json['lastReadTime'] as String? ?? 'Recently',
      coverGradient: gradientValues,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      excerpt: json['excerpt'] as String?,
      filePath: json['filePath'] as String?,
      lastOpenedAt: json['lastOpenedAt'] != null
          ? DateTime.tryParse(json['lastOpenedAt'] as String)
          : null,
    );
  }
}
