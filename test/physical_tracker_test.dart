import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/models/book_model.dart';
import 'package:read_smart/models/reading_session_model.dart';
import 'package:read_smart/state/app_state.dart';

void main() {
  group('ReadingSession Model Calculations', () {
    test('Calculates transparent Pages Per Hour (PPH) correctly', () {
      // 30 pages read in 3600 seconds (1 hour) = 30 PPH
      final session1 = ReadingSession(
        id: 'test_1',
        bookId: 'book_1',
        bookTitle: 'Test Book',
        durationSeconds: 3600,
        pagesRead: 30,
        readingSpeedWpm: 125,
        timestamp: DateTime.now(),
      );
      expect(session1.pagesPerHour, equals(30.0));
      expect(session1.formattedPagesPerHour, equals('30.0 pph'));

      // 15 pages in 1800 seconds (30 min) = 30 PPH
      final session2 = ReadingSession(
        id: 'test_2',
        bookId: 'book_1',
        bookTitle: 'Test Book',
        durationSeconds: 1800,
        pagesRead: 15,
        readingSpeedWpm: 125,
        timestamp: DateTime.now(),
      );
      expect(session2.pagesPerHour, equals(30.0));
    });

    test('Calculates transparent seconds per page and formatted pace', () {
      // 10 pages in 1200 seconds = 120 sec/page = 2m 00s
      final session = ReadingSession(
        id: 'test_pace',
        bookId: 'book_1',
        bookTitle: 'Test Book',
        durationSeconds: 1200,
        pagesRead: 10,
        readingSpeedWpm: 125,
        timestamp: DateTime.now(),
      );
      expect(session.secondsPerPage, equals(120.0));
      expect(session.averageTimePerPage, equals('2m 00s'));
    });

    test('Provides explainable WPM based on ~250 words per page standard', () {
      // 10 pages * 250 words = 2500 words in 10 minutes = 250 WPM
      final session = ReadingSession(
        id: 'test_wpm',
        bookId: 'book_1',
        bookTitle: 'Test Book',
        durationSeconds: 600, // 10 minutes
        pagesRead: 10,
        readingSpeedWpm: 250,
        timestamp: DateTime.now(),
      );
      expect(session.estimatedWpm(wordsPerPage: 250), equals(250));
    });
  });

  group('AppState Physical Book Reading Tracker Flow', () {
    late AppState appState;

    setUp(() async {
      appState = AppState();
      await appState.initialize();
    });

    test('Can add a new physical book and set it as active session book', () async {
      final initialCount = appState.physicalBooks.length;
      final book = await appState.addPhysicalBook(
        title: 'Clean Architecture',
        author: 'Robert C. Martin',
        totalPages: 432,
        currentPage: 50,
      );

      expect(book.format, equals(BookFormat.physical));
      expect(book.title, equals('Clean Architecture'));
      expect(book.currentPage, equals(50));
      expect(book.totalPages, equals(432));
      expect(appState.physicalBooks.length, equals(initialCount + 1));
      expect(appState.sessionBookId, equals(book.id));
      expect(appState.sessionStartPage, equals(50));
    });

    test('Session lifecycle: start, pause, resume, and complete', () async {
      final book = await appState.addPhysicalBook(
        title: 'Dune',
        author: 'Frank Herbert',
        totalPages: 600,
        currentPage: 100,
      );

      appState.startPhysicalSession(bookId: book.id);
      expect(appState.isSessionActive, isTrue);
      expect(appState.isSessionPaused, isFalse);

      appState.pausePhysicalSession();
      expect(appState.isSessionActive, isFalse);
      expect(appState.isSessionPaused, isTrue);

      appState.resumePhysicalSession();
      expect(appState.isSessionActive, isTrue);
      expect(appState.isSessionPaused, isFalse);

      // Record completion of 25 pages
      final recorded = await appState.completeAndSaveSession(
        bookId: book.id,
        pagesRead: 25,
        startPage: 100,
        endPage: 125,
        notes: 'Great chapter on Arrakis ecology.',
      );

      expect(recorded.pagesRead, equals(25));
      expect(recorded.startPage, equals(100));
      expect(recorded.endPage, equals(125));
      expect(appState.isSessionActive, isFalse);

      // Verify book progress was updated
      final updatedBook = appState.books.firstWhere((b) => b.id == book.id);
      expect(updatedBook.currentPage, equals(125));

      // Verify session exists in history
      expect(appState.sessionsForBook(book.id).isNotEmpty, isTrue);
      expect(appState.sessionsForBook(book.id).first.id, equals(recorded.id));
    });

    test('Calculates remaining time and estimated completion date correctly', () async {
      final book = await appState.addPhysicalBook(
        title: 'Project Hail Mary',
        author: 'Andy Weir',
        totalPages: 400,
        currentPage: 100,
      );

      final remaining = appState.getEstRemainingTimeForBook(book);
      expect(remaining, isNotEmpty);
      expect(remaining.contains('h') || remaining.contains('m'), isTrue);

      final finishDate = appState.getEstCompletionDateForBook(book);
      expect(finishDate, isNotEmpty);
      expect(finishDate.contains('days'), isTrue);
    });
  });
}

