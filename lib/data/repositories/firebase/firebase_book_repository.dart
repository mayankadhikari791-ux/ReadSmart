import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:read_smart/models/book_model.dart';
import 'package:read_smart/models/bookmark_model.dart';
import 'package:read_smart/models/reading_progress_model.dart';
import '../i_book_repository.dart';

/// Firestore implementation of [IBookRepository].
/// Stores books and progress under: users/{uid}/books/{bookId}
class FirebaseBookRepository implements IBookRepository {
  final FirebaseFirestore _db;
  final String _uid;

  FirebaseBookRepository({required String uid, FirebaseFirestore? db})
      : _uid = uid,
        _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _booksCol =>
      _db.collection('users/$_uid/books');

  CollectionReference<Map<String, dynamic>> get _progressCol =>
      _db.collection('users/$_uid/progress');

  CollectionReference<Map<String, dynamic>> get _bookmarksCol =>
      _db.collection('users/$_uid/bookmarks');

  @override
  Future<List<Book>> getAllBooks() async {
    final snap = await _booksCol.orderBy('lastReadAt', descending: true).get();
    return snap.docs
        .map((d) => _bookFromFirestore(d.id, d.data()))
        .toList();
  }

  @override
  Future<Book?> getBookById(String bookId) async {
    final doc = await _booksCol.doc(bookId).get();
    if (!doc.exists) return null;
    return _bookFromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<void> saveBook(Book book) async {
    await _booksCol.doc(book.id).set(_bookToFirestore(book), SetOptions(merge: true));
  }

  @override
  Future<void> deleteBook(String bookId) async {
    await _booksCol.doc(bookId).delete();
  }

  @override
  Future<ReadingProgress?> getReadingProgress(String bookId) async {
    final doc = await _progressCol.doc(bookId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return ReadingProgress(
      id: 'progress_$bookId',
      bookId: data['bookId'] as String? ?? bookId,
      currentPage: data['currentPage'] as int? ?? 0,
      totalPages: data['totalPages'] as int? ?? 0,
      progressPercentage: (data['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      lastReadTimestamp: (data['lastReadTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<void> updateReadingProgress(ReadingProgress progress) async {
    await _progressCol.doc(progress.bookId).set({
      'bookId': progress.bookId,
      'currentPage': progress.currentPage,
      'totalPages': progress.totalPages,
      'progressPercentage': progress.progressPercentage,
      'lastReadTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Also update currentPage on the book document
    await _booksCol.doc(progress.bookId).set({
      'currentPage': progress.currentPage,
      'lastReadAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> saveBookmark(Bookmark bookmark) async {
    await _bookmarksCol.doc(bookmark.id).set({
      'id': bookmark.id,
      'bookId': bookmark.bookId,
      'pageNumber': bookmark.pageNumber,
      'title': bookmark.title,
      'createdAt': bookmark.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteBookmark(String bookmarkId) async {
    await _bookmarksCol.doc(bookmarkId).delete();
  }

  @override
  Future<List<Bookmark>> getBookmarksForBook(String bookId) async {
    final snap = await _bookmarksCol
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return Bookmark(
        id: data['id'] as String,
        bookId: data['bookId'] as String,
        pageNumber: data['pageNumber'] as int,
        title: data['title'] as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
      );
    }).toList();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  Book _bookFromFirestore(String id, Map<String, dynamic> data) {
    final gradientValues = (data['coverGradient'] as List<dynamic>?)
            ?.map((v) => Color(v as int))
            .toList() ??
        const [Color(0xFFE8A020), Color(0xFF78350F)];

    return Book(
      id: id,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      totalPages: data['totalPages'] as int? ?? 0,
      currentPage: data['currentPage'] as int? ?? 0,
      format: BookFormat.values.firstWhere(
        (f) => f.name == data['format'],
        orElse: () => BookFormat.ebook,
      ),
      status: BookStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => BookStatus.reading,
      ),
      lastReadTime: data['lastReadTime'] as String? ?? 'Recently',
      coverGradient: gradientValues,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.0,
      excerpt: data['excerpt'] as String?,
    );
  }

  Map<String, dynamic> _bookToFirestore(Book book) {
    return {
      'id': book.id,
      'title': book.title,
      'author': book.author,
      'totalPages': book.totalPages,
      'currentPage': book.currentPage,
      'format': book.format.name,
      'status': book.status.name,
      'lastReadTime': book.lastReadTime,
      'coverGradient': book.coverGradient.map((c) => c.value).toList(),
      'rating': book.rating,
      'excerpt': book.excerpt,
      'lastReadAt': FieldValue.serverTimestamp(),
    };
  }
}
