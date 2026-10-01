import 'package:flutter/material.dart';

/// Represents the synchronization status of the user's reading data.
enum SyncStatus {
  synced,
  syncing,
  offline,
  syncFailed;

  String get label {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.syncFailed:
        return 'Sync Failed';
    }
  }

  IconData get icon {
    switch (this) {
      case SyncStatus.synced:
        return Icons.cloud_done_rounded;
      case SyncStatus.syncing:
        return Icons.sync_rounded;
      case SyncStatus.offline:
        return Icons.cloud_off_rounded;
      case SyncStatus.syncFailed:
        return Icons.sync_problem_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SyncStatus.synced:
        return const Color(0xFF10B981); // Emerald green
      case SyncStatus.syncing:
        return const Color(0xFF3B82F6); // Blue
      case SyncStatus.offline:
        return const Color(0xFF9CA3AF); // Muted grey
      case SyncStatus.syncFailed:
        return const Color(0xFFEF4444); // Red
    }
  }
}
