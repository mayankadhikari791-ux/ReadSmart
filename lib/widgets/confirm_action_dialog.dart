import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// A professional confirmation dialog for destructive actions.
/// Shows title, message, an optional safety note, and a red destructive button.
class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? safetyNote;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    this.safetyNote,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
  });

  /// Convenience static method — shows the dialog and returns true if confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? safetyNote,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmActionDialog(
        title: title,
        message: message,
        safetyNote: safetyNote,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.roundedXl,
        side: const BorderSide(color: AppColors.darkBorder, width: 0.8),
      ),
      child: Padding(
        padding: AppSpacing.dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.dangerRed.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.dangerRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Message
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),

            // Safety note (green reassurance box)
            if (safetyNote != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.10),
                  borderRadius: AppRadius.roundedSm,
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.successGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        safetyNote!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.successGreen,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.darkBorder),
                      foregroundColor: AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedLg,
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedLg,
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
