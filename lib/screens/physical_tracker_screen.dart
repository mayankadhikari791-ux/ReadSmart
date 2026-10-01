import 'package:flutter/material.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../models/book_model.dart';
import '../models/reading_session_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/stat_card.dart';

class PhysicalTrackerScreen extends StatefulWidget {
  final AppState appState;
  final Book? initialBook;

  const PhysicalTrackerScreen({
    super.key,
    required this.appState,
    this.initialBook,
  });

  @override
  State<PhysicalTrackerScreen> createState() => _PhysicalTrackerScreenState();
}

class _PhysicalTrackerScreenState extends State<PhysicalTrackerScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _totalPagesController;
  late final TextEditingController _currentPageController;
  bool _filterHistoryByCurrentBook = true;

  @override
  void initState() {
    super.initState();
    final book = widget.appState.currentlyReadingBook;
    _titleController = TextEditingController(text: book.title);
    _authorController = TextEditingController(text: book.author);
    _totalPagesController =
        TextEditingController(text: book.totalPages.toString());
    _currentPageController =
        TextEditingController(text: book.currentPage.toString());
    if (widget.initialBook != null) {
      widget.appState.setSessionBook(
        widget.initialBook!.id,
        widget.initialBook!.title,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final currentBook = state.physicalSessionBook;
    final physicalBooks = state.physicalBooks;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final currentSessions = _filterHistoryByCurrentBook
            ? state.sessionsForBook(currentBook.id)
            : state.sessions;

        final avgPph = state.getAveragePagesPerHourForBook(currentBook.id);
        final avgTimePerPage =
            state.getAverageTimePerPageForBook(currentBook.id);
        final estRemainingTime = state.getEstRemainingTimeForBook(currentBook);
        final estCompletionDate =
            state.getEstCompletionDateForBook(currentBook);
        final totalBookReadingTime =
            state.getTotalReadingTimeFormattedForBook(currentBook.id);
        final consistency = (state.calculateReadingConsistency() * 100).round();
        final streak = state.calculateStreakDays();

        return Scaffold(
          appBar: AppBar(
            title: Text(
               l10n.trackerTitle,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'How speed is calculated',
                icon: const Icon(Icons.info_outline, color: AppColors.primaryGold),
                onPressed: () => _showSpeedCalculationExplainer(context),
              ),
              IconButton(
                tooltip: 'Add Physical Book',
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primaryGold),
                onPressed: () => _showAddBookDialog(context, state),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Physical Book Switcher & Details
                _buildBookSelectorCard(context, state, currentBook, physicalBooks),

                const SizedBox(height: 16),

                // 2. Stopwatch Session Hero Card
                _buildSessionHeroCard(context, state, currentBook),

                const SizedBox(height: 18),

                // 3. Transparent Analytics Grid
                _buildAnalyticsGrid(
                  avgPph: avgPph,
                  avgTimePerPage: avgTimePerPage,
                  estRemainingTime: estRemainingTime,
                  totalBookReadingTime: totalBookReadingTime,
                  onExplainSpeed: () =>
                      _showSpeedCalculationExplainer(context),
                ),

                const SizedBox(height: 18),

                // 4. Reading Consistency & Projected Completion Card
                _buildProjectionsCard(
                  estCompletionDate: estCompletionDate,
                  consistency: consistency,
                  streak: streak,
                  currentBook: currentBook,
                ),

                const SizedBox(height: 22),

                // 5. Reading History Section
                _buildHistorySection(context, state, currentBook, currentSessions),

                const SizedBox(height: 22),

                // 6. Reading Tips Banner
                _buildSpeedTipsSection(),

                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── 1. Book Selector & Details Card ──────────────────────────────────────

  Widget _buildBookSelectorCard(
    BuildContext context,
    AppState state,
    Book currentBook,
    List<Book> physicalBooks,
  ) {
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
          // Header row with book picker & add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PHYSICAL BOOK',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${physicalBooks.length} in catalog',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Edit details',
                    icon: const Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.textMuted),
                    onPressed: () =>
                        _showEditBookDialog(context, state, currentBook),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Switch Book',
                    icon: const Icon(Icons.swap_horiz_rounded,
                        color: AppColors.primaryGold),
                    color: AppColors.darkSurface,
                    onSelected: (bookId) {
                      final chosen =
                          state.books.firstWhere((b) => b.id == bookId);
                      state.setSessionBook(chosen.id, chosen.title);
                    },
                    itemBuilder: (context) {
                      return physicalBooks.map((b) {
                        return PopupMenuItem<String>(
                          value: b.id,
                          child: Row(
                            children: [
                              Icon(
                                b.id == currentBook.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 16,
                                color: b.id == currentBook.id
                                    ? AppColors.primaryGold
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  b.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: b.id == currentBook.id
                                        ? AppColors.primaryGold
                                        : Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Book info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 82,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentBook.coverGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.menu_book, color: Colors.white70, size: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentBook.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      currentBook.author,
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ProgressBarWidget(
                      progress: currentBook.progressPercentage,
                      height: 5,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Page ${currentBook.currentPage} of ${currentBook.totalPages}',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${currentBook.progressPercentInt}% • ${currentBook.remainingPages} pages left',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 2. Stopwatch Session Hero Card ───────────────────────────────────────

  Widget _buildSessionHeroCard(
    BuildContext context,
    AppState state,
    Book currentBook,
  ) {
    Color badgeColor;
    String badgeText;
    if (state.isSessionActive) {
      badgeColor = AppColors.successGreen;
      badgeText = 'SESSION ACTIVE';
    } else if (state.isSessionPaused) {
      badgeColor = AppColors.secondaryAmber;
      badgeText = 'SESSION PAUSED';
    } else {
      badgeColor = Colors.grey;
      badgeText = 'READY TO READ';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: state.isSessionActive
              ? AppColors.primaryGold.withValues(alpha: 0.6)
              : (state.isSessionPaused
                  ? AppColors.secondaryAmber.withValues(alpha: 0.5)
                  : AppColors.darkBorder),
          width: 1.5,
        ),
        boxShadow: [
          if (state.isSessionActive)
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          // Active / Paused Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Monospace Stopwatch Display
          Text(
            state.formattedSessionDuration,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.isSessionActive
                ? 'Tracking live reading pace...'
                : (state.isSessionPaused
                    ? 'Session paused. Tap Resume to continue.'
                    : 'Track your print reading with no PDF needed.'),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!state.isSessionActive && !state.isSessionPaused) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => state.startPhysicalSession(
                      bookId: currentBook.id,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text(
                      'START READING',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Pause / Resume button
                Expanded(
                  child: state.isSessionActive
                      ? ElevatedButton.icon(
                          onPressed: () => state.pausePhysicalSession(),
                          icon: const Icon(Icons.pause_rounded, size: 20),
                          label: const Text('PAUSE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryAmber,
                            foregroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => state.resumePhysicalSession(),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text('RESUME'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            foregroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),

                // Finish / Stop button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showFinishSessionDialog(
                      context,
                      state,
                      currentBook,
                    ),
                    icon: const Icon(Icons.stop_rounded, size: 20),
                    label: const Text('FINISH'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Reset button
                IconButton(
                  tooltip: 'Reset timer',
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.textMuted),
                  onPressed: () {
                    state.resetPhysicalSession();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Session timer reset.'),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── 3. Transparent Analytics Grid ────────────────────────────────────────

  Widget _buildAnalyticsGrid({
    required double avgPph,
    required String avgTimePerPage,
    required String estRemainingTime,
    required String totalBookReadingTime,
    required VoidCallback onExplainSpeed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reading Pace & Calculations',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            InkWell(
              onTap: onExplainSpeed,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  children: const [
                    Icon(Icons.help_outline_rounded,
                        size: 13, color: AppColors.primaryGold),
                    SizedBox(width: 4),
                    Text(
                      'Explain Speed',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            StatCard(
              icon: Icons.speed_rounded,
              value: '${avgPph.toStringAsFixed(1)} PPH',
              label: 'Average Speed',
              subtitle: 'Pages per hour',
              onTap: onExplainSpeed,
            ),
            StatCard(
              icon: Icons.timer_outlined,
              value: avgTimePerPage,
              label: 'Time Per Page',
              subtitle: 'Average pace',
            ),
            StatCard(
              icon: Icons.hourglass_bottom_rounded,
              value: estRemainingTime,
              label: 'Remaining Time',
              subtitle: 'To finish book',
            ),
            StatCard(
              icon: Icons.auto_stories_rounded,
              value: totalBookReadingTime,
              label: 'Total Book Time',
              subtitle: 'Logged reading',
            ),
          ],
        ),
      ],
    );
  }

  // ─── 4. Reading Projections & Consistency ─────────────────────────────────

  Widget _buildProjectionsCard({
    required String estCompletionDate,
    required int consistency,
    required int streak,
    required Book currentBook,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Icon(Icons.insights_rounded,
                  color: AppColors.primaryGold, size: 18),
              SizedBox(width: 8),
              Text(
                'COMPLETION FORECAST & HABIT',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Finish Date',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      estCompletionDate,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: AppColors.darkBorder,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consistency (14d)',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '$consistency%',
                          style: const TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.brightFlame.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '🔥 ${streak}d streak',
                            style: const TextStyle(
                              color: AppColors.brightFlame,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 5. Reading History Section ───────────────────────────────────────────

  Widget _buildHistorySection(
    BuildContext context,
    AppState state,
    Book currentBook,
    List<ReadingSession> sessions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reading History',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('This Book', style: TextStyle(fontSize: 11)),
                  selected: _filterHistoryByCurrentBook,
                  onSelected: (selected) {
                    setState(() {
                      _filterHistoryByCurrentBook = true;
                    });
                  },
                  selectedColor: AppColors.primaryGold.withValues(alpha: 0.2),
                  backgroundColor: AppColors.darkCard,
                  labelStyle: TextStyle(
                    color: _filterHistoryByCurrentBook
                        ? AppColors.primaryGold
                        : AppColors.textMuted,
                    fontWeight: _filterHistoryByCurrentBook
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('All Books', style: TextStyle(fontSize: 11)),
                  selected: !_filterHistoryByCurrentBook,
                  onSelected: (selected) {
                    setState(() {
                      _filterHistoryByCurrentBook = false;
                    });
                  },
                  selectedColor: AppColors.primaryGold.withValues(alpha: 0.2),
                  backgroundColor: AppColors.darkCard,
                  labelStyle: TextStyle(
                    color: !_filterHistoryByCurrentBook
                        ? AppColors.primaryGold
                        : AppColors.textMuted,
                    fontWeight: !_filterHistoryByCurrentBook
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                Icon(Icons.history, color: AppColors.textMuted.withValues(alpha: 0.5), size: 36),
                const SizedBox(height: 8),
                const Text(
                  'No sessions recorded yet',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap "Start Reading" above to log your first physical book session!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = sessions[index];
              final dateStr =
                  '${_formatDate(s.timestamp)} • ${_formatTime(s.timestamp)}';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s.bookTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSessionChip(
                          icon: Icons.timer,
                          label: s.formattedDuration,
                          color: AppColors.textWhite,
                        ),
                        const SizedBox(width: 8),
                        _buildSessionChip(
                          icon: Icons.menu_book,
                          label: s.startPage != null && s.endPage != null
                              ? '+${s.pagesRead} pages (p. ${s.startPage}→${s.endPage})'
                              : '+${s.pagesRead} pages',
                          color: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 8),
                        _buildSessionChip(
                          icon: Icons.speed,
                          label: s.formattedPagesPerHour,
                          color: AppColors.successGreen,
                        ),
                      ],
                    ),
                    if (s.notes != null && s.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '“${s.notes!.trim()}”',
                        style: const TextStyle(
                          color: AppColors.textWarmParchment,
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSessionChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 6. Reading Tips Section ──────────────────────────────────────────────

  Widget _buildSpeedTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.primaryGold, size: 18),
            SizedBox(width: 6),
            Text(
              'Physical Reading Techniques',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTipCard(
                icon: Icons.touch_app,
                title: 'Use a Pointer',
                description:
                    'Guide your eyes with a finger or bookmark along the page to eliminate regressions.',
              ),
              const SizedBox(width: 10),
              _buildTipCard(
                icon: Icons.psychology,
                title: 'Comprehension Guardrail',
                description:
                    'Never sacrifice understanding for raw speed. Speed without retention is lost reading.',
              ),
              const SizedBox(width: 10),
              _buildTipCard(
                icon: Icons.view_column,
                title: 'Chunk Phrases',
                description:
                    'Take in 3-4 words per eye fixation instead of reading individual syllables.',
              ),
              const SizedBox(width: 10),
              _buildTipCard(
                icon: Icons.volume_off,
                title: 'Subvocalization Control',
                description:
                    'Absorb high-frequency words visually rather than pronouncing them internally.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 18),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs & Sheets ─────────────────────────────────────────────────────

  /// 1. Add Physical Book Dialog
  void _showAddBookDialog(BuildContext context, AppState state) {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final totalPagesCtrl = TextEditingController();
    final currentPagesCtrl = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: Row(
            children: const [
              Icon(Icons.bookmark_add, color: AppColors.primaryGold),
              SizedBox(width: 8),
              Text(
                'Add Physical Book',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: const InputDecoration(
                      labelText: 'Book Title',
                      hintText: 'e.g. Sapiens, Atomic Habits',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: authorCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: const InputDecoration(
                      labelText: 'Author Name',
                      hintText: 'e.g. Yuval Noah Harari',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Author is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: totalPagesCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13.5),
                          decoration: const InputDecoration(
                            labelText: 'Total Pages',
                            hintText: 'e.g. 350',
                          ),
                          validator: (val) {
                            final n = int.tryParse(val ?? '');
                            if (n == null || n <= 0) {
                              return 'Enter valid pages';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: currentPagesCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13.5),
                          decoration: const InputDecoration(
                            labelText: 'Current Page',
                            hintText: '0',
                          ),
                          validator: (val) {
                            final n = int.tryParse(val ?? '0');
                            if (n == null || n < 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final total = int.parse(totalPagesCtrl.text.trim());
                  final current = int.parse(currentPagesCtrl.text.trim());
                  final newBook = await state.addPhysicalBook(
                    title: titleCtrl.text.trim(),
                    author: authorCtrl.text.trim(),
                    totalPages: total,
                    currentPage: current,
                  );
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added "${newBook.title}" to your catalog!'),
                    ),
                  );
                }
              },
              child: const Text('Add Book'),
            ),
          ],
        );
      },
    );
  }

  /// 2. Edit Book Dialog
  void _showEditBookDialog(
    BuildContext context,
    AppState state,
    Book currentBook,
  ) {
    final titleCtrl = TextEditingController(text: currentBook.title);
    final authorCtrl = TextEditingController(text: currentBook.author);
    final totalPagesCtrl =
        TextEditingController(text: currentBook.totalPages.toString());
    final currentPagesCtrl =
        TextEditingController(text: currentBook.currentPage.toString());

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text(
            'Edit Book Details',
            style: TextStyle(
              color: AppColors.textWhite,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(labelText: 'Book Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: authorCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: totalPagesCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13.5),
                        decoration:
                            const InputDecoration(labelText: 'Total Pages'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: currentPagesCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13.5),
                        decoration:
                            const InputDecoration(labelText: 'Current Page'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final total = int.tryParse(totalPagesCtrl.text) ??
                    currentBook.totalPages;
                final current = int.tryParse(currentPagesCtrl.text) ??
                    currentBook.currentPage;
                await state.updateBookDetails(
                  bookId: currentBook.id,
                  title: titleCtrl.text,
                  author: authorCtrl.text,
                  totalPages: total,
                  currentPage: current,
                );
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// 3. Finish Session Dialog & Recording Flow
  void _showFinishSessionDialog(
    BuildContext context,
    AppState state,
    Book currentBook,
  ) {
    final startPage = currentBook.currentPage;
    int pagesRead = state.sessionPagesRead > 0 ? state.sessionPagesRead : 15;
    int endPage = (startPage + pagesRead).clamp(0, currentBook.totalPages);
    final durationSec =
        state.sessionDurationSeconds > 0 ? state.sessionDurationSeconds : 900;

    final pagesCtrl = TextEditingController(text: pagesRead.toString());
    final endPageCtrl = TextEditingController(text: endPage.toString());
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            // Live calculated speed metrics
            final durationMin = durationSec / 60.0;
            final durationHrs = durationSec / 3600.0;
            final livePph = durationHrs > 0 ? (pagesRead / durationHrs) : 0.0;
            final liveSecPerPage =
                pagesRead > 0 ? (durationSec / pagesRead.toDouble()).round() : 0;
            final liveTimePerPage = liveSecPerPage > 0
                ? '${liveSecPerPage ~/ 60}m ${(liveSecPerPage % 60).toString().padLeft(2, "0")}s'
                : 'N/A';
            final liveEstWpm = durationMin > 0
                ? ((pagesRead * 250) / durationMin).round()
                : 0;

            void updatePages(int newPages) {
              setModalState(() {
                pagesRead = newPages.clamp(0, currentBook.totalPages - startPage);
                endPage = (startPage + pagesRead).clamp(0, currentBook.totalPages);
                pagesCtrl.text = pagesRead.toString();
                endPageCtrl.text = endPage.toString();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.darkBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Record Reading Session',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            state.formattedSessionDuration,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppColors.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recording for "${currentBook.title}" (Start: Page $startPage)',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Page range inputs
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: pagesCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              labelText: 'Pages Read',
                              prefixIcon: Icon(Icons.auto_stories, size: 18),
                            ),
                            onChanged: (val) {
                              final p = int.tryParse(val) ?? 0;
                              updatePages(p);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: endPageCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              labelText: 'Ending Page',
                              prefixIcon: Icon(Icons.flag_rounded, size: 18),
                            ),
                            onChanged: (val) {
                              final end = int.tryParse(val) ?? startPage;
                              updatePages(end - startPage);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick page increment chips
                    Row(
                      children: [
                        const Text(
                          'Quick add:',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        ...[1, 5, 10, 25].map<Widget>((inc) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () => updatePages(pagesRead + inc),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.darkCard,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: AppColors.darkBorder),
                                ),
                                child: Text(
                                  '+$inc',
                                  style: const TextStyle(
                                    color: AppColors.primaryGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Live calculation metrics card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetricSnippet(
                            label: 'Calculated Speed',
                            value: '${livePph.toStringAsFixed(1)} pph',
                            subtitle: 'Pages per hour',
                          ),
                          _buildMetricSnippet(
                            label: 'Time / Page',
                            value: liveTimePerPage,
                            subtitle: 'Reading pace',
                          ),
                          _buildMetricSnippet(
                            label: 'Est. WPM',
                            value: '~$liveEstWpm WPM',
                            subtitle: '~250 wpp standard',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Optional Notes
                    TextField(
                      controller: notesCtrl,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Session Reflections & Key Takeaways (Optional)',
                        hintText: 'e.g. Finished chapter 5, powerful insight on habit loops...',
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(sheetCtx).pop();

                          final recordedSession =
                              await state.completeAndSaveSession(
                            bookId: currentBook.id,
                            pagesRead: pagesRead,
                            startPage: startPage,
                            endPage: endPage,
                            notes: notesCtrl.text.trim().isNotEmpty
                                ? notesCtrl.text.trim()
                                : null,
                          );

                          if (context.mounted) {
                            _showSessionInsightsDialog(
                              context,
                              state,
                              currentBook,
                              recordedSession,
                            );
                          }
                        },
                        child: const Text(
                          'LOG SESSION & SAVE INSIGHTS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricSnippet({
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
        ),
      ],
    );
  }

  /// 4. Post-Session Insights Dialog (celebration & comprehensive feedback)
  void _showSessionInsightsDialog(
    BuildContext context,
    AppState state,
    Book currentBook,
    ReadingSession session,
  ) {
    final estRemaining = state.getEstRemainingTimeForBook(currentBook);
    final estFinish = state.getEstCompletionDateForBook(currentBook);
    final streak = state.calculateStreakDays();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
          ),
          title: Row(
            children: const [
              Icon(Icons.workspace_premium,
                  color: AppColors.primaryGold, size: 26),
              SizedBox(width: 10),
              Text(
                'Session Insights!',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Achievement Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    children: [
                      Text(
                        ' Pages in ',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ' • ',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Milestone / progress change
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.successGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Now on page ${currentBook.currentPage} of ${currentBook.totalPages} (${currentBook.progressPercentInt}%)',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Streak update
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.brightFlame, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🔥 $streak-day reading streak! Consistency updated.',
                        style: const TextStyle(
                          color: AppColors.brightFlame,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Remaining time & completion forecast
                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        color: AppColors.infoBlue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'At this pace: ~$estRemaining left. Est. finish: $estFinish',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // AI Coach Tip
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.psychology,
                          color: AppColors.primaryGold, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Coach Insight: Take 60 seconds now to mentally summarize the top 3 concepts you just read to lock them into long-term memory.',
                          style: TextStyle(
                            color: AppColors.textWarmParchment,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Awesome!'),
            ),
          ],
        );
      },
    );
  }

  /// 5. Speed Calculation Explainer Modal
  void _showSpeedCalculationExplainer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.menu_book, color: AppColors.primaryGold),
                  SizedBox(width: 8),
                  Text(
                    'Reading Speed Transparency',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Why Pages Per Hour (PPH) is our primary metric for physical books:',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Unlike digital readers where every character and word is indexed in real time, physical paper books have varying typography, font sizes, line spacing, and margin widths across different publisher editions.\n\n'
                'Claiming an exact "words-per-minute" count on paper without scanning the page would be inaccurate. ReadSmart uses transparent, verifiable formulas:',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildFormulaRow(
                formula: 'PPH = (Pages Read / Duration in Hours)',
                description: 'Direct measurement of your physical reading velocity.',
              ),
              const SizedBox(height: 8),
              _buildFormulaRow(
                formula: 'Pace = Duration in Seconds / Pages Read',
                description: 'Average time spent per page (e.g. 1m 45s/page).',
              ),
              const SizedBox(height: 8),
              _buildFormulaRow(
                formula: 'Estimated WPM = (Pages Read × 250) / Minutes',
                description:
                    'Industry standard approximation: trade paperbacks average ~250 words per page.',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormulaRow({
    required String formula,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formula,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppColors.primaryGold,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(dt.year, dt.month, dt.day);

    if (sessionDay == today) return 'Today';
    if (sessionDay == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
