import '../../models/book_model.dart';
import '../../models/reading_progress_model.dart';
import '../../models/bookmark_model.dart';

abstract class IBookRepository {
  Future<List<Book>> getAllBooks();
  Future<Book?> getBookById(String bookId);
  Future<void> saveBook(Book book);
  Future<void> deleteBook(String bookId);
  Future<void> updateReadingProgress(ReadingProgress progress);
  Future<ReadingProgress?> getReadingProgress(String bookId);
  Future<List<Bookmark>> getBookmarksForBook(String bookId);
  Future<void> saveBookmark(Bookmark bookmark);
  Future<void> deleteBookmark(String bookmarkId);
}
