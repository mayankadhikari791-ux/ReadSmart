import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/reading_goals_sheet.dart';
import 'language_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppState appState;

  const ProfileScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final user = appState.user;
        final totalHours = (appState.readingTimeBreakdown.allTimeSeconds / 3600).toStringAsFixed(1);

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkBackground,
            elevation: 0,
            title: Text(
               l10n.profileTitle,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit Profile',
                icon: const Icon(Icons.edit_outlined, color: AppColors.primaryGold),
                onPressed: () => EditProfileSheet.show(context, appState),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Header Card
                _buildProfileHeaderCard(context, user),
                const SizedBox(height: 18),

                // 2. Reading Goals Section
                _buildReadingGoalsCard(context),
                const SizedBox(height: 18),

                // 3. Reader & Appearance Settings
                _buildAppearanceSettingsCard(context),
                const SizedBox(height: 18),

                // 4. Language & Dictionary Section
                _buildLanguageSettingsTile(context, l10n),
                const SizedBox(height: 18),

                // 5. Reading Statistics Summary
                _buildReadingStatsCard(context, totalHours),
                const SizedBox(height: 18),

                // 6. Notifications & Reminders
                _buildNotificationsCard(context),
                const SizedBox(height: 18),

                // 7. Data Management (Export & Clear History with confirmation)
                _buildDataManagementCard(context),
                const SizedBox(height: 18),

                // 8. About ReadSmart
                _buildAboutCard(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────── 1. Profile Header Card ────────────────
  Widget _buildProfileHeaderCard(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar circle with gold gradient
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryGold,
                  AppColors.secondaryAmber,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                user.avatarInitials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.name,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user.email,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '📚 ${user.readingLevel}',
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.memberSince,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.darkBorder),
          const SizedBox(height: 12),

          // Stats Quick Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileStatColumn('${appState.booksCompletedCount}', 'Books Finished'),
              _buildDivider(),
              _buildProfileStatColumn('${appState.totalPagesReadOverall}', 'Pages Read'),
              _buildDivider(),
              _buildProfileStatColumn('${appState.dayStreak}-Day', 'Streak'),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────── 2. Reading Goals Card ────────────────
  Widget _buildReadingGoalsCard(BuildContext context) {
    final dailyMinutes = appState.todayReadingMinutes;
    final targetDaily = appState.dailyGoalMinutes;
    final progress = appState.dailyGoalProgress;
    final annualBooks = appState.annualBooksGoal;
    final completedBooks = appState.booksCompletedCount;
    final annualProgress = (completedBooks / annualBooks).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.track_changes_rounded, color: AppColors.primaryGold, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'READING GOALS',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => ReadingGoalsSheet.show(context, appState),
                child: const Text(
                  'Adjust Goals',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daily Target Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Reading Target', style: TextStyle(color: Colors.white, fontSize: 13)),
              Text(
                '$dailyMinutes / $targetDaily min',
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.darkSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            ),
          ),

          const SizedBox(height: 14),

          // Annual Target Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Annual Book Target', style: TextStyle(color: Colors.white, fontSize: 13)),
              Text(
                '$completedBooks / $annualBooks books',
                style: const TextStyle(
                  color: AppColors.secondaryAmber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: annualProgress,
              minHeight: 6,
              backgroundColor: AppColors.darkSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryAmber),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 3. Appearance & Reader Settings ────────────────
  Widget _buildAppearanceSettingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.palette_outlined, color: AppColors.primaryGold, size: 16),
              SizedBox(width: 8),
              Text(
                'READER & APPEARANCE',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Theme selection
          const Text('Reading Theme', style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildThemeOption('Dark Mode', ReadingThemeMode.dark, appState),
              const SizedBox(width: 8),
              _buildThemeOption('Sepia Mode', ReadingThemeMode.sepia, appState),
              const SizedBox(width: 8),
              _buildThemeOption('Light Mode', ReadingThemeMode.light, appState),
            ],
          ),
          const SizedBox(height: 16),

          // Font size slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Default Font Size', style: TextStyle(color: Colors.white, fontSize: 13)),
              Text(
                '${appState.readerFontSize.round()} sp',
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryGold,
              inactiveTrackColor: AppColors.darkSurface,
              thumbColor: AppColors.primaryGold,
              trackHeight: 3,
            ),
            child: Slider(
              value: appState.readerFontSize,
              min: 12,
              max: 28,
              divisions: 8,
              onChanged: (val) => appState.setReaderFontSize(val),
            ),
          ),
          const SizedBox(height: 6),

          // Full screen mode toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryGold,
            title: const Text('Start in Distraction-Free Fullscreen',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text('Hide device status bar and system bars while reading',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            value: appState.startInFullScreen,
            onChanged: (val) => appState.toggleFullScreen(val),
          ),

          // Auto-bookmark toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryGold,
            title: const Text('Auto-Save Last Read Position',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text('Automatically bookmark page on exit or pause',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            value: appState.autoBookmark,
            onChanged: (val) => appState.toggleAutoBookmark(val),
          ),
        ],
      ),
    );
  }

  // ──────────────── 4. Language Settings Tile ────────────────
  Widget _buildLanguageSettingsTile(BuildContext context, AppLocalizations? l10n) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LanguageSettingsScreen(appState: appState),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.language, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.settingsTitle ?? 'Language & Dictionary',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'App: ${appState.interfaceLanguage.split(' ').first} • Dict: ${appState.primaryDictionaryLanguage.split(' ').first}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  // ──────────────── 5. Reading Statistics Summary ────────────────
  Widget _buildReadingStatsCard(BuildContext context, String totalHours) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppColors.primaryGold, size: 16),
              SizedBox(width: 8),
              Text(
                'READING STATISTICS',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  '${appState.sessions.length}',
                  'Total Sessions',
                  Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  '${appState.totalPagesReadOverall}',
                  'Total Pages',
                  Icons.menu_book_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  appState.avgSessionDuration,
                  'Avg Duration',
                  Icons.timelapse_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  '$totalHours hrs',
                  'Time Reading',
                  Icons.hourglass_bottom_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────── 6. Notifications & Reminders ────────────────
  Widget _buildNotificationsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_outlined, color: AppColors.primaryGold, size: 16),
              SizedBox(width: 8),
              Text(
                'NOTIFICATIONS & REMINDERS',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryGold,
            title: const Text('Daily Reading Reminders',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text('Encouraging daily prompt to protect your streak',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            value: appState.dailyReminderEnabled,
            onChanged: (val) => appState.toggleDailyReminder(val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryGold,
            title: const Text('Streak & Achievement Alerts',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text('Milestone celebrations upon completing books or streaks',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            value: appState.streakAlertsEnabled,
            onChanged: (val) => appState.toggleStreakAlerts(val),
          ),
        ],
      ),
    );
  }

  // ──────────────── 7. Data Management ────────────────
  Widget _buildDataManagementCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storage_rounded, color: AppColors.primaryGold, size: 16),
              SizedBox(width: 8),
              Text(
                'DATA MANAGEMENT',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Export Notes
          _buildDataRow(
            icon: Icons.file_upload_outlined,
            title: 'Export Vocabulary Notes (.json)',
            subtitle: 'Export ${appState.allVocabularyNotes.length} saved words & definitions',
            onTap: () {
              final jsonStr = appState.exportNotesAsJson();
              Clipboard.setData(ClipboardData(text: jsonStr));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.darkCardElevated,
                  content: Text(
                    'Exported ${appState.allVocabularyNotes.length} notes! Copied JSON to clipboard.',
                    style: const TextStyle(color: AppColors.textWhite),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(color: AppColors.darkBorder),

          // Clear Reading History with professional confirmation dialog
          _buildDataRow(
            icon: Icons.delete_sweep_outlined,
            title: 'Clear Reading History',
            subtitle: 'Wipe sessions & speed logs (keeps all books & vocabulary intact)',
            textColor: AppColors.dangerRed,
            onTap: () async {
              final confirmed = await ConfirmActionDialog.show(
                context,
                title: 'Clear Reading History?',
                message:
                    'This action permanently deletes all recorded reading sessions and resets your reading speed statistics.',
                safetyNote:
                    'Your books and saved vocabulary notes will NOT be deleted or modified.',
                confirmLabel: 'Clear History',
                cancelLabel: 'Cancel',
              );

              if (confirmed) {
                await appState.clearReadingHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.darkCardElevated,
                      content: Text(
                        'Reading history cleared. Books & vocabulary preserved.',
                        style: TextStyle(color: AppColors.textWhite),
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ──────────────── 8. About ReadSmart ────────────────
  Widget _buildAboutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryGold, size: 16),
              SizedBox(width: 8),
              Text(
                'ABOUT READSMART',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'ReadSmart — Intelligent Companion & E-Reader',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Built with Flutter. Supporting physical reading trackers, true PDF rendering, book-scoped vocabulary flashcards, and personalized retention coaching.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: const Text(
              'v2.4.1 (Phase 13 Release)',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 26,
      color: AppColors.darkBorder,
    );
  }

  Widget _buildThemeOption(
      String label, ReadingThemeMode mode, AppState state) {
    final isSelected = state.themeMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => state.setThemeMode(mode),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGold : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color textColor = Colors.white,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: textColor, size: 22),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
      onTap: onTap,
    );
  }
}
