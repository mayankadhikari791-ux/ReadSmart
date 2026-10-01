import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/network_exceptions.dart';
import '../../core/network/resource.dart';
import '../auth/auth_session_manager.dart';
import 'sync_record.dart';

/// Abstract contract for cloud synchronization backend.
abstract class ICloudSyncBackend {
  /// Pushes client changes to the cloud.
  /// Server validates [authToken] and determines the user's identity securely.
  Future<Resource<List<SyncRecord>>> pushChanges({
    required String authToken,
    required List<SyncRecord> records,
  });

  /// Pulls changes updated after [since] from the cloud for the authenticated user.
  Future<Resource<List<SyncRecord>>> pullChanges({
    required String authToken,
    DateTime? since,
  });

  /// Wipes all cloud data for the authenticated user.
  Future<Resource<void>> clearUserData({required String authToken});

  /// Retrieves all records for the authenticated user.
  Future<Resource<List<SyncRecord>>> getAllUserData({required String authToken});
}

/// Simulated cloud backend with strict server-side session token validation
/// and per-user isolated cloud partitions.
///
/// Security:
/// - Never trusts client-supplied `userId` values.
/// - Validates [authToken] against [AuthSessionManager.validateServerSession].
/// - Server stamps and enforces the verified `userId` on every record.
/// - Data for User A is physically separated from User B (`rs_cloud_data_<userId>`).
class CloudSyncBackend implements ICloudSyncBackend {
  static const String _kCloudPrefix = 'rs_cloud_data_';

  // In-memory fallback registry if SharedPreferences is unavailable in pure tests
  final Map<String, Map<String, SyncRecord>> _inMemoryPartitions = {};

  String _storageKey(String verifiedUserId) => '$_kCloudPrefix$verifiedUserId';

  /// Validates session token on the simulated server and returns the verified user ID.
  Future<String?> _authenticateToken(String token) async {
    if (token.isEmpty) return null;
    return await AuthSessionManager.validateServerSession(token);
  }

  /// Loads all stored records for [verifiedUserId].
  Future<Map<String, SyncRecord>> _loadPartition(String verifiedUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey(verifiedUserId);
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final result = <String, SyncRecord>{};
          decoded.forEach((k, v) {
            if (v is Map) {
              result[k.toString()] = SyncRecord.fromJson(Map<String, dynamic>.from(v));
            }
          });
          return result;
        }
      }
    } catch (_) {}

    return _inMemoryPartitions.putIfAbsent(verifiedUserId, () => {});
  }

  /// Persists all records for [verifiedUserId].
  Future<void> _savePartition(
    String verifiedUserId,
    Map<String, SyncRecord> records,
  ) async {
    _inMemoryPartitions[verifiedUserId] = Map.from(records);
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey(verifiedUserId);
      final map = records.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString(key, jsonEncode(map));
    } catch (_) {}
  }

  @override
  Future<Resource<List<SyncRecord>>> pushChanges({
    required String authToken,
    required List<SyncRecord> records,
  }) async {
    // 1. Server-side token validation (never trust client userId)
    final verifiedUserId = await _authenticateToken(authToken);
    if (verifiedUserId == null) {
      return Resource.error(
        UnauthorizedFailure('Invalid or expired authentication session'),
      );
    }

    try {
      final cloudRecords = await _loadPartition(verifiedUserId);
      final acceptedRecords = <SyncRecord>[];

      for (final clientRec in records) {
        // Enforce verified user ID from the authenticated token
        final stampedRec = clientRec.copyWith(userId: verifiedUserId);
        final existing = cloudRecords[stampedRec.id];

        if (existing == null) {
          cloudRecords[stampedRec.id] = stampedRec;
          acceptedRecords.add(stampedRec);
        } else {
          // Conflict resolution
          if (stampedRec.isDeleted != existing.isDeleted) {
            final tombstoneWins =
                SyncConflictResolver.shouldTombstoneWin(existing, stampedRec);
            final winner = tombstoneWins
                ? (stampedRec.isDeleted ? stampedRec : existing)
                : (stampedRec.isDeleted ? existing : stampedRec);
            cloudRecords[stampedRec.id] = winner;
            acceptedRecords.add(winner);
          } else {
            final winner = SyncConflictResolver.resolveLWW(existing, stampedRec);
            cloudRecords[stampedRec.id] = winner;
            acceptedRecords.add(winner);
          }
        }
      }

      await _savePartition(verifiedUserId, cloudRecords);
      return Resource.success(acceptedRecords);
    } catch (e) {
      return Resource.error(
        ServerFailure('Cloud synchronization push failed: $e'),
      );
    }
  }

  @override
  Future<Resource<List<SyncRecord>>> pullChanges({
    required String authToken,
    DateTime? since,
  }) async {
    // 1. Server-side token validation
    final verifiedUserId = await _authenticateToken(authToken);
    if (verifiedUserId == null) {
      return Resource.error(
        UnauthorizedFailure('Invalid or expired authentication session'),
      );
    }

    try {
      final cloudRecords = await _loadPartition(verifiedUserId);
      List<SyncRecord> results = cloudRecords.values.toList();

      if (since != null) {
        results = results
            .where((r) => r.updatedAt.isAfter(since))
            .toList();
      }

      // Sort oldest to newest so clients replay orderly
      results.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      return Resource.success(results);
    } catch (e) {
      return Resource.error(
        ServerFailure('Cloud synchronization pull failed: $e'),
      );
    }
  }

  @override
  Future<Resource<List<SyncRecord>>> getAllUserData({
    required String authToken,
  }) async {
    return pullChanges(authToken: authToken, since: null);
  }

  @override
  Future<Resource<void>> clearUserData({required String authToken}) async {
    final verifiedUserId = await _authenticateToken(authToken);
    if (verifiedUserId == null) {
      return Resource.error(
        UnauthorizedFailure('Invalid or expired authentication session'),
      );
    }

    _inMemoryPartitions.remove(verifiedUserId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey(verifiedUserId));
    } catch (_) {}

    return Resource.success(null);
  }
}
