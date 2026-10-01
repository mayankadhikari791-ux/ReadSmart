import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class ComprehensionCheckDialog extends StatefulWidget {
  final AppState appState;

  const ComprehensionCheckDialog({super.key, required this.appState});

  static Future<void> show(BuildContext context, AppState appState) {
    return showDialog(
      context: context,
      builder: (_) => ComprehensionCheckDialog(appState: appState),
    );
  }

  @override
  State<ComprehensionCheckDialog> createState() =>
      _ComprehensionCheckDialogState();
}

class _ComprehensionCheckDialogState extends State<ComprehensionCheckDialog> {
  int _ratingStars = 4;
  final TextEditingController _notesController = TextEditingController();
  late String _selectedBookTitle;

  @override
  void initState() {
    super.initState();
    _selectedBookTitle = widget.appState.currentlyReadingBook.title;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getRetentionLabel(int stars) {
    switch (stars) {
      case 1:
        return '1/5 • Skimmed / Low Recall';
      case 2:
        return '2/5 • Vague Outline / Few Details';
      case 3:
        return '3/5 • Understood Core Ideas';
      case 4:
        return '4/5 • Strong Retention & Details';
      case 5:
        return '5/5 • Complete Synthesis & Mastery';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.infoBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.infoBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Comprehension Check',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Take 30 seconds to reflect on your retention. This keeps reading active and updates your personalized coach recommendations.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Book Title
              Text(
                'Book: $_selectedBookTitle',
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),

              // Rating Stars
              const Text(
                'How clearly can you recall what you just read?',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return IconButton(
                    icon: Icon(
                      star <= _ratingStars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.primaryGold,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _ratingStars = star;
                      });
                    },
                  );
                }),
              ),
              Center(
                child: Text(
                  _getRetentionLabel(_ratingStars),
                  style: const TextStyle(
                    color: AppColors.secondaryAmber,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 1-Sentence Synthesis
              const Text(
                '1-Sentence Synthesis (Feynman Reflection)',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g., The protagonist learned that true mastery requires deliberate patience...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.darkBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primaryGold),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final notes = _notesController.text.trim().isEmpty
                        ? 'Chapter reflection logged.'
                        : _notesController.text.trim();
                    widget.appState.logComprehensionAssessment(
                      bookTitle: _selectedBookTitle,
                      ratingStars: _ratingStars,
                      notes: notes,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Comprehension score logged! (${_ratingStars * 20}%)',
                        ),
                        backgroundColor: AppColors.darkCard,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Save Reflection & Update Coach',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

