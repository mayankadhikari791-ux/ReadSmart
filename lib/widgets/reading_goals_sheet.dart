import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

/// Modal bottom sheet for configuring daily reading time and annual books goals.
class ReadingGoalsSheet extends StatefulWidget {
  final AppState appState;

  const ReadingGoalsSheet({super.key, required this.appState});

  static Future<void> show(BuildContext context, AppState appState) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReadingGoalsSheet(appState: appState),
    );
  }

  @override
  State<ReadingGoalsSheet> createState() => _ReadingGoalsSheetState();
}

class _ReadingGoalsSheetState extends State<ReadingGoalsSheet> {
  late double _dailyMinutes;
  late double _annualBooks;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dailyMinutes = widget.appState.dailyGoalMinutes.toDouble().clamp(5.0, 180.0);
    _annualBooks = widget.appState.annualBooksGoal.toDouble().clamp(1.0, 100.0);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.appState.updateDailyGoal(_dailyMinutes.round());
    await widget.appState.updateAnnualGoal(_annualBooks.round());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottom),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Reading Goals',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Personalize your daily routine and long-term milestones. Consistency over speed builds lasting reading habits.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Daily reading goal slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAILY READING TARGET',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${_dailyMinutes.round()} mins / day',
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryGold,
              inactiveTrackColor: AppColors.darkSurface,
              thumbColor: AppColors.primaryGold,
              overlayColor: AppColors.primaryGold.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _dailyMinutes,
              min: 5,
              max: 180,
              divisions: 35,
              onChanged: (val) => setState(() => _dailyMinutes = val),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('5m (Casual)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                Text('30m (Recommended)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                Text('3h (Deep)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Annual books goal slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ANNUAL BOOKS TARGET',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.secondaryAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${_annualBooks.round()} books / year',
                  style: const TextStyle(
                    color: AppColors.secondaryAmber,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondaryAmber,
              inactiveTrackColor: AppColors.darkSurface,
              thumbColor: AppColors.secondaryAmber,
              overlayColor: AppColors.secondaryAmber.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _annualBooks,
              min: 1,
              max: 100,
              divisions: 99,
              onChanged: (val) => setState(() => _annualBooks = val),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 book', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                Text('24 books (2/mo)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                Text('100 books', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'SAVE READING GOALS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

