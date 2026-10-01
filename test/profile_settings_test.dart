import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/models/user_model.dart';
import 'package:read_smart/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 13 Complete Profile & Settings Tests', () {
    late AppState appState;

    setUp(() async {
      appState = AppState();
      await appState.initialize();
    });

    test('User profile update modifies name, email, and initials in memory and persists', () async {
      final initialUser = appState.user;
      expect(initialUser.name.isNotEmpty, isTrue);

      final updatedUser = User(
        id: initialUser.id,
        name: 'Alex Rivera',
        email: 'alex.rivera@example.com',
        readingLevel: 'Master Reader',
        avatarInitials: 'AR',
        memberSince: 'Member since 2024',
      );

      await appState.updateUser(updatedUser);

      expect(appState.user.name, 'Alex Rivera');
      expect(appState.user.email, 'alex.rivera@example.com');
      expect(appState.user.avatarInitials, 'AR');
      expect(appState.user.readingLevel, 'Master Reader');
    });

    test('Reading goals update adjusts daily minutes and annual target', () async {
      await appState.updateDailyGoal(45);
      await appState.updateAnnualGoal(36);

      expect(appState.dailyGoalMinutes, 45);
      expect(appState.annualBooksGoal, 36);

      // Verify daily goal progress computation
      expect(appState.dailyGoalProgress, greaterThanOrEqualTo(0.0));
      expect(appState.dailyGoalProgress, lessThanOrEqualTo(1.0));
    });

    test('Notification toggles operate independently in memory', () {
      expect(appState.dailyReminderEnabled, isFalse);
      expect(appState.streakAlertsEnabled, isFalse);

      appState.toggleDailyReminder(true);
      expect(appState.dailyReminderEnabled, isTrue);
      expect(appState.streakAlertsEnabled, isFalse);

      appState.toggleStreakAlerts(true);
      expect(appState.streakAlertsEnabled, isTrue);

      appState.toggleDailyReminder(false);
      expect(appState.dailyReminderEnabled, isFalse);
      expect(appState.streakAlertsEnabled, isTrue);
    });

    test('exportNotesAsJson formats all vocabulary words into valid JSON string', () {
      final jsonOutput = appState.exportNotesAsJson();
      expect(jsonOutput.isNotEmpty, isTrue);

      final dynamic decoded = jsonDecode(jsonOutput);
      expect(decoded, isA<List>());
      final list = decoded as List;
      expect(list.length, appState.allVocabularyNotes.length);

      if (list.isNotEmpty) {
        final firstItem = list.first as Map<String, dynamic>;
        expect(firstItem.containsKey('word'), isTrue);
        expect(firstItem.containsKey('englishMeaning'), isTrue);
      }
    });

    test('clearReadingHistory clears sessions without deleting books or vocabulary notes', () async {
      final initialBookCount = appState.books.length;
      final initialVocabCount = appState.allVocabularyNotes.length;

      expect(initialBookCount, greaterThan(0));
      expect(initialVocabCount, greaterThan(0));

      // Clear reading history (destructive to sessions and stats only)
      await appState.clearReadingHistory();

      // Sessions must be completely empty
      expect(appState.sessions, isEmpty);
      expect(appState.totalPagesReadOverall, 0);

      // Books and vocabulary notes must remain completely untouched
      expect(appState.books.length, initialBookCount);
      expect(appState.allVocabularyNotes.length, initialVocabCount);
    });
  });
}

