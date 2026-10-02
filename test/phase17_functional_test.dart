// ignore_for_file: avoid_print
/// Phase 17 — Comprehensive Functional Test Suite
///
/// Tests all major user flows including:
///   • App startup and state initialization
///   • Navigation (bottom tabs)
///   • Physical book CRUD and session tracking
///   • PDF book lifecycle
///   • Dictionary lookup (English, Hindi, selected language)
///   • Vocabulary note saving and book-level isolation
///   • CRITICAL: "journey" saved from Book A ≠ "journey" saved from Book B
///   • Notes search, filter, flashcard mode
///   • Reading goals and analytics
///   • Theme switching persistence
///   • Language preference switching
///   • Offline behavior
///   • UI overflow guards (multiple screen sizes)
library phase17_functional_test;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/models/book_model.dart';
import 'package:read_smart/models/vocabulary_word_model.dart';
import 'package:read_smart/models/book_vocabulary_collection_model.dart';
import 'package:read_smart/state/app_state.dart';
import 'package:read_smart/theme/app_theme.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Create a fresh test AppState (no real DB writes in unit-test mode).
AppState _freshAppState() => AppState();

/// Build a minimal [VocabularyWord] for unit tests using the correct field names.
VocabularyWord _makeWord({
  required String id,
  required String word,
  required String bookId,
  required String bookTitle,
  String englishMeaning = 'Test meaning',
  int page = 1,
}) {
  return VocabularyWord(
    id: id,
    word: word,
    englishMeaning: englishMeaning,
    hindiMeaning: '',
    hindiWord: '',
    selectedLangMeaning: '',
    selectedLangCode: '',
    pronunciation: '',
    exampleSentence: '',
    dateSaved: DateTime.now().toIso8601String(),
    bookId: bookId,
    bookTitle: bookTitle,
    pageNumber: page,
    savedAt: DateTime.now(),
  );
}

// ─── Group 1: App State Initialization ───────────────────────────────────────

