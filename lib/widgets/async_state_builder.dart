import 'package:flutter/material.dart';
import '../core/network/resource.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Standardized builder widget for cleanly handling loading spinners, error states
/// (with retry button and cached data display), and success content.
class AsyncStateBuilder<T> extends StatelessWidget {
  final Resource<T> resource;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, String? message)? loadingBuilder;
  final Widget Function(BuildContext context, String message, VoidCallback? onRetry)?
      errorBuilder;
  final VoidCallback? onRetry;

  const AsyncStateBuilder({
    super.key,
    required this.resource,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Loading State
    if (resource.isLoading && !resource.hasData) {
      if (loadingBuilder != null) {
        return loadingBuilder!(context, resource.message);
      }
      return Center(
        child: Padding(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                ),
              ),
              if (resource.message != null) ...[
                const SizedBox(height: 14),
                Text(
                  resource.message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 2. Error State (when NO cached data is available)
    if (resource.isError && !resource.hasData) {
      final message = resource.message ?? 'An error occurred. Please try again.';
      if (errorBuilder != null) {
        return errorBuilder!(context, message, onRetry);
      }
      return Center(
        child: Padding(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.dangerRed.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.dangerRed,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                  height: 1.4,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: const Color(0xFF141414),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

    // 3. Success (or Error with cached data)
    if (resource.hasData) {
      return builder(context, resource.data as T);
    }

    // 4. Initial / Empty
    return const SizedBox.shrink();
  }
}
