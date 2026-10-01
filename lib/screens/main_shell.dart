import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav_bar.dart';
import 'full_library_screen.dart';
import 'home_dashboard_screen.dart';
import 'notes_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class MainShell extends StatefulWidget {
  final AppState appState;

  const MainShell({super.key, required this.appState});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _currentTabIndex,
            children: [
              HomeDashboardScreen(
                appState: widget.appState,
                onSwitchTab: _onTabSelected,
              ),
              FullLibraryScreen(appState: widget.appState),
              StatsScreen(appState: widget.appState),
              NotesScreen(appState: widget.appState),
              ProfileScreen(appState: widget.appState),
            ],
          ),
          bottomNavigationBar: ReadSmartBottomNavBar(
            currentIndex: _currentTabIndex,
            onTabSelected: _onTabSelected,
          ),
        );
      },
    );
  }
}
