import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/stat_card.dart';
import 'coach_screen.dart';
import 'ebook_library_screen.dart';
import 'pdf_reader_screen.dart';
import 'physical_tracker_screen.dart';
import 'reader_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final AppState appState;
  final Function(int)? onSwitchTab;

  const HomeDashboardScreen({
    super.key,
    required this.appState,
    this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final activeBook = appState.currentlyReadingBook;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Section / Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryGold, AppColors.secondaryAmber],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_stories,
                            color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ReadSmart',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => onSwitchTab?.call(4), // navigate to profile
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGold, AppColors.secondaryAmber],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Greeting
              const Text(
                'Good Evening, Mayank 👋',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Your personal reading companion',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              // 2. Currently Reading Hero Card
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.35),
                    width: 1,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookCoverWidget(
                          book: activeBook,
                          width: 68,
                          height: 98,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                                  borderRadius: AppRadius.roundedXs,
                                ),
                                child: const Text(
                                  'CURRENTLY READING',
                                  style: TextStyle(
                                    color: AppColors.primaryGold,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                activeBook.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activeBook.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.primaryGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ProgressBarWidget(
                                progress: activeBook.progressPercentage,
                                height: 5,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Page ${activeBook.currentPage} of ${activeBook.totalPages} • ${activeBook.progressPercentInt}%',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (activeBook.id == 'placeholder' || appState.books.isEmpty) {
                            onSwitchTab?.call(1); // Navigate to Library tab
                            return;
                          }
                          if (activeBook.isPhysical) {
                            appState.setSessionBook(activeBook.id, activeBook.title);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PhysicalTrackerScreen(
                                  appState: appState,
                                ),
                              ),
                            );
                          } else if (activeBook.isPdf) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PdfReaderScreen(
                                  book: activeBook,
                                  appState: appState,
                                  initialPage: activeBook.currentPage > 0
                                      ? activeBook.currentPage
                                      : 1,
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReaderScreen(
                                  book: activeBook,
                                  appState: appState,
                                  initialPage: activeBook.currentPage > 0
                                      ? activeBook.currentPage
                                      : 1,
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          activeBook.isPhysical
                              ? Icons.timer_outlined
                              : Icons.play_arrow_rounded,
                          size: 20,
                        ),
                        label: Text(
                          activeBook.id == 'placeholder'
                              ? 'Explore Library'
                              : (activeBook.isPhysical
                                  ? (activeBook.currentPage > 0
                                      ? 'Continue Tracking'
                                      : 'Track Reading')
                                  : (activeBook.currentPage > 0
                                      ? 'Continue Reading'
                                      : 'Start Reading')),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: const Color(0xFF141414),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedLg,
                          ),
                          textStyle: AppTypography.labelLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 3. Today's Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.schedule_rounded,
                      value: '45 min',
                      label: 'Read Time',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      icon: Icons.bolt_rounded,
                      value: '280 WPM',
                      label: 'Speed',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      icon: Icons.menu_book_rounded,
                      value: '23',
                      label: 'Pages',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department_rounded,
                      value: '${appState.dayStreak}d',
                      label: 'Streak',
                      iconColor: AppColors.brightFlame,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Personalized Reading Coach Card
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoachScreen(appState: appState),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology_outlined,
                          color: AppColors.primaryGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Reading Coach',
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${appState.coachGoals.where((g) => g.isCompleted).length}/${appState.coachGoals.length} Goals',
                                    style: const TextStyle(
                                      color: AppColors.primaryGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Personalized habits, goals & retention advice based on your data',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primaryGold,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  _buildQuickActionCard(
                    context,
                    icon: Icons.smartphone_rounded,
                    title: 'Read E-Book',
                    subtitle: 'Open digital library',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EbookLibraryScreen(appState: appState),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.bookmark_add_rounded,
                    title: 'Track Physical',
                    subtitle: 'Log live session',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PhysicalTrackerScreen(appState: appState),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.shelves,
                    title: 'My Library',
                    subtitle: '28 books cataloged',
                    onTap: () => onSwitchTab?.call(1),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.analytics_rounded,
                    title: 'Statistics',
                    subtitle: 'Speed & trend charts',
                    onTap: () => onSwitchTab?.call(2),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 5. Daily Literary Inspiration
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.format_quote_rounded,
                            color: AppColors.primaryGold, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'DAILY LITERARY INSIGHT',
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '“When you want something, all the universe conspires in helping you to achieve it.”',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '— Paulo Coelho, The Alchemist',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
