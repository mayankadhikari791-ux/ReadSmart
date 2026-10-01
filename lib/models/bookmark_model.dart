class Bookmark {
  final String id;
  final String bookId;
  final int pageNumber;
  final String title;
  final String? snippet;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.pageNumber,
    required this.title,
    this.snippet,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'pageNumber': pageNumber,
      'title': title,
      'snippet': snippet,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      pageNumber: json['pageNumber'] as int,
      title: json['title'] as String,
      snippet: json['snippet'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
