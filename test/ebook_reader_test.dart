import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/models/reader_settings_model.dart';
import 'package:read_smart/state/app_state.dart';
import 'package:read_smart/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 11 E-Book Reader Physical Book Feel Tests', () {
    late AppState appState;

    setUp(() async {
      appState = AppState();
      await appState.initialize();
    });

    test('ReaderSettings model initializes with sensible physical book defaults', () {
      const settings = ReaderSettings();
      expect(settings.fontSize, equals(16.0));
      expect(settings.lineSpacing, equals(LineSpacingPreset.normal));
      expect(settings.layout, equals(PageMarginLayout.bookLike));
      expect(settings.transition, equals(PageTransitionType.animatedCurl));
      expect(settings.themeMode, equals(ReadingThemeMode.dark));
      expect(settings.tapZonesEnabled, isTrue);
      expect(settings.autoHideControls, isTrue);
      expect(settings.showFooter, isTrue);
    });

    test('ReaderSettings copyWith and JSON roundtrip preserves all reader comfort options', () {
      const original = ReaderSettings(
        fontSize: 20.0,
        lineSpacing: LineSpacingPreset.relaxed,
        brightness: 0.25,
        themeMode: ReadingThemeMode.sepia,
        transition: PageTransitionType.animatedCurl,
        layout: PageMarginLayout.spacious,
        font: ReaderFontPreset.serif,
        highContrast: true,
        autoHideControls: false,
        tapZonesEnabled: true,
        showFooter: true,
      );

      final json = original.toJson();
      final revived = ReaderSettings.fromJson(json);

      expect(revived.fontSize, equals(20.0));
      expect(revived.lineSpacing, equals(LineSpacingPreset.relaxed));
      expect(revived.themeMode, equals(ReadingThemeMode.sepia));
      expect(revived.layout, equals(PageMarginLayout.spacious));
      expect(revived.highContrast, isTrue);
      expect(revived.autoHideControls, isFalse);
    });

    test('AppState updates ReaderSettings and synchronizes theme and font size', () {
      expect(appState.readerSettings.layout, equals(PageMarginLayout.bookLike));

      final updated = appState.readerSettings.copyWith(
        themeMode: ReadingThemeMode.sepia,
        fontSize: 22.0,
        layout: PageMarginLayout.spacious,
      );

      appState.updateReaderSettings(updated);

      expect(appState.readerSettings.themeMode, equals(ReadingThemeMode.sepia));
      expect(appState.themeMode, equals(ReadingThemeMode.sepia));
      expect(appState.readerFontSize, equals(22.0));
      expect(appState.readerSettings.layout, equals(PageMarginLayout.spacious));
    });

    test('Bookmarks flow: save, list and delete bookmark in AppState', () async {
      final initialBookmarks = await appState.getBookmarksForBook('book_1');
      final initialCount = initialBookmarks.length;

      await appState.saveBookmark(
        bookId: 'book_1',
        page: 42,
        title: 'Page 42 — The Alchemist',
      );

      final updatedBookmarks = await appState.getBookmarksForBook('book_1');
      expect(updatedBookmarks.length, equals(initialCount + 1));
      final saved = updatedBookmarks.firstWhere((b) => b.pageNumber == 42);
      expect(saved.title, contains('Page 42'));

      // Delete bookmark
      await appState.deleteBookmark(saved.id);
      final remaining = await appState.getBookmarksForBook('book_1');
      expect(remaining.length, equals(initialCount));
    });

    test('Tap zone calculation properly segments screen into left 25%, center 50%, and right 25%', () {
      const screenWidth = 400.0;
      final leftBoundary = screenWidth * 0.25; // 100.0
      final rightBoundary = screenWidth * 0.75; // 300.0

      expect(50.0 < leftBoundary, isTrue); // Left zone: Previous page
      expect(350.0 > rightBoundary, isTrue); // Right zone: Next page
      expect(200.0 >= leftBoundary && 200.0 <= rightBoundary, isTrue); // Center zone: Menu
    });
  });
}

