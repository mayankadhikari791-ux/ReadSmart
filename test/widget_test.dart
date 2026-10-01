import 'package:flutter_test/flutter_test.dart';
import 'package:read_smart/main.dart';
import 'package:read_smart/state/app_state.dart';

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
    await tester.pump(const Duration(milliseconds: 100));

    // Now transitioned to MainShell
    expect(appState.isLoaded, isTrue);
  });
}
