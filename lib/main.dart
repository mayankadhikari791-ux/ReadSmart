import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import 'screens/main_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.initialize();
  runApp(ReadSmartApp(appState: appState));
}

class ReadSmartApp extends StatelessWidget {
  final AppState appState;

  const ReadSmartApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        ThemeData theme;
        switch (appState.themeMode) {
          case ReadingThemeMode.dark:
            theme = AppTheme.darkTheme;
            break;
          case ReadingThemeMode.sepia:
            theme = AppTheme.sepiaTheme;
            break;
          case ReadingThemeMode.light:
            theme = AppTheme.lightTheme;
            break;
        }

        if (!appState.isLoaded) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            locale: appState.appLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8A020)),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'ReadSmart',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8A020),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Loading your library...',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'ReadSmart',
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: appState.appLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainShell(appState: appState),
        );
      },
    );
  }
}
