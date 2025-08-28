import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/user.dart';
import 'package:campus_event_mgmt_system/core/providers.dart';
import '../repository/auth_repository.dart';

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuthService _authService;
  final Ref _ref;

  AuthController(this._authService, this._ref) : super(const AsyncValue.data(null));

  /// Get current user from Firebase
  Future<void> getCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _setUser(user);
      } else {
        _ref.read(isAuthenticatedProvider.notifier).state = false;
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Login - use email for login, not username
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signIn(email, password);
      _setUser(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Register
  Future<void> register(String username, String email, String password, String role) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUp(username, email, password, role);
      _setUser(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      _ref.read(currentUserProvider.notifier).state = null;
      _ref.read(userRoleProvider.notifier).state = UserRole.student;
      _ref.read(isAuthenticatedProvider.notifier).state = false;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear error
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }

  /// Private helper to set user and role
  void _setUser(User user) {
    _ref.read(currentUserProvider.notifier).state = user;

    final roleString = user.role?.toLowerCase().trim() ?? '';
    UserRole role;
    switch (roleString) {
      case 'admin':
      case 'administrator':
        role = UserRole.admin;
        break;
      case 'student':
      case 'user':
      default:
        role = UserRole.student;
    }

    _ref.read(userRoleProvider.notifier).state = role;
    _ref.read(isAuthenticatedProvider.notifier).state = true;
    state = AsyncValue.data(user);
  }
}

/// Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final authService = ref.read(firebaseAuthServiceProvider);
  return AuthController(authService, ref);
});