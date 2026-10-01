class BookNote {
  final String id;
  final String bookId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookNote({
    required this.id,
    required this.bookId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BookNote.fromJson(Map<String, dynamic> json) {
    return BookNote(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
