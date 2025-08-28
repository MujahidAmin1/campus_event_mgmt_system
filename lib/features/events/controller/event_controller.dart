import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/features/events/repository/event_repository.dart';

enum EventFilter { upcoming, ongoing, past }
final eventFilterProvider = StateProvider<EventFilter>((ref) => EventFilter.upcoming);

final eventRepositoryProvider = Provider<EventRepository>((ref) => EventRepository());

final eventsProvider = StateNotifierProvider<EventController, AsyncValue<List<Event>>>(
  (ref) => EventController(ref),
);

final userEventsProvider = FutureProvider.family<List<Event>, String>(
  (ref, userId) => ref.read(eventRepositoryProvider).getUserRegisteredEvents(userId),
);

/// Filtered events based on selected filter
final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final filter = ref.watch(eventFilterProvider);

  return eventsAsync.when(
    data: (events) {
      final filtered = events.where((event) {
        switch (filter) {
          case EventFilter.upcoming:
            return event.isUpcoming;
          case EventFilter.ongoing:
            return event.isOngoing;
          case EventFilter.past:
            return event.isPast;
        }
      }).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
class EventController extends StateNotifier<AsyncValue<List<Event>>> {
  final Ref ref;

  EventController(this.ref) : super(const AsyncValue.loading()) {
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final events = await ref.read(eventRepositoryProvider).getAllEvents();
      state = AsyncValue.data(events);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

   Future<void> registerForEvent(String userId, Event event) async {
    try {
      await ref.read(eventRepositoryProvider).registerUserForEvent(userId, event);
    } catch (e) {
      rethrow; // or handle error
    }
  }
  /// 🔹 Create a new event
  Future<void> createTheEvent(Event event) async {
    try {
      await ref.read(eventRepositoryProvider).createEvent(event);
      await fetchEvents(); // refresh list after adding
    } catch (e) {
      rethrow;
    }
  
}
}