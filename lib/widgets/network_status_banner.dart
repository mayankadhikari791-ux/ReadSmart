import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Non-intrusive status banner indicating offline mode or background sync progress.
class NetworkStatusBanner extends StatelessWidget {
  final bool isOffline;
  final bool isSyncing;
  final String? errorMessage;
  final VoidCallback? onDismissError;
  final VoidCallback? onRetry;

  const NetworkStatusBanner({
    super.key,
    required this.isOffline,
    this.isSyncing = false,
    this.errorMessage,
    this.onDismissError,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && !isSyncing && errorMessage == null) {
      return const SizedBox.shrink();
    }

    Color bgColor = AppColors.darkCardElevated;
    IconData icon = Icons.cloud_off_rounded;
    String text = 'Offline Mode • Local Library Available';
    Widget? action;

    if (errorMessage != null) {
      bgColor = AppColors.dangerRed.withValues(alpha: 0.15);
      icon = Icons.error_outline_rounded;
      text = errorMessage!;
      if (onDismissError != null) {
        action = IconButton(
          icon: const Icon(Icons.close, size: 16, color: AppColors.dangerRed),
          onPressed: onDismissError,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }
    } else if (isSyncing) {
      bgColor = AppColors.infoBlue.withValues(alpha: 0.15);
      icon = Icons.sync_rounded;
      text = 'Syncing reading progress with cloud...';
    } else if (isOffline) {
      bgColor = AppColors.secondaryAmber.withValues(alpha: 0.15);
      icon = Icons.wifi_off_rounded;
      text = 'Offline Mode • All books & notes saved locally';
      if (onRetry != null) {
        action = TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'RETRY',
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: errorMessage != null
                ? AppColors.dangerRed.withValues(alpha: 0.4)
                : AppColors.darkBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}

