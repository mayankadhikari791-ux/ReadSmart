import 'package:flutter/material.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../models/reading_analytics_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/analytics_time_chart.dart';
import '../widgets/reading_consistency_chart.dart';
import '../widgets/reading_speed_chart.dart';
import '../widgets/intelligent_insights_card.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/stat_card.dart';
import 'coach_screen.dart';

class StatsScreen extends StatefulWidget {
  final AppState appState;

  const StatsScreen({super.key, required this.appState});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  AnalyticsTimeframe _selectedTimeframe = AnalyticsTimeframe.thisWeek;
  AnalyticsChartType _selectedChartMetric = AnalyticsChartType.readingTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = widget.appState;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final timeBreakdown = appState.readingTimeBreakdown;
        final dailyRecords = appState.getDailyReadingHistory(
          days: _selectedTimeframe == AnalyticsTimeframe.thisWeek
              ? 7
              : (_selectedTimeframe == AnalyticsTimeframe.thisMonth ? 14 : 28),
        );
        final insights = appState.generateIntelligentImprovementInsights();

        // Selected period values
        String selectedPeriodReadingTime;
        int selectedPeriodPages;
        String periodSubtitle;

        switch (_selectedTimeframe) {
          case AnalyticsTimeframe.thisWeek:
            selectedPeriodReadingTime = timeBreakdown.weeklyFormatted;
            selectedPeriodPages = appState.totalPagesReadThisWeek;
            periodSubtitle = 'This week';
            break;
          case AnalyticsTimeframe.thisMonth:
            selectedPeriodReadingTime = timeBreakdown.monthlyFormatted;
            selectedPeriodPages = appState.totalPagesReadThisMonth;
            periodSubtitle = 'This month';
            break;
          case AnalyticsTimeframe.allTime:
            selectedPeriodReadingTime = timeBreakdown.allTimeFormatted;
            selectedPeriodPages = appState.totalPagesReadOverall;
            periodSubtitle = 'All time';
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.statsTitle,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.psychology_outlined, color: AppColors.primaryGold),
                tooltip: 'Reading Coach',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoachScreen(appState: appState),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Timeframe Pill Selector (This Week, This Month, All Time)
                _buildTimeframeSelector(),

                const SizedBox(height: 14),

                // 2. Hero Streak & Reading Consistency Banner
                _buildStreakCard(appState),

                const SizedBox(height: 18),

                // 3. Core Reading Time & Pages Metric Grid (4 Cards)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.45,
                  children: [
                    StatCard(
                      icon: Icons.schedule_rounded,
                      value: selectedPeriodReadingTime,
                      label: 'Reading Time',
                      subtitle: periodSubtitle,
                    ),
                    StatCard(
                      icon: Icons.menu_book_rounded,
                      value: '$selectedPeriodPages',
                      label: l10n.statsPagesRead,
                      subtitle: periodSubtitle,
                    ),
                    StatCard(
                      icon: Icons.hourglass_top_rounded,
                      value: appState.avgSessionDuration,
                      label: l10n.statsAvgSession,
                      subtitle: '${appState.averagePagesPerSession.toStringAsFixed(1)} pages/session',
                    ),
                    StatCard(
                      icon: Icons.speed_rounded,
                      value: '${appState.averagePagesPerHourOverall.toStringAsFixed(1)} pph',
                      label: 'Reading Pace',
                      subtitle: 'Pages per hour',
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 4. Books Progress Summary Bar (Started vs Completed)
                _buildBookVolumeCard(appState),

                const SizedBox(height: 18),

                // 5. Interactive Activity Chart Card (Time / Pages toggle)
                Container(
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
                          Text(
                            _selectedChartMetric == AnalyticsChartType.readingTime
                                ? 'Reading Time Over Time'
                                : 'Pages Read Per Day',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                          Row(
                            children: [
                              _buildMetricTab('Minutes', AnalyticsChartType.readingTime),
                              const SizedBox(width: 6),
                              _buildMetricTab('Pages', AnalyticsChartType.pagesRead),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnalyticsTimeChart(
                        records: dailyRecords,
                        chartType: _selectedChartMetric,
                        goalDailyTarget: _selectedChartMetric == AnalyticsChartType.readingTime ? 30 : 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 6. Reading Speed Trend Card
                Container(
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
                          const Flexible(
                            child: Text(
                              'Reading Speed Trend',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'WPM • Pace',
                              style: TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ReadingSpeedChart(weeklyWpm: appState.weeklyWpmTrend),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 7. Reading Consistency Matrix Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reading Consistency',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ReadingConsistencyChart(
                        records: appState.getDailyReadingHistory(days: 14),
                        consistencyScore: appState.calculateReadingConsistency(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 8. Book Completion Progress Section
                _buildActiveBooksProgressCard(appState),

                const SizedBox(height: 18),

                // 9. Intelligent Reading Improvement Section
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Intelligent Reading Improvement',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Actionable insights based on your reading patterns with comprehension-first guardrails.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                IntelligentInsightsCard(insights: insights),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTimeframePill('This Week', AnalyticsTimeframe.thisWeek),
          _buildTimeframePill('This Month', AnalyticsTimeframe.thisMonth),
          _buildTimeframePill('All Time', AnalyticsTimeframe.allTime),
        ],
      ),
    );
  }

  Widget _buildTimeframePill(String title, AnalyticsTimeframe timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTimeframe = timeframe),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTab(String title, AnalyticsChartType metric) {
    final isSelected = _selectedChartMetric == metric;
    return InkWell(
      onTap: () => setState(() => _selectedChartMetric = metric),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
            width: 0.8,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGold : AppColors.textMuted,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brightFlame.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brightFlame.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${appState.dayStreak} Day Streak!',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brightFlame.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: AppColors.brightFlame,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day stars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final isDone = i < appState.dayStreak.clamp(0, 7);
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.brightFlame : AppColors.darkSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.star,
                        size: 16,
                        color: isDone ? Colors.black : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days[i],
                    style: TextStyle(
                      color: isDone ? AppColors.textWhite : AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            appState.dayStreak > 0
                ? 'Keep going! Read today to extend your streak to ${appState.dayStreak + 1} days.'
                : 'Start a reading session today to begin your streak!',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBookVolumeCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Books In Progress',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appState.booksStartedCount} Started',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.darkBorder),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Books Completed',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${appState.booksCompletedCount} Finished',
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBooksProgressCard(AppState appState) {
    final activeBooks = appState.books.where((b) => b.currentPage < b.totalPages).take(4).toList();

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
              const Text(
                'Book Completion Progress',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              Text(
                '${activeBooks.length} active',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (activeBooks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'All books completed! Add new books in the library.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            )
          else
            ...activeBooks.map((book) {
              final estRemaining = appState.getEstRemainingTimeForBook(book);
              final progress = book.progressPercentage;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            estRemaining,
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ProgressBarWidget(progress: progress, height: 4),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${book.currentPage} of ${book.totalPages} pages',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                        ),
                        Text(
                          '${book.progressPercentInt}%',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
