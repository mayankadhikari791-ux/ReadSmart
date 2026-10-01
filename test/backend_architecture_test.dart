import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/core/config/app_config.dart';
import 'package:read_smart/core/network/network_exceptions.dart';
import 'package:read_smart/core/network/resource.dart';
import 'package:read_smart/models/book_model.dart';
import 'package:read_smart/models/reading_progress_model.dart';
import 'package:read_smart/models/bookmark_model.dart';
import 'package:read_smart/data/repositories/i_book_repository.dart';
import 'package:read_smart/data/repositories/sync/offline_first_book_repository.dart';
import 'package:read_smart/services/auth/mock_auth_service.dart';
import 'package:read_smart/state/app_state.dart';

/// In-memory test repository simulating a local database driver.
class FakeLocalBookRepo implements IBookRepository {
  final List<Book> books = [];
  final Map<String, ReadingProgress> progressMap = {};
  final List<Bookmark> bookmarks = [];

  @override
  Future<List<Book>> getAllBooks() async => List.unmodifiable(books);

  @override
  Future<Book?> getBookById(String bookId) async =>
      books.firstWhere((b) => b.id == bookId, orElse: () => throw Exception('Not found'));

  @override
  Future<void> saveBook(Book book) async {
    books.removeWhere((b) => b.id == book.id);
    books.add(book);
  }

  @override
  Future<void> deleteBook(String bookId) async {
    books.removeWhere((b) => b.id == bookId);
  }

  @override
  Future<void> updateReadingProgress(ReadingProgress progress) async {
    progressMap[progress.bookId] = progress;
  }

  @override
  Future<ReadingProgress?> getReadingProgress(String bookId) async =>
      progressMap[bookId];

  @override
  Future<List<Bookmark>> getBookmarksForBook(String bookId) async =>
      bookmarks.where((b) => b.bookId == bookId).toList();

  @override
  Future<void> saveBookmark(Bookmark bookmark) async {
    bookmarks.add(bookmark);
  }

  @override
  Future<void> deleteBookmark(String bookmarkId) async {
    bookmarks.removeWhere((b) => b.id == bookmarkId);
  }
}

/// Simulated remote backend repository throwing network faults when requested.
class FaultyRemoteBookRepo implements IBookRepository {
  bool shouldTimeout = false;
  bool shouldFailServer = false;
  final List<Book> remoteStore = [];

  @override
  Future<List<Book>> getAllBooks() async {
    if (shouldTimeout) {
      throw const TimeoutFailure();
    }
    if (shouldFailServer) {
      throw const ServerFailure('500 Internal Server Error');
    }
    return remoteStore;
  }

  @override
  Future<Book?> getBookById(String bookId) async {
    if (shouldTimeout) throw const TimeoutFailure();
    return remoteStore.firstWhere((b) => b.id == bookId);
  }

  @override
  Future<void> saveBook(Book book) async {
    if (shouldTimeout) throw const TimeoutFailure();
    remoteStore.add(book);
  }

  @override
  Future<void> deleteBook(String bookId) async {
    if (shouldTimeout) throw const TimeoutFailure();
    remoteStore.removeWhere((b) => b.id == bookId);
  }

  @override
  Future<void> updateReadingProgress(ReadingProgress progress) async {
    if (shouldTimeout) throw const TimeoutFailure();
  }

  @override
  Future<ReadingProgress?> getReadingProgress(String bookId) async {
    if (shouldTimeout) throw const TimeoutFailure();
    return null;
  }

  @override
  Future<List<Bookmark>> getBookmarksForBook(String bookId) async => [];

  @override
  Future<void> saveBookmark(Bookmark bookmark) async {}

