import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/features/events/repository/event_repository.dart';

enum EventFilter { upcoming, ongoing, past }

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

final eventFilterProvider = StateProvider<EventFilter>((ref) => EventFilter.upcoming);

/// Stream of all events from Firestore
final eventsProvider = StreamProvider<List<Event>>((ref) {
  final repository = ref.read(eventRepositoryProvider);
  return repository.getEventsStream();
});

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

/// EventController for manual operations (create/update/delete)
class EventController extends StateNotifier<AsyncValue<List<Event>>> {
  final EventRepository _repository;
  EventController(this._repository) : super(const AsyncValue.loading()) {
    _listenToEvents();
  }

  void _listenToEvents() {
    _repository.getEventsStream().listen((events) {
      state = AsyncValue.data(events);
    }, onError: (error, stack) {
      state = AsyncValue.error(error, stack);
    });
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      await _repository.createEvent(eventData);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    try {
      await _repository.updateEvent(eventId, eventData);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _repository.deleteEvent(eventId);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

/// Provider for EventController
final eventControllerProvider =
    StateNotifierProvider<EventController, AsyncValue<List<Event>>>((ref) {
  final repository = ref.read(eventRepositoryProvider);
  return EventController(repository);
});
