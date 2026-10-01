import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:read_smart/models/reading_progress_model.dart';
import 'package:read_smart/models/reading_session_model.dart';
import 'package:read_smart/models/user_model.dart';
import 'package:read_smart/models/vocabulary_word_model.dart';
import 'package:read_smart/services/auth/auth_session_manager.dart';
import 'package:read_smart/services/sync/cloud_sync_backend.dart';
import 'package:read_smart/services/sync/sync_record.dart';
import 'package:read_smart/services/sync/sync_state.dart';
import 'package:read_smart/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CloudSyncBackend sharedBackend;
  const userAToken = 'session_token_alice_12345';
  const userBToken = 'session_token_bob_67890';
  const userAId = 'usr_alice';
  const userBId = 'usr_bob';

  final userA = User(
    id: userAId,
    name: 'Alice',
    email: 'alice@readsmart.app',
    readingLevel: 'Avid Reader',
    avatarInitials: 'A',
    memberSince: 'Member',
  );


  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedBackend = CloudSyncBackend();

    // Register active server sessions
    AuthSessionManager.registerServerSession(
      token: userAToken,
      userId: userAId,
      email: 'alice@readsmart.app',
      expiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
    );

    AuthSessionManager.registerServerSession(
      token: userBToken,
      userId: userBId,
      email: 'bob@readsmart.app',
      expiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
    );
  });

  group('Cloud Synchronization Tests', () {
    test('Device A -> Login -> Add book -> Save vocabulary; Device B restores data', () async {
      // 1. Device A sets up session for User A
      final deviceA = AppState();
      await deviceA.initializeForUser(
        userId: userAId,
        authenticatedUser: userA,
        authToken: userAToken,
        customBackend: sharedBackend,
      );

      // Device A adds a book and book-specific vocabulary
      final book = await deviceA.addPhysicalBook(
        title: 'The Alchemist',
        author: 'Paulo Coelho',
        totalPages: 200,
        currentPage: 45,
      );

      final word1 = VocabularyWord(
        id: 'vocab_perseverance',
        bookId: book.id,
        bookTitle: book.title,
        word: 'Perseverance',
        pronunciation: '/ˌpərsəˈvirəns/',
        englishMeaning: 'Steadfastness in doing something despite difficulty.',
        hindiMeaning: 'दृढ़ता',
        hindiWord: 'दृढ़ता',
        exampleSentence: 'The boy learned the power of perseverance.',
        dateSaved: 'Just now',
        pageNumber: 45,
      );
      await deviceA.addVocabularyNote(word1);

      final word2 = VocabularyWord(
        id: 'vocab_destiny',
        bookId: book.id,
        bookTitle: book.title,
        word: 'Destiny',
        pronunciation: '/ˈdestinē/',
        englishMeaning: 'The events that will necessarily happen to a particular person.',
        hindiMeaning: 'भाग्य',
        hindiWord: 'किस्मत',
        exampleSentence: 'To realize one’s destiny is a person’s only obligation.',
        dateSaved: 'Just now',
        pageNumber: 45,
      );
      await deviceA.addVocabularyNote(word2);

      // Force device A sync push to backend
      await deviceA.syncNow();
      expect(deviceA.syncStatus, equals(SyncStatus.synced));

      // 2. Device B logs in with the SAME user account
      final deviceB = AppState();
      await deviceB.initializeForUser(
        userId: userAId,
        authenticatedUser: userA,
        authToken: userAToken,
        customBackend: sharedBackend,
      );

      // Pull updates from cloud
      await deviceB.syncNow();

      // Verify book and book-specific vocabulary appear on Device B
      expect(deviceB.books.any((b) => b.title == 'The Alchemist'), isTrue);
      final deviceBBook = deviceB.books.firstWhere((b) => b.title == 'The Alchemist');
      expect(deviceBBook.currentPage, equals(45));

      expect(deviceB.allVocabularyNotes.any((w) => w.word == 'Perseverance'), isTrue);
      expect(deviceB.allVocabularyNotes.any((w) => w.word == 'Destiny'), isTrue);

      // Verify vocabulary is properly partitioned under the specific book
      final collection = deviceB.collectionForBook(book.id);
      expect(collection, isNotNull);
      expect(collection!.words.length, equals(2));
      expect(collection.words.any((w) => w.word == 'Perseverance'), isTrue);
      expect(collection.words.any((w) => w.word == 'Destiny'), isTrue);
    });

    test('Offline reading on Device A queues changes; reconnecting synchronizes to Device B', () async {
      // Setup Device A
      final deviceA = AppState();
      await deviceA.initializeForUser(
        userId: userAId,
        authenticatedUser: userA,
        authToken: userAToken,
        customBackend: sharedBackend,
      );

      final book = await deviceA.addPhysicalBook(
        title: 'Atomic Habits',
        author: 'James Clear',
        totalPages: 320,
        currentPage: 10,
      );
      await deviceA.syncNow();

      // Device A goes offline
      deviceA.setOfflineMode(true);
      expect(deviceA.isOffline, isTrue);
      expect(deviceA.syncStatus, equals(SyncStatus.offline));

      // Offline updates: update progress and add vocabulary
      await deviceA.updateBookProgress(book.id, 85);
      final offlineWord = VocabularyWord(
        id: 'vocab_friction',
        bookId: book.id,
        bookTitle: book.title,
        word: 'Friction',
        pronunciation: '/ˈfrikSH(ə)n/',
        englishMeaning: 'The resistance that one surface or object encounters.',
        hindiMeaning: 'घर्षण',
        hindiWord: 'घर्षण',
        exampleSentence: 'Reduce friction to make good habits easier.',
        dateSaved: 'Just now',
        pageNumber: 85,
      );
      await deviceA.addVocabularyNote(offlineWord);

      // Reading should not be blocked while offline
      expect(deviceA.pendingSyncCount, greaterThan(0));
      expect(deviceA.books.firstWhere((b) => b.id == book.id).currentPage, equals(85));

      // Reconnect network on Device A
      deviceA.setOfflineMode(false);
      expect(deviceA.isOffline, isFalse);
      await deviceA.syncNow();
      expect(deviceA.syncStatus, equals(SyncStatus.synced));
      expect(deviceA.pendingSyncCount, equals(0));

      // Device B pulls and verifies offline changes synchronized
      final deviceB = AppState();
      await deviceB.initializeForUser(
        userId: userAId,
        authenticatedUser: userA,
        authToken: userAToken,
        customBackend: sharedBackend,
      );
      await deviceB.syncNow();

      final syncedBook = deviceB.books.firstWhere((b) => b.id == book.id);
      expect(syncedBook.currentPage, equals(85));
      expect(deviceB.allVocabularyNotes.any((w) => w.word == 'Friction'), isTrue);
    });

    test('Conflict resolution: highest reading page progress always wins', () {
      final now = DateTime.now();
      final local = ReadingProgress(
        id: 'prog_1',
        bookId: 'book_1',
        currentPage: 50,
        totalPages: 200,
        progressPercentage: 25.0,
        lastReadTimestamp: now,
      );

      final remote = ReadingProgress(
        id: 'prog_1',
        bookId: 'book_1',
        currentPage: 120,
        totalPages: 200,
        progressPercentage: 60.0,
        lastReadTimestamp: now.subtract(const Duration(minutes: 5)),
      );

      final resolved = SyncConflictResolver.resolveReadingProgress(local, remote);
      // Even though local timestamp is newer, remote currentPage is 120 > 50, so page 120 wins
      expect(resolved.currentPage, equals(120));
    });

    test('Conflict resolution: reading sessions merge additively without loss', () {
      final t1 = DateTime.now().subtract(const Duration(hours: 2));
      final t2 = DateTime.now().subtract(const Duration(hours: 1));

      final session1 = ReadingSession(
        id: 'sess_1',
        bookId: 'book_1',
        bookTitle: 'Book 1',
        durationSeconds: 1200,
        pagesRead: 20,
        readingSpeedWpm: 250,
        timestamp: t1,
      );

      final session2 = ReadingSession(
        id: 'sess_2',
        bookId: 'book_1',
        bookTitle: 'Book 1',
        durationSeconds: 1800,
        pagesRead: 30,
        readingSpeedWpm: 260,
        timestamp: t2,
      );

      final merged = SyncConflictResolver.mergeSessions([session1], [session2]);
      expect(merged.length, equals(2));
      expect(merged.any((s) => s.id == 'sess_1'), isTrue);
      expect(merged.any((s) => s.id == 'sess_2'), isTrue);
    });

    test('Backend security: token validation enforces server identity and denies unauthorized requests', () async {
      // 1. Invalid token request
      final invalidRes = await sharedBackend.pullChanges(authToken: 'fake_or_expired_token');
      expect(invalidRes.isSuccess, isFalse);

      // 2. Client-supplied userId spoofing is ignored:
      // Client tries to push a record with userId 'usr_victim' using Alice's token
      final spoofedRecord = SyncRecord(
        id: 'spoofed_record_1',
        entityType: SyncEntityType.book,
        userId: 'usr_victim',
        data: {'title': 'Malicious Book'},
        updatedAt: DateTime.now().toUtc(),
      );

      final pushRes = await sharedBackend.pushChanges(
        authToken: userAToken,
        records: [spoofedRecord],
      );
      expect(pushRes.isSuccess, isTrue);

      // Verify the record was stamped with Alice's verified userId on the server
      final accepted = pushRes.data!.first;
      expect(accepted.userId, equals(userAId));

      // 3. User B cannot access User A's cloud records
      final userBRecords = await sharedBackend.pullChanges(authToken: userBToken);
      expect(userBRecords.isSuccess, isTrue);
      expect(userBRecords.data!.any((r) => r.id == 'spoofed_record_1'), isFalse);
    });
  });
}
