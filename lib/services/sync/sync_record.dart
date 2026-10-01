import '../../models/reading_progress_model.dart';
import '../../models/reading_session_model.dart';

/// The types of domain entities synchronized between client and cloud.
enum SyncEntityType {
  book,
  progress,
  session,
  bookmark,
  vocabulary,
  note,
  stats,
  goal,
  preference;

  String get name => toString().split('.').last;

  static SyncEntityType fromString(String val) {
    return SyncEntityType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => SyncEntityType.book,
    );
  }
}

/// A versioned, timestamped record representing an entity state change.
/// Supports tombstones for reliable offline deletions across devices.
class SyncRecord {
  final String id;
  final SyncEntityType entityType;
  final String userId;
  final String? bookId;
  final Map<String, dynamic> data;
  final int version;
  final DateTime updatedAt;
  final bool isDeleted;

  const SyncRecord({
    required this.id,
    required this.entityType,
    required this.userId,
    this.bookId,
    required this.data,
    this.version = 1,
    required this.updatedAt,
    this.isDeleted = false,
  });

  SyncRecord copyWith({
    String? id,
    SyncEntityType? entityType,
    String? userId,
    String? bookId,
    Map<String, dynamic>? data,
    int? version,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return SyncRecord(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      data: data ?? this.data,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.name,
      'userId': userId,
      if (bookId != null) 'bookId': bookId,
      'data': data,
      'version': version,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory SyncRecord.fromJson(Map<String, dynamic> json) {
    return SyncRecord(
      id: json['id'] as String,
      entityType: SyncEntityType.fromString(json['entityType'] as String),
      userId: json['userId'] as String? ?? '',
      bookId: json['bookId'] as String?,
      data: json['data'] != null ? Map<String, dynamic>.from(json['data'] as Map) : {},
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now().toUtc(),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

/// Resolves synchronization conflicts across multiple devices without data loss.
class SyncConflictResolver {
  /// Reading progress resolution:
  /// The furthest page read wins so user progress never rolls backwards.
  /// If current page is identical, the one with the latest timestamp wins.
  static ReadingProgress resolveReadingProgress(
    ReadingProgress local,
    ReadingProgress remote,
  ) {
    if (remote.currentPage > local.currentPage) {
      return remote;
    } else if (local.currentPage > remote.currentPage) {
      return local;
    } else {
      return remote.lastReadTimestamp.isAfter(local.lastReadTimestamp)
          ? remote
          : local;
    }
  }

  /// Last-Write-Wins (LWW) conflict resolution for book metadata, notes, and preferences.
  static SyncRecord resolveLWW(SyncRecord local, SyncRecord remote) {
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      return remote;
    }
    return local;
  }

  /// Additive union merge for reading sessions:
  /// No reading session is ever discarded. If session IDs collide, keep the one
  /// with longer duration or later timestamp.
  static List<ReadingSession> mergeSessions(
    List<ReadingSession> local,
    List<ReadingSession> remote,
  ) {
    final Map<String, ReadingSession> merged = {};
    for (final s in local) {
      merged[s.id] = s;
    }
    for (final r in remote) {
      if (!merged.containsKey(r.id)) {
        merged[r.id] = r;
      } else {
        final existing = merged[r.id]!;
        if (r.durationSeconds > existing.durationSeconds ||
            r.timestamp.isAfter(existing.timestamp)) {
          merged[r.id] = r;
        }
      }
    }
    final list = merged.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Tombstone vs edit conflict resolution:
  /// If an item was deleted on device A at time T1, but updated on device B at time T2:
  /// If T2 > T1, the edit wins (item is restored).
  /// If T1 >= T2, the tombstone wins (item stays deleted).
  static bool shouldTombstoneWin(SyncRecord local, SyncRecord remote) {
    if (local.isDeleted && !remote.isDeleted) {
      return !remote.updatedAt.isAfter(local.updatedAt);
    }
    if (!local.isDeleted && remote.isDeleted) {
      return remote.updatedAt.isAfter(local.updatedAt);
    }
    return local.isDeleted || remote.isDeleted;
  }
}
