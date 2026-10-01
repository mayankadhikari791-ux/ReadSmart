import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/models/book_model.dart';
import 'package:read_smart/models/reading_analytics_models.dart';
import 'package:read_smart/state/app_state.dart';

void main() {
  group('Phase 9 Reading Analytics & Improvement Tests', () {
    late AppState appState;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      appState = AppState();
      await appState.initialize();
    });

    test('ReadingTimeBreakdown formats durations accurately', () {
      const breakdown = ReadingTimeBreakdown(
        todaySeconds: 1800, // 30m
        weeklySeconds: 7500, // 2h 5m
        monthlySeconds: 36600, // 10h 10m
        allTimeSeconds: 72000, // 20h 0m
      );

      expect(breakdown.todayFormatted, '30m');
      expect(breakdown.weeklyFormatted, '2h 5m');
      expect(breakdown.monthlyFormatted, '10h 10m');
      expect(breakdown.allTimeFormatted, '20h 0m');
    });

    test('AppState tracks books started and completed counts', () async {
      expect(appState.booksStartedCount, greaterThanOrEqualTo(0));
      expect(appState.booksCompletedCount, greaterThanOrEqualTo(0));

      // Add a completed book and verify count increment
      final testBook = await appState.addPhysicalBook(
        title: 'Finished Book',
        author: 'Test Author',
        totalPages: 100,
        currentPage: 100,
      );

      expect(appState.booksCompletedCount, greaterThanOrEqualTo(1));
      expect(testBook.status, BookStatus.completed);
    });

    test('AppState calculates average pages per session and PPH', () async {
      // Complete a 15-minute session of 10 pages
      await appState.completeAndSaveSession(
        bookId: appState.physicalSessionBook.id,
        pagesRead: 10,
        startPage: 1,
        endPage: 11,
      );

      expect(appState.averagePagesPerSession, greaterThan(0));
      expect(appState.averagePagesPerHourOverall, greaterThan(0));
    });

    test('AppState generates daily reading history records for charts', () {
      final records = appState.getDailyReadingHistory(days: 7);
      expect(records.length, 7);
      expect(records.first.date.isBefore(records.last.date) || records.first.date.isAtSameMomentAs(records.last.date), isTrue);
    });

    test('Intelligent Improvement Insights includes comprehension guardrail', () {
      final insights = appState.generateIntelligentImprovementInsights();
      expect(insights, isNotEmpty);

      // Must always have at least one comprehension-first guardrail insight
      final hasGuardrail = insights.any((i) => i.isComprehensionGuardrail);
      expect(hasGuardrail, isTrue);

      final guardrail = insights.firstWhere((i) => i.isComprehensionGuardrail);
      expect(guardrail.badgeText, anyOf(contains('Guardrail'), contains('Principle')));
    });
  });
}
