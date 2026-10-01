import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/models/book_model.dart';
import 'package:read_smart/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 12 Complete ReadSmart Library Tests', () {
    late AppState appState;

    setUp(() async {
      appState = AppState();
      await appState.initialize();
    });

    test('Book model extensions: lastOpenedAt, helpers, and copyWith', () {
      final now = DateTime.now();
      final book = Book(
        id: 'test_bk',
        title: 'Designing Data-Intensive Applications',
        author: 'Martin Kleppmann',
        totalPages: 616,
        currentPage: 154,
        format: BookFormat.ebook,
        status: BookStatus.reading,
        coverGradient: const [Color(0xFF2563EB), Color(0xFF1E3A8A)],
        lastOpenedAt: now.subtract(const Duration(minutes: 15)),
      );

      expect(book.isReading, isTrue);
      expect(book.isCompleted, isFalse);
      expect(book.isWantToRead, isFalse);
      expect(book.isEbook, isTrue);
      expect(book.isPhysical, isFalse);
      expect(book.formattedBookType, equals('Uploaded E-book'));
      expect(book.formattedStatus, equals('Currently Reading'));
      expect(book.formattedLastOpened, equals('15m ago'));

      // Test copyWith
      final updated = book.copyWith(
        status: BookStatus.completed,
        currentPage: 616,
      );
      expect(updated.isCompleted, isTrue);
      expect(updated.isReading, isFalse);
      expect(updated.currentPage, equals(616));
      expect(updated.formattedStatus, equals('Completed'));

      // Test JSON roundtrip
      final json = book.toJson();
      final fromJson = Book.fromJson(json);
      expect(fromJson.id, equals(book.id));
      expect(fromJson.title, equals(book.title));
      expect(fromJson.lastOpenedAt, isNotNull);
      expect(fromJson.format, equals(BookFormat.ebook));
    });

    test('AppState separates library books into 6 distinct sections', () async {
      // Ensure we have books across each status
      if (appState.wantToReadBooks.isEmpty) {
        await appState.markBookStatus(appState.books.last.id, BookStatus.saved);
      }
      if (appState.currentlyReadingBooks.isEmpty) {
        await appState.markBookStatus(appState.books.first.id, BookStatus.reading);
      }

      // 1. Currently Reading
      final reading = appState.currentlyReadingBooks;
      expect(reading, isNotEmpty);
      for (final b in reading) {
        expect(b.isReading, isTrue);
      }

      // 2. Want to Read
      final wantToRead = appState.wantToReadBooks;
      expect(wantToRead, isNotEmpty);
      for (final b in wantToRead) {
        expect(b.isWantToRead, isTrue);
      }

      // 3. Completed
      final completed = appState.completedBooks;
      expect(completed, isNotEmpty);
      for (final b in completed) {
        expect(b.isCompleted, isTrue);
      }

      // 4. Uploaded E-books
      final ebooks = appState.uploadedEbooks;
      expect(ebooks, isNotEmpty);
      for (final b in ebooks) {
        expect(b.isEbook, isTrue);
      }

      // 5. Physical Books
      final physical = appState.physicalLibraryBooks;
      expect(physical, isNotEmpty);
      for (final b in physical) {
        expect(b.isPhysical, isTrue);
      }

      // 6. Recently Opened (sorted by lastOpenedAt descending)
      final recent = appState.recentlyOpenedBooks;
      expect(recent, isNotEmpty);
      if (recent.length >= 2) {
        final firstTime = recent[0].lastOpenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondTime = recent[1].lastOpenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        expect(firstTime.isAfter(secondTime) || firstTime.isAtSameMomentAs(secondTime), isTrue);
      }
    });

    test('Book lifecycle mutations: markBookStatus and progress auto-complete', () async {
      final book = appState.books.first;
      final bookId = book.id;

      // Mark completed
      await appState.markBookStatus(bookId, BookStatus.completed);
      final updatedCompleted = appState.books.firstWhere((b) => b.id == bookId);
      expect(updatedCompleted.status, equals(BookStatus.completed));
      expect(updatedCompleted.currentPage, equals(updatedCompleted.totalPages));

      // Mark back to reading
      await appState.markBookStatus(bookId, BookStatus.reading);
      final updatedReading = appState.books.firstWhere((b) => b.id == bookId);
      expect(updatedReading.status, equals(BookStatus.reading));
    });

    test('Bookmark wishlist: toggleBookWantToRead switches between saved and reading', () async {
      final book = appState.books.first;
      final bookId = book.id;

      // Toggle to saved (Want to Read)
      await appState.toggleBookWantToRead(bookId);
      var current = appState.books.firstWhere((b) => b.id == bookId);
      expect(current.isWantToRead, isTrue);

      // Toggle back
      await appState.toggleBookWantToRead(bookId);
      current = appState.books.firstWhere((b) => b.id == bookId);
      expect(current.isWantToRead, isFalse);
    });

    test('touchBookOpened updates lastOpenedAt timestamp and brings book to top of Recently Opened', () async {
      // Find a book that is not currently the most recent
      final targetBook = appState.books.last;
      final targetId = targetBook.id;

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await appState.touchBookOpened(targetId);

      final recent = appState.recentlyOpenedBooks;
      expect(recent.first.id, equals(targetId));
    });

    test('Delete from library removes book from all queries and state', () async {
      final initialTotal = appState.books.length;
      final newBook = await appState.addPhysicalBook(
        title: 'Temporary Test Book',
        author: 'Tester',
        totalPages: 100,
        currentPage: 10,
      );

      expect(appState.books.length, equals(initialTotal + 1));
      await appState.deleteBook(newBook.id);
      expect(appState.books.length, equals(initialTotal));
      expect(appState.books.any((b) => b.id == newBook.id), isFalse);
    });
  });
}
