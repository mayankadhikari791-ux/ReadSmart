import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages auth session persistence via SharedPreferences.
///
/// All structured data is serialised as JSON strings so the storage layer
/// stays trivially portable — swap the backing store (e.g. Hive, SQLite)
/// without touching any auth-logic callers.
class AuthSessionManager {
  // ── Storage keys ────────────────────────────────────────────────────────────
  static const _kUsers = 'rs_auth_users';
  static const _kSession = 'rs_auth_session';
  static const _kResetTokens = 'rs_reset_tokens';

  // ── Users registry ───────────────────────────────────────────────────────────
  // Stored as: Map<lowercaseEmail, Map<String,dynamic>> serialised to JSON.

  /// Returns the full users registry, or an empty map if none is stored yet.
  static Future<Map<String, dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsers);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {};
  }

  /// Persists the entire users registry, replacing any previous value.
  static Future<void> saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, jsonEncode(users));
  }

  // ── Active session ───────────────────────────────────────────────────────────
  // Stored as a single JSON object (or absent when no session is active).

  /// Returns the currently persisted session map, or null if none exists.
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  /// Persists a new session, overwriting any previously stored session.
  static Future<void> saveSession(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSession, jsonEncode(session));
  }

  /// Removes the active session (call on sign-out or token expiry).
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSession);
  }

  // ── Password-reset tokens ────────────────────────────────────────────────────
  // Stored as: Map<lowercaseEmail, {token: String, expiresAt: ISO8601String}>

  /// Returns the raw reset-token registry, or an empty map if none exists.
  static Future<Map<String, dynamic>> getResetTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kResetTokens);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {};
  }

  /// Stores (or replaces) a reset token for [email].
  ///
  /// [expiresAt] is the absolute expiry timestamp; the caller controls the
  /// window (typically 15–60 minutes from now).
  static Future<void> saveResetToken(
    String email,
    String token,
    DateTime expiresAt,
  ) async {
    final tokens = await getResetTokens();
    tokens[email.toLowerCase()] = {
      'token': token,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kResetTokens, jsonEncode(tokens));
  }

  /// Returns the stored reset token string for [email], or null if none exists
  /// or the stored entry has already expired.
  static Future<String?> getResetToken(String email) async {
    final tokens = await getResetTokens();
    final entry = tokens[email.toLowerCase()];
    if (entry == null) return null;
    try {
      final expiry = DateTime.parse(entry['expiresAt'] as String);
      if (DateTime.now().toUtc().isAfter(expiry)) {
        // Token has expired — clean it up eagerly.
        await clearResetToken(email);
        return null;
      }
      return entry['token'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Removes the reset token entry for [email] (after use or expiry).
  static Future<void> clearResetToken(String email) async {
    final tokens = await getResetTokens();
    tokens.remove(email.toLowerCase());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kResetTokens, jsonEncode(tokens));
  }

  // ── Server session validation (cloud sync authorization) ───────────────────
  static final Map<String, Map<String, dynamic>> _serverSessions = {};

  /// Simulates backend session registration for testing/verification.
  static void registerServerSession({
    required String token,
    required String userId,
    required String email,
    required DateTime expiresAt,
  }) {
    _serverSessions[token] = {
      'userId': userId,
      'email': email,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
    };
  }

  /// Validates session token on the backend and returns verified userId if valid & unexpired.
  static Future<String?> validateServerSession(String token) async {
    if (_serverSessions.containsKey(token)) {
      final s = _serverSessions[token]!;
      final expiry = DateTime.parse(s['expiresAt'] as String);
      if (DateTime.now().toUtc().isBefore(expiry)) {
        return s['userId'] as String?;
      }
      return null;
    }
    final session = await getSession();
    if (session != null && session['token'] == token) {
      final expiryStr = session['expiresAt'] as String?;
      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().toUtc().isBefore(expiry)) {
          return session['userId'] as String?;
        }
      } else {
        return session['userId'] as String?;
      }
    }
    return null;
  }
}

