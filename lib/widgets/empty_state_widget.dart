import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Commercial-grade empty state presentation widget.
/// Used for empty libraries, zero search results, no saved vocabulary, and empty reading history.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primaryGold;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ambient icon badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveIconColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),

            // Optional Call-To-Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: const Color(0xFF141414),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedLg,
                  ),
                  textStyle: AppTypography.labelLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

