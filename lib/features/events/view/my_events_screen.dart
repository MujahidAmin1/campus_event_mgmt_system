import 'package:campus_event_mgmt_system/features/events/view/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';

class MyEventsScreen extends ConsumerWidget {
  final String userId;

  const MyEventsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myEventsAsync = ref.watch(userEventsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        centerTitle: true,
      ),
      body: myEventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('You have not registered for any events.'));
          }
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (_, index) {
              final event = events[index];
              return EventCard(
                event: event,
                onTap: () => {},
                 
                showRegisterButton: false, // don't show register button in MyEvents
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
