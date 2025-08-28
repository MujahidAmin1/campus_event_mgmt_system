import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/user.dart';
import 'package:campus_event_mgmt_system/core/services/api_service.dart';
import 'package:campus_event_mgmt_system/core/services/jwt_service.dart';

// Export event providers for easy access
export 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';

var accountStateProvider = StateProvider<bool>((ref) => true);
var userRoleProvider = StateProvider<UserRole>((ref) => UserRole.student);

// Authentication providers
var authTokenProvider = StateProvider<String?>((ref) => null);
var currentUserProvider = StateProvider<User?>((ref) => null);
var isAuthenticatedProvider = StateProvider<bool>((ref) => false);

// Service providers
var apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

var jwtServiceProvider = Provider<JwtService>((ref) {
  return JwtService();
});

enum UserRole {
  student,
  admin,
}

void toggle(WidgetRef ref, bool val) {
  ref.read(accountStateProvider.notifier).state = val;
}

void setUserRole(WidgetRef ref, UserRole role) {
  ref.read(userRoleProvider.notifier).state = role;
}

void setAuthToken(WidgetRef ref, String token) {
  ref.read(authTokenProvider.notifier).state = token;
  ref.read(apiServiceProvider).setAuthToken(token);
  ref.read(isAuthenticatedProvider.notifier).state = true;
}

void setCurrentUser(WidgetRef ref, User user) {
  ref.read(currentUserProvider.notifier).state = user;
  // Set user role based on API response
  final role = user.role.toLowerCase() == 'admin' ? UserRole.admin : UserRole.student;
  ref.read(userRoleProvider.notifier).state = role;
}

void logout(WidgetRef ref) {
  ref.read(authTokenProvider.notifier).state = null;
  ref.read(currentUserProvider.notifier).state = null;
  ref.read(isAuthenticatedProvider.notifier).state = false;
  ref.read(apiServiceProvider).clearAuthToken();
  ref.read(userRoleProvider.notifier).state = UserRole.student;
}
