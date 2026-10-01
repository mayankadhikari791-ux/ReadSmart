import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/network_exceptions.dart';
import '../../core/network/resource.dart';
import '../../models/user_model.dart';
import 'auth_session_manager.dart';
import 'i_auth_service.dart';

/// Fully local, offline-capable [IAuthService] implementation.
///
/// Credentials are stored in [SharedPreferences] via [AuthSessionManager].
/// Passwords are never stored in plain-text: each password entry is secured
/// with a per-user random 32-byte salt (stored as hex) and hashed with SHA-256.
///
/// Because there is no real email server, [sendPasswordResetEmail] generates
/// a one-time token that callers can surface in-app via [getResetToken] and
/// redeem with [resetPasswordWithToken].
class LocalAuthService implements IAuthService {
  // ── Auth-state stream ────────────────────────────────────────────────────────
  final _authController = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _authController.stream;

  // ── In-memory state ──────────────────────────────────────────────────────────
  User? _currentUser;
  String? _currentUserId;

  @override
  User? get currentUser => _currentUser;

  /// Returns the internal id of the currently signed-in user, or null.
  String? get currentUserId => _currentUserId;

  @override
  bool get isAuthenticated => _currentUser != null;

  // ── Internal helpers ─────────────────────────────────────────────────────────

  /// Generates a cryptographically-random 32-byte value as a lowercase hex string.
  String _generateHex32() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Derives the SHA-256 hash of [password] + [saltHex].
  String _hashPassword(String password, String saltHex) {
    final input = utf8.encode(password + saltHex);
    return sha256.convert(input).toString();
  }