  @override
  Future<void> deleteBookmark(String bookmarkId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 14 — Production Backend Integration Architecture Tests', () {
    test('AppConfig provides non-empty default configurations and timeouts', () {
      expect(AppConfig.apiBaseUrl, isNotEmpty);
      expect(AppConfig.requestTimeoutMs, greaterThan(0));
      expect(AppConfig.requestTimeout, equals(const Duration(milliseconds: 15000)));
      expect(AppConfig.apiKey, isNotEmpty);
    });

    test('NetworkFailure exceptions preserve status codes and error messages', () {
      const timeout = TimeoutFailure();
      expect(timeout.statusCode, 408);
      expect(timeout.message, contains('timed out'));

      const unauthorized = UnauthorizedFailure();
      expect(unauthorized.statusCode, 401);

      const serverError = ServerFailure('Database unreachable', statusCode: 503);
      expect(serverError.statusCode, 503);
      expect(serverError.message, 'Database unreachable');

      const noInternet = NoInternetFailure();
      expect(noInternet.message, contains('No internet connection'));
    });

    test('Resource<T> encapsulates initial, loading, success, and error states with cache', () {
      final initial = Resource<String>.initial();
      expect(initial.isInitial, isTrue);
      expect(initial.hasData, isFalse);

      final loading = Resource<String>.loading(message: 'Fetching books...');
      expect(loading.isLoading, isTrue);
      expect(loading.message, 'Fetching books...');

      final success = Resource<List<String>>.success(['Book 1', 'Book 2']);
      expect(success.isSuccess, isTrue);
      expect(success.data?.length, 2);

      // Error with cached data preserved
      final error = Resource<List<String>>.error(
        const TimeoutFailure(),
        cachedData: ['Cached Book'],
      );
      expect(error.isError, isTrue);
      expect(error.hasData, isTrue);
      expect(error.data?.first, 'Cached Book');
      expect(error.failure, isA<TimeoutFailure>());
    });

    test('IAuthService (MockAuthService) signs in, validates inputs, and handles offline failure', () async {
      final auth = MockAuthService();

      // Sign In with invalid email
      final invalidRes = await auth.signInWithEmail(email: 'invalid', password: '123');
      expect(invalidRes.isError, isTrue);
      expect(invalidRes.failure, isA<InvalidDataFailure>());

      // Sign In with short password
      final shortPassRes = await auth.signInWithEmail(email: 'user@test.com', password: '12');
      expect(shortPassRes.isError, isTrue);
      expect(shortPassRes.failure, isA<UnauthorizedFailure>());

      // Sign In success
      final successRes = await auth.signInWithEmail(email: 'user@test.com', password: 'password123');
      expect(successRes.isSuccess, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.email, 'user@test.com');

      // Offline simulation
      auth.simulateOffline = true;
      final offlineRes = await auth.signInWithEmail(email: 'user@test.com', password: 'password123');
      expect(offlineRes.isError, isTrue);
      expect(offlineRes.failure, isA<NoInternetFailure>());
      // Returns previous cached user when available
      expect(offlineRes.hasData, isTrue);

      auth.dispose();
    });

    test('OfflineFirstBookRepository keeps local reading functional when remote backend times out or fails', () async {
      final localRepo = FakeLocalBookRepo();
      final remoteRepo = FaultyRemoteBookRepo();

      final offlineFirstRepo = OfflineFirstBookRepository(
        localRepo: localRepo,
        remoteRepo: remoteRepo,
      );

      // 1. Add local book
      final localBook = Book(
        id: 'book_offline_1',
        title: 'Offline Reading Mastery',
        author: 'ReadSmart Scholar',
        totalPages: 200,
        currentPage: 50,
        coverGradient: const [Color(0xFFE8A020), Color(0xFF78350F)],
      );
      await offlineFirstRepo.saveBook(localBook);

      // 2. Simulate complete remote timeout / server error
      remoteRepo.shouldTimeout = true;
      remoteRepo.shouldFailServer = true;

      // 3. User can still fetch all books seamlessly without unhandled exceptions
      final books = await offlineFirstRepo.getAllBooks();
      expect(books.length, 1);
      expect(books.first.title, 'Offline Reading Mastery');

      // 4. Progress updates succeed locally even during remote failure
      await offlineFirstRepo.updateReadingProgress(
        ReadingProgress(
          id: 'prog_1',
          bookId: 'book_offline_1',
          currentPage: 75,
          totalPages: 200,
          progressPercentage: 0.375,
          lastReadTimestamp: DateTime.now(),
        ),
      );

      final progress = await offlineFirstRepo.getReadingProgress('book_offline_1');
      expect(progress?.currentPage, 75);
    });

    test('AppState integrates authentication and offline toggling cleanly', () async {
      final appState = AppState();
      await appState.initialize();

      expect(appState.isOffline, isFalse);
      appState.setOfflineMode(true);
      expect(appState.isOffline, isTrue);

      // Clean authentication trigger via AppState
      final res = await appState.signIn(email: 'reader@readsmart.app', password: 'secretpassword');
      expect(res.isSuccess, isTrue);
      expect(appState.user.email, 'reader@readsmart.app');

      // Sign out
      await appState.signOut();
      expect(appState.authStatus.isInitial, isTrue);
    });
  });
}
