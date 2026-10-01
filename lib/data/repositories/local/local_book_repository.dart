import 'package:read_smart/models/book_model.dart';
import 'package:read_smart/models/reading_progress_model.dart';
import 'package:read_smart/models/bookmark_model.dart';
import '../i_book_repository.dart';
import '../../storage/i_storage_driver.dart';

class LocalBookRepository implements IBookRepository {
  final IStorageDriver _storage;

  static const String _booksKey = 'books';
  static const String _progressKey = 'reading_progress';
  static const String _bookmarksKey = 'bookmarks';

  LocalBookRepository(this._storage);

  @override
  Future<List<Book>> getAllBooks() async {
    final raw = await _storage.readList(_booksKey);
    return raw.map(Book.fromJson).toList();
  }

  @override
  Future<Book?> getBookById(String bookId) async {
    final all = await getAllBooks();
    try {
      return all.firstWhere((b) => b.id == bookId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveBook(Book book) async {
    final all = await getAllBooks();
    final index = all.indexWhere((b) => b.id == book.id);
    if (index == -1) {
      all.add(book);
    } else {
      all[index] = book;
    }
    await _storage.writeList(_booksKey, all.map((b) => b.toJson()).toList());
  }

  @override
  Future<void> deleteBook(String bookId) async {
    final all = await getAllBooks();
    all.removeWhere((b) => b.id == bookId);
    await _storage.writeList(_booksKey, all.map((b) => b.toJson()).toList());
  }

  @override
  Future<void> updateReadingProgress(ReadingProgress progress) async {
    final all = await _getAllProgress();
    final index = all.indexWhere((p) => p.bookId == progress.bookId);
    if (index == -1) {
      all.add(progress);
    } else {
      all[index] = progress;
    }
    await _storage.writeList(
        _progressKey, all.map((p) => p.toJson()).toList());
  }

  @override
  Future<ReadingProgress?> getReadingProgress(String bookId) async {
    final all = await _getAllProgress();
    try {
      return all.firstWhere((p) => p.bookId == bookId);
    } catch (_) {
      return null;
    }
  }

  Future<List<ReadingProgress>> _getAllProgress() async {
    final raw = await _storage.readList(_progressKey);
    return raw.map(ReadingProgress.fromJson).toList();
  }

  @override
  Future<List<Bookmark>> getBookmarksForBook(String bookId) async {
    final all = await _getAllBookmarks();
    return all.where((b) => b.bookId == bookId).toList();
  }

  @override
  Future<void> saveBookmark(Bookmark bookmark) async {
    final all = await _getAllBookmarks();
    final index = all.indexWhere((b) => b.id == bookmark.id);
    if (index == -1) {
      all.add(bookmark);
    } else {
      all[index] = bookmark;
    }
    await _storage.writeList(
        _bookmarksKey, all.map((b) => b.toJson()).toList());
  }

  @override
  Future<void> deleteBookmark(String bookmarkId) async {
    final all = await _getAllBookmarks();
    all.removeWhere((b) => b.id == bookmarkId);
    await _storage.writeList(
        _bookmarksKey, all.map((b) => b.toJson()).toList());
  }

  Future<List<Bookmark>> _getAllBookmarks() async {
    final raw = await _storage.readList(_bookmarksKey);
    return raw.map(Bookmark.fromJson).toList();
  }
}
