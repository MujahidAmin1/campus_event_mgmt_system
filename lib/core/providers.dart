import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/user.dart';
import 'package:campus_event_mgmt_system/features/auth/controller/auth_controller.dart';

// Export event providers for easy access
export 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';

// State providers
final accountStateProvider = StateProvider<bool>((ref) => true);
final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.student);

// Authentication providers
final currentUserProvider = StateProvider<User?>((ref) => null);
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

// Enum for user roles
enum UserRole {
  student,
  admin,
}

// Toggle account state
void toggle(WidgetRef ref, bool val) {
  ref.read(accountStateProvider.notifier).state = val;
}

// Set user role
void setUserRole(WidgetRef ref, UserRole role) {
  ref.read(userRoleProvider.notifier).state = role;
}

// Set current user and role safely
void setCurrentUser(WidgetRef ref, User user) {
  ref.read(currentUserProvider.notifier).state = user;

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
      break;
  }

  ref.read(userRoleProvider.notifier).state = role;
  ref.read(isAuthenticatedProvider.notifier).state = true;
}

// Logout user (Firebase-friendly)
void logout(WidgetRef ref) {
  ref.read(currentUserProvider.notifier).state = null;
  ref.read(isAuthenticatedProvider.notifier).state = false;
  ref.read(userRoleProvider.notifier).state = UserRole.student;

  // If you have an AuthController, also call logout there
  ref.read(authControllerProvider.notifier).logout();

  print('User logged out - all state cleared');
}
