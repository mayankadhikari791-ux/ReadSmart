import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:read_smart/models/user_model.dart';
import 'package:read_smart/models/vocabulary_word_model.dart';
import 'package:read_smart/services/auth/auth_session_manager.dart';
import 'package:read_smart/services/auth/local_auth_service.dart';
import 'package:read_smart/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rs_auth_test_');
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Authentication and User Isolation Tests', () {
    test('User registration validates name, email, and password strength', () async {
      final auth = LocalAuthService();

      // Short name
      final r1 = await auth.signUpWithEmail(
        email: 'test@example.com',
        password: 'Password123',
        name: 'A',
      );
      expect(r1.isSuccess, isFalse);

      // Invalid email
      final r2 = await auth.signUpWithEmail(
        email: 'invalid-email',
        password: 'Password123',
        name: 'Valid Name',
      );
      expect(r2.isSuccess, isFalse);

      // Weak password (no number)
      final r3 = await auth.signUpWithEmail(
        email: 'test@example.com',
        password: 'onlyletters',
        name: 'Valid Name',
      );
      expect(r3.isSuccess, isFalse);

      // Valid registration
      final r4 = await auth.signUpWithEmail(
        email: 'alice@example.com',
        password: 'Password123',
        name: 'Alice Reader',
      );
      expect(r4.isSuccess, isTrue);
      expect(r4.data?.name, equals('Alice Reader'));
      expect(r4.data?.email, equals('alice@example.com'));

      // Duplicate email rejection
      final r5 = await auth.signUpWithEmail(
        email: 'alice@example.com',
        password: 'AnotherPassword456',
        name: 'Alice Duplicate',
      );
      expect(r5.isSuccess, isFalse);
    });

    test('Passwords are never stored in plain text (uses SHA-256 + salt)', () async {
      final auth = LocalAuthService();
      const rawPassword = 'SecretPassword999';

      await auth.signUpWithEmail(
        email: 'secure@example.com',
        password: rawPassword,
        name: 'Secure User',
      );

      final users = await AuthSessionManager.getUsers();
      final entry = users['secure@example.com']!;
      expect(entry['passwordHash'], isNotNull);
      expect(entry['salt'], isNotNull);

      // Confirm plain-text password is NOT in the database
      expect(entry.values.contains(rawPassword), isFalse);
      expect(entry['passwordHash'], isNot(equals(rawPassword)));
    });

    test('User A data is strictly isolated from User B data', () async {
      // 1. User A registers and signs in
      final appStateA = AppState();
      final userA = User(
        id: 'usr_alice_1',
        name: 'Alice',
        email: 'alice@readsmart.app',
        readingLevel: 'Avid Reader',
        avatarInitials: 'A',
        memberSince: 'Member',
      );

      await appStateA.initializeForUser(
        userId: userA.id,
        authenticatedUser: userA,
      );

      // User A adds a physical book and saves a book-specific vocabulary word
      final bookA = await appStateA.addPhysicalBook(
        title: 'The Alchemist',
        author: 'Paulo Coelho',
        totalPages: 200,
        currentPage: 50,
      );

      final vocabWord = VocabularyWord(
        id: 'vocab_1',
        bookId: bookA.id,
        bookTitle: bookA.title,
        word: 'Perseverance',
        pronunciation: '/ˌpərsəˈvirəns/',
        englishMeaning: 'Persistence in doing something despite difficulty.',
        hindiMeaning: 'दृढ़ता',
        hindiWord: 'दृढ़ता',
        exampleSentence: 'The boy felt that perseverance was essential.',
        dateSaved: 'Today',
        pageNumber: 50,
      );
      await appStateA.addVocabularyNote(vocabWord);

      expect(appStateA.books.any((b) => b.title == 'The Alchemist'), isTrue);
      expect(appStateA.vocabularyNotes.any((v) => v.word == 'Perseverance'), isTrue);

      // User A logs out
      appStateA.logout();
      expect(appStateA.books, isEmpty);
      expect(appStateA.vocabularyNotes, isEmpty);

      // 2. User B registers and signs in
      final appStateB = AppState();
      final userB = User(
        id: 'usr_bob_2',
        name: 'Bob',
        email: 'bob@readsmart.app',
        readingLevel: 'Casual Reader',
        avatarInitials: 'B',
        memberSince: 'Member',
      );

      await appStateB.initializeForUser(
        userId: userB.id,
        authenticatedUser: userB,
      );

      // Verify User B cannot access User A's books or vocabulary
      expect(appStateB.books.any((b) => b.title == 'The Alchemist'), isFalse);
      expect(appStateB.vocabularyNotes.any((v) => v.word == 'Perseverance'), isFalse);

      // User B adds their own book and vocabulary
      final bookB = await appStateB.addPhysicalBook(
        title: 'Atomic Habits',
        author: 'James Clear',
        totalPages: 300,
        currentPage: 25,
      );

      final vocabB = VocabularyWord(
        id: 'vocab_2',
        bookId: bookB.id,
        bookTitle: bookB.title,
        word: 'Habits',
        pronunciation: '/ˈhæbɪts/',
        englishMeaning: 'A settled or regular tendency or practice.',
        hindiMeaning: 'आदतें',
        hindiWord: 'आदत',
        exampleSentence: 'Tiny changes lead to remarkable results.',
        dateSaved: 'Today',
        pageNumber: 25,
      );
      await appStateB.addVocabularyNote(vocabB);

      expect(appStateB.books.any((b) => b.title == 'Atomic Habits'), isTrue);
      expect(appStateB.vocabularyNotes.any((v) => v.word == 'Habits'), isTrue);

      // User B logs out
      appStateB.logout();

      // 3. User A logs in again -> verify User A's data is restored
      final appStateARestore = AppState();
      await appStateARestore.initializeForUser(
        userId: userA.id,
        authenticatedUser: userA,
      );

      expect(appStateARestore.books.any((b) => b.title == 'The Alchemist'), isTrue);
      expect(appStateARestore.vocabularyNotes.any((v) => v.word == 'Perseverance'), isTrue);
      // User A cannot see User B's book
      expect(appStateARestore.books.any((b) => b.title == 'Atomic Habits'), isFalse);
      expect(appStateARestore.vocabularyNotes.any((v) => v.word == 'Habits'), isFalse);
    });
  });
}
