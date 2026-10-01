import 'dart:async';
import '../../core/network/network_exceptions.dart';
import '../../core/network/resource.dart';
import '../../models/user_model.dart';
import 'i_auth_service.dart';

/// Concrete in-memory implementation of [IAuthService] supporting offline mode
/// and zero-network development/testing scenarios.
class MockAuthService implements IAuthService {
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  User? _currentUser;
  bool simulateOffline = false;
  bool simulateTimeout = false;
  bool simulateServerError = false;

  MockAuthService({User? initialUser}) {
    _currentUser = initialUser ??
        User(
          id: 'user_dev_1',
          name: 'Mayank',
          email: 'mayank@readsmart.app',
          readingLevel: 'Advanced Reader',
          avatarInitials: 'M',
          memberSince: 'Reading since Jan 2024',
        );
  }

  @override
  Stream<User?> get authStateChanges => _userController.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<Resource<User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (simulateOffline) {
      return Resource.error(
        const NoInternetFailure(),
        cachedData: _currentUser,
      );
    }
    if (simulateTimeout) {
      return Resource.error(const TimeoutFailure());
    }
    if (simulateServerError) {
      return Resource.error(const ServerFailure('Backend authentication unavailable'));
    }

    if (email.trim().isEmpty || !email.contains('@')) {
      return Resource.error(const InvalidDataFailure('Invalid email address format'));
    }

    if (password.length < 6) {
      return Resource.error(
        const UnauthorizedFailure('Password must be at least 6 characters'),
      );
    }

    final user = User(
      id: 'user_${email.hashCode}',
      name: email.split('@').first,
      email: email,
      avatarInitials: email.isNotEmpty ? email[0].toUpperCase() : 'U',
      readingLevel: 'Advanced Reader',
      memberSince: 'Member since 2024',
    );

    _currentUser = user;
    _userController.add(user);
    return Resource.success(user);
  }

  @override
  Future<Resource<User>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    if (simulateOffline) {
      return Resource.error(const NoInternetFailure());
    }

    if (name.trim().isEmpty) {
      return Resource.error(const InvalidDataFailure('Name cannot be empty'));
    }

    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      avatarInitials: name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U',
      readingLevel: 'Avid Reader',
      memberSince: 'Joined today',
    );

    _currentUser = user;
    _userController.add(user);
    return Resource.success(user);
  }

  @override
  Future<Resource<void>> signOut() async {
    _currentUser = null;
    _userController.add(null);
    return Resource.success(null);
  }

  @override
  Future<Resource<void>> sendPasswordResetEmail(String email) async {
    if (simulateOffline) {
      return Resource.error(const NoInternetFailure());
    }
    if (email.isEmpty || !email.contains('@')) {
      return Resource.error(const InvalidDataFailure('Invalid email address'));
    }
    return Resource.success(null);
  }

  void dispose() {
    _userController.close();
  }
}

