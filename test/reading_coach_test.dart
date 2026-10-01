import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/models/coach_models.dart';
import 'package:read_smart/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 10 Personalized Reading Coach Tests', () {
    late AppState appState;

    setUp(() async {
      appState = AppState();
      await appState.initialize();
    });

    test('Initializes the 5 required simple daily reading goals', () {
      final goals = appState.coachGoals;
      expect(goals.length, equals(5));

      final goalTypes = goals.map((g) => g.type).toSet();
      expect(goalTypes.contains(CoachGoalType.dailyMinutes), isTrue);
      expect(goalTypes.contains(CoachGoalType.dailyPages), isTrue);
      expect(goalTypes.contains(CoachGoalType.streak), isTrue);
      expect(goalTypes.contains(CoachGoalType.vocabulary), isTrue);
      expect(goalTypes.contains(CoachGoalType.finishChapter), isTrue);

      // Verify titles
      expect(goals.any((g) => g.title.contains('20 minutes')), isTrue);
      expect(goals.any((g) => g.title.contains('10 pages')), isTrue);
      expect(goals.any((g) => g.title.contains('7-day')), isTrue);
      expect(goals.any((g) => g.title.contains('5 new words')), isTrue);
      expect(goals.any((g) => g.title.contains('Finish a chapter')), isTrue);
    });

    test('Toggles finish chapter goal manually', () {
      final initialGoal = appState.coachGoals.firstWhere(
        (g) => g.type == CoachGoalType.finishChapter,
      );
      expect(initialGoal.isCompleted, isFalse);

      appState.toggleChapterGoalCompleted();
      final toggledGoal = appState.coachGoals.firstWhere(
        (g) => g.type == CoachGoalType.finishChapter,
      );
      expect(toggledGoal.isCompleted, isTrue);
      expect(toggledGoal.progress, equals(1.0));

      appState.toggleChapterGoalCompleted();
      final resetGoal = appState.coachGoals.firstWhere(
        (g) => g.type == CoachGoalType.finishChapter,
      );
      expect(resetGoal.isCompleted, isFalse);
    });

    test('Generates practical recommendations spanning all 7 categories citing data', () {
      final recs = appState.generatePersonalizedCoachRecommendations();

      // Must cover all 7 categories
      expect(recs.length, greaterThanOrEqualTo(7));
      final categories = recs.map((r) => r.category).toSet();
      expect(categories.contains(CoachRecommendationCategory.speed), isTrue);
      expect(categories.contains(CoachRecommendationCategory.comprehension), isTrue);
      expect(categories.contains(CoachRecommendationCategory.consistency), isTrue);
      expect(categories.contains(CoachRecommendationCategory.distractions), isTrue);
      expect(categories.contains(CoachRecommendationCategory.vocabulary), isTrue);
      expect(categories.contains(CoachRecommendationCategory.sessionQuality), isTrue);
      expect(categories.contains(CoachRecommendationCategory.healthyHabits), isTrue);

      // Avoid generic messages: must include concrete data evidence
      for (final rec in recs) {
        expect(rec.dataEvidence, contains('Data Evidence:'));
        expect(rec.recommendation.isNotEmpty, isTrue);
      }
    });

    test('Strictly enforces comprehension-first guardrail on speed recommendations', () {
      final recs = appState.generatePersonalizedCoachRecommendations();
      final speedRec = recs.firstWhere(
        (r) => r.category == CoachRecommendationCategory.speed,
      );

      expect(speedRec.isComprehensionGuardrail, isTrue);
      // Ensure the advice focuses on pacing with retention rather than sacrificing understanding
      expect(
        speedRec.recommendation.toLowerCase(),
        anyOf(contains('reducing'), contains('pacing'), contains('guide')),
      );
    });

    test('Logs comprehension self-assessment and updates user reading score', () {
      final initialLogsCount = appState.comprehensionLogs.length;

      appState.logComprehensionAssessment(
        bookTitle: 'Atomic Habits',
        ratingStars: 5,
        notes: 'Fabulous retention on the 4 laws of behavior change.',
      );

      expect(appState.comprehensionLogs.length, equals(initialLogsCount + 1));
      final latest = appState.latestComprehensionLog;
      expect(latest, isNotNull);
      expect(latest!.bookTitle, equals('Atomic Habits'));
      expect(latest.score, equals(100));
      expect(latest.ratingStars, equals(5));

      // Reading score adjusted upwards with high comprehension score
      expect(appState.userReadingScore, greaterThanOrEqualTo(50));
    });
  });
}
