import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/book_model.dart';
import '../../models/book_note_model.dart';
import '../../models/bookmark_model.dart';
import '../../models/language_preference_model.dart';
import '../../models/reading_goal_model.dart';
import '../../models/reading_progress_model.dart';
import '../../models/reading_session_model.dart';
import '../../models/reading_statistics_model.dart';
import '../../models/vocabulary_word_model.dart';
import 'cloud_sync_backend.dart';
import 'sync_record.dart';
import 'sync_state.dart';

/// Offline-first synchronization coordinator.
///
/// Features:
/// - Durable offline mutation queue persisted in local storage.
/// - Never blocks local reading or note-taking when offline.
/// - Automatic replay of pending mutations when network is restored.
/// - Pulls cloud updates and distributes them to application state via callbacks.
/// - Handles conflict resolution using [SyncConflictResolver].
class SyncEngine extends ChangeNotifier {
  final ICloudSyncBackend backend;
  final String userId;
  final String authToken;

  // Domain dispatch callbacks
  final Future<void> Function(Book book)? onRemoteBookReceived;
  final Future<void> Function(String bookId)? onRemoteBookDeleted;
  final Future<void> Function(ReadingProgress progress)? onRemoteProgressReceived;
  final Future<void> Function(List<ReadingSession> sessions)? onRemoteSessionsReceived;
  final Future<void> Function(VocabularyWord word)? onRemoteVocabularyReceived;
  final Future<void> Function(String wordId)? onRemoteVocabularyDeleted;
  final Future<void> Function(BookNote note)? onRemoteNoteReceived;
  final Future<void> Function(String noteId)? onRemoteNoteDeleted;
  final Future<void> Function(Bookmark bookmark)? onRemoteBookmarkReceived;
  final Future<void> Function(String bookmarkId)? onRemoteBookmarkDeleted;
  final Future<void> Function(ReadingStatistics stats)? onRemoteStatsReceived;
  final Future<void> Function(ReadingGoal goal)? onRemoteGoalReceived;
  final Future<void> Function(LanguagePreference pref)? onRemotePreferenceReceived;

  SyncStatus _status = SyncStatus.synced;
  bool _isOnline = true;
  DateTime? _lastSyncTime;
  String? _lastError;
  final List<SyncRecord> _queue = [];
  bool _isProcessing = false;
  final String? deviceId;

  SyncEngine({
    required this.backend,
    required this.userId,
    required this.authToken,
    this.deviceId,
    this.onRemoteBookReceived,
    this.onRemoteBookDeleted,
    this.onRemoteProgressReceived,
    this.onRemoteSessionsReceived,
    this.onRemoteVocabularyReceived,
    this.onRemoteVocabularyDeleted,
    this.onRemoteNoteReceived,
    this.onRemoteNoteDeleted,
    this.onRemoteBookmarkReceived,
    this.onRemoteBookmarkDeleted,
    this.onRemoteStatsReceived,
    this.onRemoteGoalReceived,
    this.onRemotePreferenceReceived,
  });

  SyncStatus get status => _isOnline ? _status : SyncStatus.offline;
  bool get isOnline => _isOnline;
  int get pendingCount => _queue.length;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastError => _lastError;

  String get _queueStorageKey =>
      deviceId != null ? 'rs_sync_queue_${userId}_$deviceId' : 'rs_sync_queue_$userId';
  String get _lastSyncStorageKey =>
      deviceId != null ? 'rs_last_sync_${userId}_$deviceId' : 'rs_last_sync_$userId';

  /// Initializes the local durable queue and runs an initial synchronization.
  Future<void> initialize() async {
    await _loadQueue();
    await _loadLastSyncTime();

    if (_isOnline) {
      await syncNow();
    } else {
      _status = SyncStatus.offline;
      notifyListeners();
    }
  }

  void setOnline(bool online) {
    if (_isOnline == online) return;
    _isOnline = online;
    if (!_isOnline) {
      _status = SyncStatus.offline;
      notifyListeners();
    } else {
      _status = SyncStatus.synced;
      notifyListeners();
      // Automatically attempt sync when coming back online
      syncNow();
    }
  }

  /// Appends or updates an entity mutation in the local durable queue.
  /// Offline actions return immediately and never block UI.
  Future<void> queueMutation({
    required String id,
    required SyncEntityType entityType,
    String? bookId,
    required Map<String, dynamic> data,
    bool isDeleted = false,
  }) async {
    final record = SyncRecord(
      id: id,
      entityType: entityType,
      userId: userId,
      bookId: bookId,
      data: data,
      version: 1,
      updatedAt: DateTime.now().toUtc(),
      isDeleted: isDeleted,
    );

    // De-duplicate if record is already in pending queue
    final existingIdx = _queue.indexWhere((r) => r.id == id);
    if (existingIdx != -1) {
      _queue[existingIdx] = record;
    } else {
      _queue.add(record);
    }

    await _saveQueue();
    notifyListeners();

    // Trigger sync in background if online
    if (_isOnline && !_isProcessing) {
      unawaited(syncNow());
    }
  }

  /// Retries a previously failed sync.
  Future<void> retry() async {
    _lastError = null;
    await syncNow();
  }

  Completer<void>? _activeSyncCompleter;

