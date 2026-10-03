import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/main.dart';
import 'package:read_smart/screens/reader_screen.dart';
import 'package:read_smart/screens/stats_screen.dart';
import 'package:read_smart/screens/notes_screen.dart';
import 'package:read_smart/screens/profile_screen.dart';
import 'package:read_smart/screens/full_library_screen.dart';
import 'package:read_smart/state/app_state.dart';
import 'package:read_smart/widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('ReadSmartApp renders and transitions from splash to main shell',
      (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(ReadSmartApp(appState: appState));

    // Initially, when not loaded, splash loading indicator and text are visible
    expect(find.text('ReadSmart'), findsOneWidget);
    expect(find.text('Loading your library...'), findsOneWidget);

    // Initialize state
    await tester.runAsync(() async {
      await appState.initialize();
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Now transitioned to MainShell
    expect(appState.isLoaded, isTrue);
  });

  testWidgets('Clicking Continue Reading button opens ReaderScreen without errors',
      (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(ReadSmartApp(appState: appState));

    await tester.runAsync(() async {
      await appState.initialize();
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Currently Reading card is present
    expect(find.text('CURRENTLY READING'), findsOneWidget);

    // Find Continue Reading button
    final continueBtn = find.text('Continue Reading');
    expect(continueBtn, findsOneWidget);

    // Tap Continue Reading
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Verify ReaderScreen is open
    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.text('The Soul of the World'), findsOneWidget);

    // Verify Slider is rendered and does not crash
    expect(find.byType(Slider), findsOneWidget);

    // Tap back button
    final backBtn = find.byIcon(Icons.arrow_back);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify returned to MainShell
    expect(find.byType(ReaderScreen), findsNothing);
    expect(find.text('CURRENTLY READING'), findsOneWidget);
  });

  testWidgets('Bottom navigation tabs switch smoothly between all 5 screens',
      (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(ReadSmartApp(appState: appState));

    await tester.runAsync(() async {
      await appState.initialize();
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    Finder navIcon(IconData icon) => find.descendant(
          of: find.byType(ReadSmartBottomNavBar),
          matching: find.byIcon(icon),
        );

    // 1. Switch to Library (Tab 1)
    final libraryNav = navIcon(Icons.auto_stories_rounded);
    expect(libraryNav, findsOneWidget);
    await tester.tap(libraryNav);
    await tester.pumpAndSettle();
    expect(find.byType(FullLibraryScreen), findsOneWidget);

    // 2. Switch to Stats / Analytics (Tab 2)
    final statsNav = navIcon(Icons.insights_rounded);
    expect(statsNav, findsOneWidget);
    await tester.tap(statsNav);
    await tester.pumpAndSettle();
    expect(find.byType(StatsScreen), findsOneWidget);

    // 3. Switch to Notes / Vocabulary (Tab 3)
    final notesNav = navIcon(Icons.menu_book_rounded);
    expect(notesNav, findsOneWidget);
    await tester.tap(notesNav);
    await tester.pumpAndSettle();
    expect(find.byType(NotesScreen), findsOneWidget);

    // 4. Switch to Profile (Tab 4)
    final profileNav = navIcon(Icons.person_rounded);
    expect(profileNav, findsOneWidget);
    await tester.tap(profileNav);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    // 5. Switch back to Home (Tab 0)
    final homeNav = navIcon(Icons.home_rounded);
    expect(homeNav, findsOneWidget);
    await tester.tap(homeNav);
    await tester.pumpAndSettle();
    expect(find.text('CURRENTLY READING'), findsOneWidget);
  });
}
