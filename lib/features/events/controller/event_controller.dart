import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/features/events/repository/event_repository.dart';
import 'package:campus_event_mgmt_system/core/providers.dart';

enum EventFilter { upcoming, ongoing, past }

var eventFilterProvider = StateProvider<EventFilter>((ref) => EventFilter.upcoming);

var eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.read(eventRepositoryProvider);
  return await repository.getEvents();
});

var filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final filter = ref.watch(eventFilterProvider);
  
  return eventsAsync.when(
    data: (events) {
      final filteredEvents = events.where((event) {
        switch (filter) {
          case EventFilter.upcoming:
            return event.isUpcoming;
          case EventFilter.ongoing:
            return event.isOngoing;
          case EventFilter.past:
            return event.isPast;
        }
      }).toList();
      return AsyncValue.data(filteredEvents);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

var eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return EventRepository(apiService);
});

class EventController extends StateNotifier<AsyncValue<List<Event>>> {
  final EventRepository _repository;

  EventController(this._repository) : super(const AsyncValue.loading()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    state = const AsyncValue.loading();
    try {
      final events = await _repository.getEvents();
      state = AsyncValue.data(events);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      await _repository.createEvent(eventData);
      await loadEvents(); // Reload events after creation
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    try {
      await _repository.updateEvent(eventId, eventData);
      await loadEvents(); // Reload events after update
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _repository.deleteEvent(eventId);
      await loadEvents(); // Reload events after deletion
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}
