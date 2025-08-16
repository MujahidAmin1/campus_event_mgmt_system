import 'package:flutter_riverpod/flutter_riverpod.dart';

// Export event providers for easy access
export 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';

var accountStateProvider = StateProvider<bool>((ref) => true);

void toggle(WidgetRef ref, bool val) {
  ref.read(accountStateProvider.notifier).state = val;
}
