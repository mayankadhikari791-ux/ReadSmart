import 'package:flutter/material.dart';
import '../models/coach_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/coach_goal_card.dart';
import '../widgets/comprehension_check_dialog.dart';
import '../widgets/radial_score_gauge.dart';
import 'notes_screen.dart';

class CoachScreen extends StatefulWidget {
  final AppState appState;

  const CoachScreen({super.key, required this.appState});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  CoachRecommendationCategory? _selectedCategory;

  void _handleCoachAction(CoachActionType type) {
    switch (type) {
      case CoachActionType.testComprehension:
        ComprehensionCheckDialog.show(context, widget.appState);
        break;
      case CoachActionType.startSprint:
        widget.appState.startPhysicalSession();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⏱️ 20-minute Reading Sprint timer started!'),
            backgroundColor: AppColors.darkCard,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View',
              textColor: AppColors.primaryGold,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
        break;
      case CoachActionType.reviewFlashcards:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NotesScreen(appState: widget.appState),
          ),
        );
        break;
      case CoachActionType.openDistractionSettings:
        widget.appState.setThemeMode(ReadingThemeMode.sepia);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌙 Switched to Warm Sepia reading theme for eye comfort!'),
            backgroundColor: AppColors.darkCard,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case CoachActionType.browseLibrary:
      case CoachActionType.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final allRecommendations =
            state.generatePersonalizedCoachRecommendations();
        final filteredRecommendations = _selectedCategory == null
            ? allRecommendations
            : allRecommendations
                .where((r) => r.category == _selectedCategory)
                .toList();

        final goals = state.coachGoals;
        final completedGoalsCount = goals.where((g) => g.isCompleted).length;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkBackground,
            elevation: 0,
            title: const Text(
              'Personalized Reading Coach',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.rate_review_outlined, color: AppColors.primaryGold),
                tooltip: 'Comprehension Check',
                onPressed: () =>
                    ComprehensionCheckDialog.show(context, state),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Diagnostic Profile Hero Header
                _buildHeroCard(state),

                const SizedBox(height: 14),

                // 2. Strict Comprehension-First Guardrail Banner
                _buildGuardrailBanner(),

                const SizedBox(height: 20),

                // 3. Simple Daily Goals Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Reading Goals',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: completedGoalsCount == goals.length
                            ? AppColors.successGreen.withValues(alpha: 0.18)
                            : AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$completedGoalsCount of ${goals.length} Completed',
                        style: TextStyle(
                          color: completedGoalsCount == goals.length
                              ? AppColors.successGreen
                              : AppColors.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5 Daily Goals Cards
                ...goals.map((goal) => CoachGoalCard(
                      goal: goal,
                      onToggle: goal.type == CoachGoalType.finishChapter
                          ? () => state.toggleChapterGoalCompleted()
                          : null,
                    )),

                const SizedBox(height: 20),

                // 4. Personalized Practical Recommendations
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Targeted Recommendations',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    Text(
                      '${filteredRecommendations.length} active',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: const Text('All (7)'),
                          selected: _selectedCategory == null,
                          selectedColor: AppColors.primaryGold,
                          labelStyle: TextStyle(
                            color: _selectedCategory == null
                                ? Colors.black
                                : Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                          backgroundColor: AppColors.darkCard,
                          side: BorderSide(
                            color: _selectedCategory == null
                                ? AppColors.primaryGold
                                : AppColors.darkBorder,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedCategory = null);
                          },
                        ),
                      ),
                      ...CoachRecommendationCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: FilterChip(
                            avatar: Icon(cat.defaultIcon,
                                size: 14,
                                color: isSelected
                                    ? Colors.black
                                    : AppColors.primaryGold),
                            label: Text(cat.label),
                            selected: isSelected,
                            selectedColor: AppColors.primaryGold,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                            backgroundColor: AppColors.darkCard,
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryGold
                                  : AppColors.darkBorder,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? cat : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Recommendation Cards
                ...filteredRecommendations.map((rec) => _buildRecommendationCard(rec)),

                const SizedBox(height: 16),

                // Comprehension Check Trigger Card
                _buildComprehensionCheckCTA(state),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.primaryGold, width: 4),
          top: BorderSide(color: AppColors.darkBorder),
          right: BorderSide(color: AppColors.darkBorder),
          bottom: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '👋 Hey Mayank!',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Speed: ${state.averageWpm} WPM • Streak: ${state.readingStreakDays}d • Vocab: ${state.totalVocabularyCount} words',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Analytical Deep Reader • High Retention',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          RadialScoreGauge(score: state.userReadingScore, size: 84),
        ],
      ),
    );
  }

  Widget _buildGuardrailBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231A0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brightFlame.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology, color: AppColors.brightFlame, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Comprehension Always Precedes Speed',
                  style: TextStyle(
                    color: AppColors.brightFlame,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'ReadSmart never recommends sacrificing comprehension purely to increase reading speed. True mastery is the effortless absorption and retention of ideas.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(CoachRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rec.isComprehensionGuardrail
              ? AppColors.brightFlame.withValues(alpha: 0.5)
              : AppColors.darkBorder,
          width: rec.isComprehensionGuardrail ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: rec.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(rec.icon, color: rec.accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.title,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rec.category.label,
                      style: TextStyle(
                        color: rec.accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (rec.isComprehensionGuardrail)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brightFlame.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Guardrail',
                    style: TextStyle(
                      color: AppColors.brightFlame,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // User Data Evidence Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined,
                    size: 14, color: AppColors.primaryGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rec.dataEvidence,
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Actionable Recommendation
          Text(
            rec.recommendation,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              height: 1.45,
            ),
          ),

          if (rec.actionLabel != null && rec.actionType != CoachActionType.none) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: rec.accentColor.withValues(alpha: 0.15),
                  foregroundColor: rec.accentColor,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: rec.accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: Text(
                  rec.actionLabel!,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _handleCoachAction(rec.actionType),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComprehensionCheckCTA(AppState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.infoBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppColors.infoBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comprehension Reflection',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.latestComprehensionLog != null
                      ? 'Last check: ${state.latestComprehensionLog!.score}% (${state.latestComprehensionLog!.bookTitle})'
                      : 'Take 30 seconds to rate retention & summarize a chapter.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.infoBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => ComprehensionCheckDialog.show(context, state),
            child: const Text('Check', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
