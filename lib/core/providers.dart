import 'package:flutter_riverpod/flutter_riverpod.dart';

// Export event providers for easy access
export 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';

var accountStateProvider = StateProvider<bool>((ref) => true);
var userRoleProvider = StateProvider<UserRole>((ref) => UserRole.student);

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
