import '../../core/network/resource.dart';
import '../../models/user_model.dart';

/// Contract for Authentication service implementations.
///
/// Decouples authentication logic (Firebase Auth, custom JWT, OAuth, Mock)
/// from Flutter UI screens.
abstract class IAuthService {
  /// Stream emitting the currently signed in user or null when unauthenticated.
  Stream<User?> get authStateChanges;

  /// Current cached user instance.
  User? get currentUser;

  /// Authenticate with email address and password.
  Future<Resource<User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register a new account with email, password, and display name.
  Future<Resource<User>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Sign out current session.
  Future<Resource<void>> signOut();

  /// Sends a password reset verification link.
  Future<Resource<void>> sendPasswordResetEmail(String email);

  /// True if a user is currently logged in.
  bool get isAuthenticated => currentUser != null;
}