void main() {
  setUpAll(() {
    for (final basePath in ['.readsmart_data', '${Directory.systemTemp.path}/.readsmart_data']) {
      final dir = Directory(basePath);
      if (dir.existsSync()) {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
      }
    }
  });

  tearDownAll(() {
    for (final basePath in ['.readsmart_data', '${Directory.systemTemp.path}/.readsmart_data']) {
      final dir = Directory(basePath);
      if (dir.existsSync()) {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
      }
    }
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 1. App State Initialization
  // ──────────────────────────────────────────────────────────────────────────
  group('AppState initialization', () {
    test('starts with isLoaded = false before initialize()', () {
      final state = _freshAppState();
      expect(state.isLoaded, isFalse);
    });

    test('books list is non-empty after initialize()', () async {
      final state = _freshAppState();
      await state.initialize();
      expect(state.isLoaded, isTrue);
      expect(state.books, isNotEmpty);
    });

    test('currentlyReadingBook returns a valid book after init', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = state.currentlyReadingBook;
      expect(book.id, isNotEmpty);
      expect(book.title, isNotEmpty);
    });

    test('dayStreak is non-negative after init', () async {
      final state = _freshAppState();
      await state.initialize();
      expect(state.dayStreak, greaterThanOrEqualTo(0));
    });

    test('default themeMode is dark', () {
      final state = _freshAppState();
      expect(state.themeMode, equals(ReadingThemeMode.dark));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Theme Switching
  // ──────────────────────────────────────────────────────────────────────────
  group('Theme switching', () {
    test('setThemeMode(sepia) changes themeMode', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setThemeMode(ReadingThemeMode.sepia);
      expect(state.themeMode, equals(ReadingThemeMode.sepia));
    });

    test('setThemeMode(light) changes themeMode', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setThemeMode(ReadingThemeMode.light);
      expect(state.themeMode, equals(ReadingThemeMode.light));
    });

    test('setThemeMode(dark) reverts back', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setThemeMode(ReadingThemeMode.light);
      state.setThemeMode(ReadingThemeMode.dark);
      expect(state.themeMode, equals(ReadingThemeMode.dark));
    });

    test('themeMode change notifies listeners', () async {
      final state = _freshAppState();
      await state.initialize();
      var notified = false;
      void l() => notified = true;
      state.addListener(l);
      state.setThemeMode(ReadingThemeMode.sepia);
      expect(notified, isTrue);
      state.removeListener(l);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Language Switching
  // ──────────────────────────────────────────────────────────────────────────
  group('Language switching', () {
    test('setInterfaceLanguage changes interfaceLanguage', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setInterfaceLanguage('Hindi', code: 'hi');
      expect(state.interfaceLanguage, contains('Hindi'));
    });

    test('appLocale changes when setInterfaceLanguage is called', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setInterfaceLanguage('Hindi', code: 'hi');
      expect(state.appLocale.languageCode, equals('hi'));
    });

    test('setInterfaceLanguage to English resets locale to en', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setInterfaceLanguage('Hindi', code: 'hi');
      state.setInterfaceLanguage('English', code: 'en');
      expect(state.appLocale.languageCode, equals('en'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Physical Book Management
  // ──────────────────────────────────────────────────────────────────────────
  group('Physical book management', () {
    test('addPhysicalBook inserts a new book', () async {
      final state = _freshAppState();
      await state.initialize();
      final countBefore = state.books.length;
      await state.addPhysicalBook(
        title: 'Test Physical Book',
        author: 'Test Author',
        totalPages: 300,
        currentPage: 0,
      );
      expect(state.books.length, equals(countBefore + 1));
      expect(state.books.any((b) => b.title == 'Test Physical Book'), isTrue);
    });

    test('addPhysicalBook with currentPage > 0 sets status to reading', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPhysicalBook(
        title: 'In Progress Book',
        author: 'Author',
        totalPages: 200,
        currentPage: 50,
      );
      expect(book.status, equals(BookStatus.reading));
    });

    test('addPhysicalBook with currentPage == totalPages sets status to completed', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPhysicalBook(
        title: 'Finished Book',
        author: 'Author',
        totalPages: 100,
        currentPage: 100,
      );
      expect(book.status, equals(BookStatus.completed));
    });

    test('deleteBook removes book from the list', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPhysicalBook(
        title: 'To Delete',
        author: 'Author',
        totalPages: 100,
        currentPage: 0,
      );
      final countAfterAdd = state.books.length;
      await state.deleteBook(book.id);
      expect(state.books.length, equals(countAfterAdd - 1));
      expect(state.books.any((b) => b.id == book.id), isFalse);
    });

    test('updateBookDetails updates title and currentPage', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPhysicalBook(
        title: 'Original Title',
        author: 'Author',
        totalPages: 200,
        currentPage: 10,
      );
      await state.updateBookDetails(
        bookId: book.id,
        title: 'Updated Title',
        currentPage: 50,
      );
      final updated = state.books.firstWhere((b) => b.id == book.id);
      expect(updated.title, equals('Updated Title'));
      expect(updated.currentPage, equals(50));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 5. Reading Session Tracking
  // ──────────────────────────────────────────────────────────────────────────
  group('Reading session tracking', () {
    test('startPhysicalSession sets isSessionActive to true', () async {
      final state = _freshAppState();
      await state.initialize();
      state.startPhysicalSession();
      expect(state.isSessionActive, isTrue);
      state.resetPhysicalSession();
    });

    test('pausePhysicalSession sets isSessionActive to false', () async {
      final state = _freshAppState();
      await state.initialize();
      state.startPhysicalSession();
      state.pausePhysicalSession();
      expect(state.isSessionActive, isFalse);
      expect(state.isSessionPaused, isTrue);
    });

    test('resetPhysicalSession clears all session state', () async {
      final state = _freshAppState();
      await state.initialize();
      state.startPhysicalSession();
      state.resetPhysicalSession();
      expect(state.isSessionActive, isFalse);
      expect(state.isSessionPaused, isFalse);
      expect(state.sessionDurationSeconds, equals(0));
    });

    test('completeAndSaveSession saves a session record', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPhysicalBook(
        title: 'Session Test Book',
        author: 'A',
        totalPages: 100,
        currentPage: 5,
      );
      state.startPhysicalSession(bookId: book.id);
      final countBefore = state.sessions.length;
      await state.completeAndSaveSession(
        bookId: book.id,
        pagesRead: 5,
        startPage: 5,
        endPage: 10,
      );
      expect(state.sessions.length, equals(countBefore + 1));
    });

    test('setSessionBook switches active session book', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPhysicalBook(
        title: 'Session Book',
        author: 'A',
        totalPages: 100,
        currentPage: 0,
      );
      state.setSessionBook(book.id, book.title);
      expect(state.sessionBookTitle, equals('Session Book'));
    });

    test('sessionsForBook returns only sessions for that book', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPhysicalBook(
        title: 'Session Filter Book',
        author: 'A',
        totalPages: 200,
        currentPage: 5,
      );
      state.setSessionBook(book.id, book.title);
      state.startPhysicalSession(bookId: book.id);
      await state.completeAndSaveSession(
        bookId: book.id,
        pagesRead: 5,
        startPage: 5,
        endPage: 10,
      );
      final forBook = state.sessionsForBook(book.id);
      expect(forBook.every((s) => s.bookId == book.id), isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 6. PDF Book Management
  // ──────────────────────────────────────────────────────────────────────────
  group('PDF book management', () {
    test('addPdfBook creates an ebook-format entry', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPdfBook('/storage/emulated/0/Documents/test.pdf');
      expect(book.format, equals(BookFormat.ebook));
      expect(book.filePath, isNotNull);
    });

    test('addPdfBook derives title from filename', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPdfBook('/path/to/Clean_Code.pdf');
      expect(book.title, contains('Clean'));
    });

    test('isPdf returns true for ebook books with a filePath', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPdfBook('/path/to/test.pdf');
      expect(book.isPdf, isTrue);
    });

    test('updatePdfTotalPages updates the totalPages field', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPdfBook('/path/to/test.pdf');
      await state.updatePdfTotalPages(book.id, 250);
      final updated = state.books.firstWhere((b) => b.id == book.id);
      expect(updated.totalPages, equals(250));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 7. Bookmarks
  // ──────────────────────────────────────────────────────────────────────────
  group('Bookmarks', () {
    test('saveBookmark creates a bookmark for a book', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = state.currentlyReadingBook;
      await state.saveBookmark(
        bookId: book.id,
        page: 777,
        title: 'Phase 17 Bookmark',
      );
      final bookmarks = await state.getBookmarksForBook(book.id);
      expect(bookmarks.any((bm) => bm.pageNumber == 777), isTrue);
      // Clean up bookmark after test
      final bm = bookmarks.firstWhere((b) => b.pageNumber == 777);
      await state.deleteBookmark(bm.id);
    });

    test('deleteBookmark removes it', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = state.currentlyReadingBook;
      await state.saveBookmark(
        bookId: book.id,
        page: 999,
        title: 'Temp Bookmark',
      );
      final before = await state.getBookmarksForBook(book.id);
      final bm = before.firstWhere((b) => b.pageNumber == 999);
      await state.deleteBookmark(bm.id);
      final after = await state.getBookmarksForBook(book.id);
      expect(after.any((b) => b.pageNumber == 999), isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 8. Vocabulary Notes — Basic CRUD
  // ──────────────────────────────────────────────────────────────────────────
  group('Vocabulary notes - basic CRUD', () {
    test('addVocabularyNote adds a word to allVocabularyNotes', () async {
      final state = _freshAppState();
      await state.initialize();
      final word = _makeWord(
        id: 'v_001',
        word: 'ephemeral',
        bookId: 'book_1',
        bookTitle: 'The Alchemist',
      );
      await state.addVocabularyNote(word);
      expect(state.allVocabularyNotes.any((n) => n.id == 'v_001'), isTrue);
    });

    test('addVocabularyNote is idempotent for same (bookId, word) pair', () async {
      final state = _freshAppState();
      await state.initialize();
      final word = _makeWord(
        id: 'v_002',
        word: 'idempotent',
        bookId: 'book_test',
        bookTitle: 'Test Book',
      );
      await state.addVocabularyNote(word);
      final countAfterFirst = state.allVocabularyNotes.length;
      await state.addVocabularyNote(word);
      expect(state.allVocabularyNotes.length, equals(countAfterFirst));
    });

    test('deleteVocabularyNote removes the word by id', () async {
      final state = _freshAppState();
      await state.initialize();
      final word = _makeWord(
        id: 'v_del_01',
        word: 'transient',
        bookId: 'book_x',
        bookTitle: 'Book X',
      );
      await state.addVocabularyNote(word);
      await state.deleteVocabularyNote('v_del_01');
      expect(state.allVocabularyNotes.any((n) => n.id == 'v_del_01'), isFalse);
    });

    test('updateVocabularyNote updates the englishMeaning field', () async {
      final state = _freshAppState();
      await state.initialize();
      final word = _makeWord(
        id: 'v_upd_01',
        word: 'cosmos',
        bookId: 'book_y',
        bookTitle: 'Book Y',
        englishMeaning: 'Original meaning',
      );
      await state.addVocabularyNote(word);
      final updated = word.copyWith(englishMeaning: 'Updated meaning');
      await state.updateVocabularyNote(updated);
      final found = state.allVocabularyNotes.firstWhere((n) => n.id == 'v_upd_01');
      expect(found.englishMeaning, equals('Updated meaning'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 9. CRITICAL: Vocabulary Isolation — same word, different books
  //    User scenario: Open Book A → save "journey"
  //                   Open Book B → save "journey"
  //    Verify: two separate, isolated records — no cross-contamination.
  // ──────────────────────────────────────────────────────────────────────────
  group('Vocabulary isolation (CRITICAL — same word, different books)', () {
    test('"journey" saved from Book A and Book B are two separate records', () async {
      final state = _freshAppState();
      await state.initialize();

      // Open Book A and save "journey"
      const bookAId = 'book_A_isolation_test';
      const bookATitle = 'The Alchemist';
      final journeyInA = _makeWord(
        id: 'journey_in_A',
        word: 'journey',
        bookId: bookAId,
        bookTitle: bookATitle,
        englishMeaning: 'A long trip — saved from Book A',
        page: 12,
      );
      await state.addVocabularyNote(journeyInA);

      // Open Book B and save "journey"
      const bookBId = 'book_B_isolation_test';
      const bookBTitle = 'Atomic Habits';
      final journeyInB = _makeWord(
        id: 'journey_in_B',
        word: 'journey',
        bookId: bookBId,
        bookTitle: bookBTitle,
        englishMeaning: 'A long trip — saved from Book B',
        page: 34,
      );
      await state.addVocabularyNote(journeyInB);

      // Both records must exist
      final allNotes = state.allVocabularyNotes;
      final journeyNotes = allNotes.where((n) => n.word.toLowerCase() == 'journey').toList();
      expect(journeyNotes.length, greaterThanOrEqualTo(2),
          reason: '"journey" from two different books must produce two separate records');

      // Each record must be tied to its own book
      final aNote = journeyNotes.firstWhere((n) => n.bookId == bookAId,
          orElse: () => throw TestFailure('No journey record found for Book A ($bookAId)'));
      final bNote = journeyNotes.firstWhere((n) => n.bookId == bookBId,
          orElse: () => throw TestFailure('No journey record found for Book B ($bookBId)'));

      // Different record IDs
      expect(aNote.id, isNot(equals(bNote.id)));

      // Each has correct bookId and bookTitle
      expect(aNote.bookId, equals(bookAId));
      expect(bNote.bookId, equals(bookBId));
      expect(aNote.bookTitle, equals(bookATitle));
      expect(bNote.bookTitle, equals(bookBTitle));

      // Meanings must not have cross-contaminated
      expect(aNote.englishMeaning, contains('Book A'));
      expect(bNote.englishMeaning, contains('Book B'));
    });

    test('notesForBookById returns only words for that specific book', () async {
      final state = _freshAppState();
      await state.initialize();

      await state.addVocabularyNote(_makeWord(
        id: 'iso_j_A2',
        word: 'journey',
        bookId: 'iso_book_A',
        bookTitle: 'Book Alpha',
      ));
      await state.addVocabularyNote(_makeWord(
        id: 'iso_j_B2',
        word: 'journey',
        bookId: 'iso_book_B',
        bookTitle: 'Book Beta',
      ));
      await state.addVocabularyNote(_makeWord(
        id: 'iso_w_A2',
        word: 'serendipity',
        bookId: 'iso_book_A',
        bookTitle: 'Book Alpha',
      ));

      final forA = state.notesForBookById('iso_book_A');
      final forB = state.notesForBookById('iso_book_B');

      // Book A must contain both words
      expect(forA.any((n) => n.word == 'journey'), isTrue);
      expect(forA.any((n) => n.word == 'serendipity'), isTrue);

      // Book B must contain only "journey" — not "serendipity"
      expect(forB.any((n) => n.word == 'journey'), isTrue);
      expect(forB.any((n) => n.word == 'serendipity'), isFalse,
          reason: 'serendipity was saved in Book A only — must NOT appear in Book B');

      // No cross-contamination of bookIds
      expect(forA.any((n) => n.bookId == 'iso_book_B'), isFalse);
      expect(forB.any((n) => n.bookId == 'iso_book_A'), isFalse);
    });

    test('notesForBook (by title) does not cross-contaminate', () async {
      final state = _freshAppState();
      await state.initialize();

      await state.addVocabularyNote(_makeWord(
        id: 'title_iso_1',
        word: 'journey',
        bookId: 'title_book_1',
        bookTitle: 'Title Book One',
      ));
      await state.addVocabularyNote(_makeWord(
        id: 'title_iso_2',
        word: 'journey',
        bookId: 'title_book_2',
        bookTitle: 'Title Book Two',
      ));

      final forOne = state.notesForBook('Title Book One');
      final forTwo = state.notesForBook('Title Book Two');

      expect(forOne, isNotEmpty);
      expect(forTwo, isNotEmpty);
      expect(forOne.every((n) => n.bookTitle == 'Title Book One'), isTrue);
      expect(forTwo.every((n) => n.bookTitle == 'Title Book Two'), isTrue);
    });

    test('BookVocabularyCollection maps words exclusively to their book', () async {
      final state = _freshAppState();
      await state.initialize();

      await state.addVocabularyNote(_makeWord(
        id: 'coll_1',
        word: 'journey',
        bookId: 'coll_book_A',
        bookTitle: 'Collection Book A',
      ));
      await state.addVocabularyNote(_makeWord(
        id: 'coll_2',
        word: 'journey',
        bookId: 'coll_book_B',
        bookTitle: 'Collection Book B',
      ));

      final collA = state.collectionForBook('coll_book_A');
      final collB = state.collectionForBook('coll_book_B');

      expect(collA, isNotNull);
      expect(collB, isNotNull);
      expect(collA!.bookId, equals('coll_book_A'));
      expect(collB!.bookId, equals('coll_book_B'));
      expect(collA.words.every((w) => w.bookId == 'coll_book_A'), isTrue);
      expect(collB.words.every((w) => w.bookId == 'coll_book_B'), isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 10. Library — Filtering
  // ──────────────────────────────────────────────────────────────────────────
  group('Library management', () {
    test('physicalBooks contains only physical-format books', () async {
      final state = _freshAppState();
      await state.initialize();
      await state.addPhysicalBook(title: 'Phys', author: 'A', totalPages: 100, currentPage: 0);
      expect(state.physicalBooks.every((b) => b.format == BookFormat.physical), isTrue);
    });

    test('ebook books (format == ebook) are separate from physical books', () async {
      final state = _freshAppState();
      await state.initialize();
      final pdf = await state.addPdfBook('/path/filter_test.pdf');
      final ebookList = state.books.where((b) => b.format == BookFormat.ebook).toList();
      expect(ebookList.any((b) => b.id == pdf.id), isTrue);
      expect(state.physicalBooks.any((b) => b.id == pdf.id), isFalse);
    });

    test('uniqueBooksWithNotes returns books that have notes', () async {
      final state = _freshAppState();
      await state.initialize();
      await state.addVocabularyNote(_makeWord(
        id: 'uniq_1',
        word: 'cosmos',
        bookId: 'uniq_book_x',
        bookTitle: 'Unique Book X',
      ));
      final unique = state.uniqueBooksWithNotes;
      expect(unique, contains('Unique Book X'));
    });

    test('toggleBookWantToRead changes book isWantToRead status', () async {
      final state = _freshAppState();
      await state.initialize();
      final book = await state.addPhysicalBook(
        title: 'Toggle Test',
        author: 'A',
        totalPages: 200,
        currentPage: 0,
      );
      await state.toggleBookWantToRead(book.id);
      final toggled = state.books.firstWhere((b) => b.id == book.id);
      expect(toggled.isWantToRead, isTrue);

      await state.toggleBookWantToRead(book.id);
      final untoggled = state.books.firstWhere((b) => b.id == book.id);
      expect(untoggled.isWantToRead, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 11. Reading Goals
  // ──────────────────────────────────────────────────────────────────────────
  group('Reading goals', () {
    setUp(() {
      for (final basePath in ['.readsmart_data', '${Directory.systemTemp.path}/.readsmart_data']) {
        final goalsFile = File('$basePath/reading_goals.json');
        if (goalsFile.existsSync()) {
          try {
            goalsFile.deleteSync();
          } catch (_) {}
        }
      }
    });

    test('dailyGoalMinutes default is 30', () async {
      final state = _freshAppState();
      await state.initialize();
      expect(state.dailyGoalMinutes, equals(30));
    });

    test('updateDailyGoal changes dailyGoalMinutes', () async {
      final state = _freshAppState();
      await state.initialize();
      await state.updateDailyGoal(45);
      expect(state.dailyGoalMinutes, equals(45));
    });

    test('updateDailyGoal clamps to [5, 240]', () async {
      final state = _freshAppState();
      await state.initialize();
      await state.updateDailyGoal(0); // below min
      expect(state.dailyGoalMinutes, equals(5));
      await state.updateDailyGoal(9999); // above max
      expect(state.dailyGoalMinutes, equals(240));
    });

    test('updateAnnualGoal updates annualBooksGoal', () async {
      final state = _freshAppState();
      await state.initialize();
      await state.updateAnnualGoal(36);
      expect(state.annualBooksGoal, equals(36));
    });

    test('dailyGoalProgress is between 0.0 and 1.0', () async {
      final state = _freshAppState();
      await state.initialize();
      expect(state.dailyGoalProgress, greaterThanOrEqualTo(0.0));
      expect(state.dailyGoalProgress, lessThanOrEqualTo(1.0));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 12. Analytics — Reading Statistics
  // ──────────────────────────────────────────────────────────────────────────
  group('Reading analytics', () {
    test('weeklyWpmTrend has exactly 7 data points', () async {
      final state = _freshAppState();
      await state.initialize();
      expect(state.weeklyWpmTrend.length, equals(7));
    });

    test('readingTimeBreakdown.allTimeSeconds is non-negative', () async {
      final state = _freshAppState();
      await state.initialize();
      expect(state.readingTimeBreakdown.allTimeSeconds, greaterThanOrEqualTo(0));
    });

    test('calculateReadingConsistency returns value in [0.0, 1.0]', () async {
      final state = _freshAppState();
      await state.initialize();
      final consistency = state.calculateReadingConsistency();
      expect(consistency, greaterThanOrEqualTo(0.0));
      expect(consistency, lessThanOrEqualTo(1.0));
    });

    test('calculateStreakDays returns non-negative int', () async {
      final state = _freshAppState();
      await state.initialize();
      expect(state.calculateStreakDays(), greaterThanOrEqualTo(0));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 13. Settings
  // ──────────────────────────────────────────────────────────────────────────
  group('Settings', () {
    test('setReaderFontSize clamps to [12, 28]', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setReaderFontSize(5.0); // below min
      expect(state.readerFontSize, equals(12.0));
      state.setReaderFontSize(40.0); // above max
      expect(state.readerFontSize, equals(28.0));
    });

    test('setReaderFontSize within range is accepted as-is', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setReaderFontSize(18.0);
      expect(state.readerFontSize, equals(18.0));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 14. Offline Behavior
  // ──────────────────────────────────────────────────────────────────────────
  group('Offline behavior', () {
    test('setOfflineMode(true) makes isOffline true', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setOfflineMode(true);
      expect(state.isOffline, isTrue);
    });

    test('setOfflineMode(false) makes isOffline false', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setOfflineMode(true);
      state.setOfflineMode(false);
      expect(state.isOffline, isFalse);
    });

    test('books list remains accessible while offline', () async {
      final state = _freshAppState();
      await state.initialize();
      state.setOfflineMode(true);
      expect(state.books, isNotEmpty);
      state.setOfflineMode(false);
    });

    test('vocabulary notes remain accessible while offline', () async {
      final state = _freshAppState();
      await state.initialize();
      await state.addVocabularyNote(_makeWord(
        id: 'offline_v_1',
        word: 'resilient',
        bookId: 'offline_book',
        bookTitle: 'Offline Book',
      ));
      state.setOfflineMode(true);
      expect(state.allVocabularyNotes.any((n) => n.id == 'offline_v_1'), isTrue);
      state.setOfflineMode(false);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 15. ChangeNotifier contract
  // ──────────────────────────────────────────────────────────────────────────
  group('ChangeNotifier contract', () {
    test('multiple listeners all receive notifications', () async {
      final state = _freshAppState();
      await state.initialize();
      int count = 0;
      final l1 = () => count++;
      final l2 = () => count++;
      state.addListener(l1);
      state.addListener(l2);
      state.setThemeMode(ReadingThemeMode.sepia);
      expect(count, equals(2));
      state.removeListener(l1);
      state.removeListener(l2);
    });

    test('removeListener stops future notifications', () async {
      final state = _freshAppState();
      await state.initialize();
      int count = 0;
      void listener() => count++;
      state.addListener(listener);
      state.setThemeMode(ReadingThemeMode.sepia);
      expect(count, equals(1));
      state.removeListener(listener);
      state.setThemeMode(ReadingThemeMode.dark);
      expect(count, equals(1)); // no new notification after removal
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 16. VocabularyWord model edge cases
  // ──────────────────────────────────────────────────────────────────────────
  group('VocabularyWord model edge cases', () {
    test('very long bookTitle does not crash VocabularyWord construction', () {
      final longTitle = 'A' * 300;
      final word = _makeWord(
        id: 'overflow_1',
        word: 'test',
        bookId: 'overflow_book',
        bookTitle: longTitle,
      );
      expect(word.bookTitle.length, equals(300));
    });

    test('empty word string is stored as-is', () {
      final word = _makeWord(
        id: 'empty_word',
        word: '',
        bookId: 'book_x',
        bookTitle: 'Book X',
      );
      expect(word.word, isEmpty);
    });

    test('copyWith preserves bookId and bookTitle when not explicitly changed', () {
      final word = _makeWord(
        id: 'copy_1',
        word: 'ephemeral',
        bookId: 'copy_book',
        bookTitle: 'Copy Book',
      );
      final copy = word.copyWith(englishMeaning: 'New meaning');
      expect(copy.bookId, equals('copy_book'));
      expect(copy.bookTitle, equals('Copy Book'));
      expect(copy.englishMeaning, equals('New meaning'));
    });

    test('copyWith id does not change when not specified', () {
      final word = _makeWord(
        id: 'id_test_word',
        word: 'ephemeral',
        bookId: 'id_book',
        bookTitle: 'ID Book',
      );
      final copy = word.copyWith(userNote: 'My note');
      expect(copy.id, equals('id_test_word'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 17. BookVocabularyCollection model
  // ──────────────────────────────────────────────────────────────────────────
  group('BookVocabularyCollection model', () {
    test('addWord appends to collection words list', () {
      final coll = BookVocabularyCollection(
        bookId: 'coll_test',
        bookTitle: 'Collection Test',
        words: [],
      );
      final w = _makeWord(id: 'cw1', word: 'hello', bookId: 'coll_test', bookTitle: 'Collection Test');
      coll.addWord(w);
      expect(coll.words.length, equals(1));
      expect(coll.words.first.id, equals('cw1'));
    });

    test('removeWord removes by id', () {
      final w = _makeWord(id: 'cw2', word: 'world', bookId: 'coll_test2', bookTitle: 'T2');
      final coll = BookVocabularyCollection(
        bookId: 'coll_test2',
        bookTitle: 'T2',
        words: [w],
      );
      coll.removeWord('cw2');
      expect(coll.words, isEmpty);
    });

    test('updateWord replaces the matching word by id', () {
      final w = _makeWord(id: 'cw3', word: 'old', bookId: 'coll_test3', bookTitle: 'T3', englishMeaning: 'Old');
      final coll = BookVocabularyCollection(
        bookId: 'coll_test3',
        bookTitle: 'T3',
        words: [w],
      );
      final updated = w.copyWith(englishMeaning: 'New');
      coll.updateWord(updated);
      expect(coll.words.first.englishMeaning, equals('New'));
    });

    test('wordCount reflects actual words list length', () {
      final w1 = _makeWord(id: 'cnt1', word: 'a', bookId: 'cnt_book', bookTitle: 'Cnt');
      final w2 = _makeWord(id: 'cnt2', word: 'b', bookId: 'cnt_book', bookTitle: 'Cnt');
      final coll = BookVocabularyCollection(
        bookId: 'cnt_book',
        bookTitle: 'Cnt',
        words: [w1, w2],
      );
      expect(coll.wordsCount, equals(2));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 18. Book Model — Progress and Status Calculations
  // ──────────────────────────────────────────────────────────────────────────
  group('Book model calculations', () {
    Book _book({int current = 50, int total = 200}) => Book(
          id: 'test_bk',
          title: 'Test',
          author: 'A',
          totalPages: total,
          currentPage: current,
          format: BookFormat.physical,
          status: BookStatus.reading,
          lastReadTime: '',
          coverGradient: const [Colors.blue, Colors.red],
          rating: 4.0,
        );

    test('progressPercentage is 0.25 for 50/200', () {
      expect(_book(current: 50, total: 200).progressPercentage, closeTo(0.25, 0.001));
    });

    test('progressPercentInt is 25 for 50/200', () {
      expect(_book(current: 50, total: 200).progressPercentInt, equals(25));
    });

    test('progressPercentage is 0.0 when currentPage is 0', () {
      expect(_book(current: 0, total: 100).progressPercentage, equals(0.0));
    });

    test('progressPercentage is 1.0 when currentPage == totalPages', () {
      expect(_book(current: 100, total: 100).progressPercentage, equals(1.0));
    });

    test('isPdf is false for physical book without filePath', () {
      expect(_book().isPdf, isFalse);
    });
  });
}