  /// Derives avatar initials from a full name (up to 2 capital letters).
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Builds a [User] domain object from the raw stored map entry.
  User _userFromStoredEntry(Map<String, dynamic> entry) {
    final createdAt = entry['createdAt'] as String? ?? '';
    String memberSince = 'Reader';
    try {
      final dt = DateTime.parse(createdAt);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      memberSince = 'Reading since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {}

    final name = entry['name'] as String? ?? '';
    return User(
      id: entry['id'] as String,
      name: name,
      email: entry['email'] as String,
      readingLevel: 'Advanced Reader',
      avatarInitials: _initials(name),
      memberSince: memberSince,
    );
  }

  // ── Validation ───────────────────────────────────────────────────────────────

  /// Returns a [NetworkFailure] describing the first validation error found,
  /// or null if all inputs are valid.
  NetworkFailure? _validateSignUp({
    required String email,
    required String password,
    required String name,
  }) {
    if (!email.contains('@') || !email.contains('.')) {
      return const InvalidDataFailure('Please enter a valid email address.');
    }
    if (name.trim().length < 2) {
      return const InvalidDataFailure(
        'Please enter your full name (at least 2 characters)',
      );
    }
    if (password.length < 8 || !RegExp(r'\d').hasMatch(password)) {
      return const InvalidDataFailure(
        'Password must be at least 8 characters and include a number',
      );
    }
    return null;
  }

  /// Returns a [NetworkFailure] for basic sign-in input checks, or null.
  NetworkFailure? _validateSignIn({
    required String email,
    required String password,
  }) {
    if (!email.contains('@') || !email.contains('.')) {
      return const InvalidDataFailure('Please enter a valid email address.');
    }
    if (password.isEmpty) {
      // Surface only a generic error — do not indicate whether email or
      // password is wrong (prevents user-enumeration).
      return const UnauthorizedFailure('Invalid email or password');
    }
    return null;
  }

  // ── IAuthService implementation ──────────────────────────────────────────────

  @override
  Future<Resource<User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final normEmail = email.trim().toLowerCase();

      final inputError = _validateSignIn(email: normEmail, password: password);
      if (inputError != null) return Resource.error(inputError);

      final users = await AuthSessionManager.getUsers();
      final entry = users[normEmail];
      if (entry == null) {
        // Do not reveal that the email doesn't exist.
        return Resource.error(
          const UnauthorizedFailure('Invalid email or password'),
        );
      }

      final storedSalt = entry['salt'] as String;
      final storedHash = entry['passwordHash'] as String;
      final candidateHash = _hashPassword(password, storedSalt);

      if (candidateHash != storedHash) {
        return Resource.error(
          const UnauthorizedFailure('Invalid email or password'),
        );
      }

      // Credentials match — create a session.
      final sessionToken = _generateHex32();
      final expiresAt = DateTime.now().toUtc().add(const Duration(days: 30));
      await AuthSessionManager.saveSession({
        'userId': entry['id'],
        'email': normEmail,
        'token': sessionToken,
        'expiresAt': expiresAt.toIso8601String(),
      });

      final user = _userFromStoredEntry(Map<String, dynamic>.from(entry));
      _currentUser = user;
      _currentUserId = user.id;
      _authController.add(user);

      return Resource.success(user);
    } catch (e, st) {
      debugPrint('[LocalAuthService] signInWithEmail error: $e\n$st');
      return Resource.error(
        ServerFailure('Sign-in failed. Please try again.', originalError: e),
      );
    }
  }

  @override
  Future<Resource<User>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final normEmail = email.trim().toLowerCase();
      final trimmedName = name.trim();

      final inputError = _validateSignUp(
        email: normEmail,
        password: password,
        name: trimmedName,
      );
      if (inputError != null) return Resource.error(inputError);

      final users = await AuthSessionManager.getUsers();

      if (users.containsKey(normEmail)) {
        return Resource.error(
          const InvalidDataFailure(
            'An account with this email already exists',
          ),
        );
      }

      // Build the secure credential record.
      final salt = _generateHex32();
      final hash = _hashPassword(password, salt);
      final userId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toUtc().toIso8601String();

      users[normEmail] = {
        'id': userId,
        'name': trimmedName,
        'email': normEmail,
        'passwordHash': hash,
        'salt': salt,
        'createdAt': now,
      };

      await AuthSessionManager.saveUsers(users);

      // Automatically sign the new user in.
      final sessionToken = _generateHex32();
      final expiresAt = DateTime.now().toUtc().add(const Duration(days: 30));
      await AuthSessionManager.saveSession({
        'userId': userId,
        'email': normEmail,
        'token': sessionToken,
        'expiresAt': expiresAt.toIso8601String(),
      });

      final user = _userFromStoredEntry(
        Map<String, dynamic>.from(users[normEmail] as Map),
      );
      _currentUser = user;
      _currentUserId = userId;
      _authController.add(user);

      return Resource.success(user);
    } catch (e, st) {
      debugPrint('[LocalAuthService] signUpWithEmail error: $e\n$st');
      return Resource.error(
        ServerFailure('Sign-up failed. Please try again.', originalError: e),
      );
    }
  }

  @override
  Future<Resource<void>> signOut() async {
    try {
      await AuthSessionManager.clearSession();
      _currentUser = null;
      _currentUserId = null;
      _authController.add(null);
      return Resource.success(null);
    } catch (e, st) {
      debugPrint('[LocalAuthService] signOut error: $e\n$st');
      return Resource.error(
        ServerFailure('Sign-out failed. Please try again.', originalError: e),
      );
    }
  }

  /// Generates a short-lived reset token and stores it.
  ///
  /// Because there is no email server, callers should surface the token
  /// in-app via [getResetToken] so the user can complete the flow without
  /// leaving the device.
  @override
  Future<Resource<void>> sendPasswordResetEmail(String email) async {
    try {
      final normEmail = email.trim().toLowerCase();

      if (!normEmail.contains('@') || !normEmail.contains('.')) {
        return Resource.error(
          const InvalidDataFailure('Please enter a valid email address.'),
        );
      }

      final users = await AuthSessionManager.getUsers();
      if (!users.containsKey(normEmail)) {
        // Respond with success even for unknown emails to prevent enumeration.
        return Resource.success(null);
      }

      final token = _generateHex32();
      // Token is valid for 30 minutes.
      final expiresAt = DateTime.now().toUtc().add(const Duration(minutes: 30));
      await AuthSessionManager.saveResetToken(normEmail, token, expiresAt);

      debugPrint(
        '[LocalAuthService] Password reset token for $normEmail: $token',
      );

      return Resource.success(null);
    } catch (e, st) {
      debugPrint('[LocalAuthService] sendPasswordResetEmail error: $e\n$st');
      return Resource.error(
        ServerFailure(
          'Could not initiate password reset. Please try again.',
          originalError: e,
        ),
      );
    }
  }

  // ── Additional public methods ─────────────────────────────────────────────────

  /// Attempts to restore a previously saved session from [SharedPreferences].
  ///
  /// Returns the cached [User] if a non-expired session is found and the
  /// corresponding user record still exists; otherwise returns null.
  /// Should be called once at app startup (e.g. from a splash screen or
  /// an app-level provider).
  Future<User?> restoreSession() async {
    try {
      final session = await AuthSessionManager.getSession();
      if (session == null) return null;

      // Check token expiry.
      final expiresAtRaw = session['expiresAt'] as String?;
      if (expiresAtRaw == null) return null;
      final expiresAt = DateTime.parse(expiresAtRaw);
      if (DateTime.now().toUtc().isAfter(expiresAt)) {
        await AuthSessionManager.clearSession();
        return null;
      }

      final email = session['email'] as String?;
      if (email == null) return null;

      final users = await AuthSessionManager.getUsers();
      final entry = users[email.toLowerCase()];
      if (entry == null) {
        await AuthSessionManager.clearSession();
        return null;
      }

      final user = _userFromStoredEntry(Map<String, dynamic>.from(entry));
      _currentUser = user;
      _currentUserId = user.id;
      _authController.add(user);
      return user;
    } catch (e, st) {
      debugPrint('[LocalAuthService] restoreSession error: $e\n$st');
      return null;
    }
  }

  /// Returns the active reset token for [email], or null if none exists or
  /// the token has expired.
  ///
  /// Expose this in a dedicated "Enter Reset Token" screen so users can
  /// complete password-reset without a real email server.
  Future<String?> getResetToken(String email) async {
    return AuthSessionManager.getResetToken(email.trim().toLowerCase());
  }

  /// Verifies [token] against the stored reset token for [email] and, if
  /// valid, replaces the user's password hash with one derived from [newPassword].
  ///
  /// Returns [Resource.success] on success, or an appropriate failure.
  Future<Resource<void>> resetPasswordWithToken(
    String email,
    String token,
    String newPassword,
  ) async {
    try {
      final normEmail = email.trim().toLowerCase();

      // Validate the new password first.
      if (newPassword.length < 8 || !RegExp(r'\d').hasMatch(newPassword)) {
        return Resource.error(
          const InvalidDataFailure(
            'Password must be at least 8 characters and include a number',
          ),
        );
      }

      // Verify token.
      final storedToken = await AuthSessionManager.getResetToken(normEmail);
      if (storedToken == null) {
        return Resource.error(
          const UnauthorizedFailure(
            'Reset token is invalid or has expired. Please request a new one.',
          ),
        );
      }
      if (storedToken != token.trim()) {
        return Resource.error(
          const UnauthorizedFailure(
            'The token you entered is incorrect. Please check and try again.',
          ),
        );
      }

      // Update the stored password hash.
      final users = await AuthSessionManager.getUsers();
      final entry = users[normEmail];
      if (entry == null) {
        return Resource.error(
          const InvalidDataFailure('No account found for this email address.'),
        );
      }

      final newSalt = _generateHex32();
      final newHash = _hashPassword(newPassword, newSalt);
      (entry as Map<String, dynamic>)['salt'] = newSalt;
      entry['passwordHash'] = newHash;
      users[normEmail] = entry;

      await AuthSessionManager.saveUsers(users);
      await AuthSessionManager.clearResetToken(normEmail);

      // Force re-login so the new credentials take effect.
      await signOut();

      return Resource.success(null);
    } catch (e, st) {
      debugPrint('[LocalAuthService] resetPasswordWithToken error: $e\n$st');
      return Resource.error(
        ServerFailure('Password reset failed. Please try again.', originalError: e),
      );
    }
  }

  /// Releases the broadcast stream controller.
  ///
  /// Call this only when the service instance itself is being permanently
  /// disposed (e.g. in tests or when swapping service implementations).
  void dispose() {
    _authController.close();
  }
}