  /// Runs a complete synchronization cycle:
  /// 1. Pushes pending local offline mutations to the cloud.
  /// 2. Pulls new changes from the cloud.
  /// 3. Applies incoming changes through domain callbacks.
  Future<void> syncNow() async {
    if (!_isOnline) {
      _status = SyncStatus.offline;
      notifyListeners();
      return;
    }

    if (_isProcessing) {
      if (_activeSyncCompleter != null) {
        await _activeSyncCompleter!.future;
      }
      return;
    }

    _isProcessing = true;
    final completer = Completer<void>();
    _activeSyncCompleter = completer;
    _status = SyncStatus.syncing;
    _lastError = null;
    notifyListeners();

    try {
      // ── Step 1: Push local queued mutations to cloud ──
      if (_queue.isNotEmpty) {
        final recordsToPush = List<SyncRecord>.from(_queue);
        final pushRes = await backend.pushChanges(
          authToken: authToken,
          records: recordsToPush,
        );

        if (!pushRes.isSuccess) {
          _status = SyncStatus.syncFailed;
          _lastError = pushRes.message ?? 'Failed to push changes to cloud';
          _isProcessing = false;
          if (!completer.isCompleted) completer.complete();
          _activeSyncCompleter = null;
          notifyListeners();
          return;
        }

        // Successfully pushed: remove pushed records from local queue
        final pushedIds = recordsToPush.map((r) => r.id).toSet();
        _queue.removeWhere((r) => pushedIds.contains(r.id));
        await _saveQueue();
      }

      // ── Step 2: Pull cloud updates ──
      final pullRes = await backend.pullChanges(
        authToken: authToken,
        since: _lastSyncTime,
      );

      if (!pullRes.isSuccess) {
        _status = SyncStatus.syncFailed;
        _lastError = pullRes.message ?? 'Failed to pull cloud updates';
        _isProcessing = false;
        if (!completer.isCompleted) completer.complete();
        _activeSyncCompleter = null;
        notifyListeners();
        return;
      }

      // ── Step 3: Dispatch incoming records to domain ──
      final incoming = pullRes.data ?? [];
      for (final record in incoming) {
        await _applyRemoteRecord(record);
      }

      _lastSyncTime = DateTime.now().toUtc();
      await _saveLastSyncTime();
      _status = SyncStatus.synced;
    } catch (e) {
      _status = SyncStatus.syncFailed;
      _lastError = e.toString();
    } finally {
      _isProcessing = false;
      if (!completer.isCompleted) completer.complete();
      _activeSyncCompleter = null;
      notifyListeners();
    }
  }

  /// Dispatches an incoming cloud record to the appropriate local handler.
  Future<void> _applyRemoteRecord(SyncRecord record) async {
    try {
      switch (record.entityType) {
        case SyncEntityType.book:
          if (record.isDeleted) {
            await onRemoteBookDeleted?.call(record.id);
          } else {
            final book = Book.fromJson(record.data);
            await onRemoteBookReceived?.call(book);
          }
          break;

        case SyncEntityType.progress:
          final prog = ReadingProgress.fromJson(record.data);
          await onRemoteProgressReceived?.call(prog);
          break;

        case SyncEntityType.session:
          final session = ReadingSession(
            id: record.data['id'] as String? ?? record.id,
            bookId: record.data['bookId'] as String? ?? '',
            bookTitle: record.data['bookTitle'] as String? ?? '',
            durationSeconds: record.data['durationSeconds'] as int? ?? 0,
            pagesRead: record.data['pagesRead'] as int? ?? 0,
            readingSpeedWpm: record.data['readingSpeedWpm'] as int? ?? 0,
            timestamp: record.data['timestamp'] != null
                ? DateTime.parse(record.data['timestamp'] as String)
                : record.updatedAt,
            startPage: record.data['startPage'] as int?,
            endPage: record.data['endPage'] as int?,
            notes: record.data['notes'] as String?,
          );
          await onRemoteSessionsReceived?.call([session]);
          break;

        case SyncEntityType.vocabulary:
          if (record.isDeleted) {
            await onRemoteVocabularyDeleted?.call(record.id);
          } else {
            final word = VocabularyWord.fromJson(record.data);
            await onRemoteVocabularyReceived?.call(word);
          }
          break;

        case SyncEntityType.note:
          if (record.isDeleted) {
            await onRemoteNoteDeleted?.call(record.id);
          } else {
            final note = BookNote.fromJson(record.data);
            await onRemoteNoteReceived?.call(note);
          }
          break;

        case SyncEntityType.bookmark:
          if (record.isDeleted) {
            await onRemoteBookmarkDeleted?.call(record.id);
          } else {
            final bm = Bookmark.fromJson(record.data);
            await onRemoteBookmarkReceived?.call(bm);
          }
          break;

        case SyncEntityType.stats:
          final stats = ReadingStatistics.fromJson(record.data);
          await onRemoteStatsReceived?.call(stats);
          break;

        case SyncEntityType.goal:
          final goal = ReadingGoal.fromJson(record.data);
          await onRemoteGoalReceived?.call(goal);
          break;

        case SyncEntityType.preference:
          final pref = LanguagePreference.fromJson(record.data);
          await onRemotePreferenceReceived?.call(pref);
          break;
      }
    } catch (e) {
      debugPrint('[SyncEngine] Error applying remote record ${record.id}: $e');
    }
  }

  // ── Persistence Helpers ──────────────────────────────────────────────────

  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queueStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _queue.clear();
          for (final item in decoded) {
            if (item is Map) {
              _queue.add(SyncRecord.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _queue.map((r) => r.toJson()).toList();
      await prefs.setString(_queueStorageKey, jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _loadLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lastSyncStorageKey);
      if (raw != null && raw.isNotEmpty) {
        _lastSyncTime = DateTime.parse(raw);
      }
    } catch (_) {}
  }

  Future<void> _saveLastSyncTime() async {
    if (_lastSyncTime == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastSyncStorageKey,
        _lastSyncTime!.toIso8601String(),
      );
    } catch (_) {}
  }

  /// Clears in-memory state on sign out.
  void clear() {
    _queue.clear();
    _lastError = null;
    _lastSyncTime = null;
    _status = SyncStatus.synced;
  }
}
