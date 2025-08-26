import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/features/events/repository/event_repository.dart';

// Repository provider
final eventRepositoryProvider = Provider<EventRepository>((ref) => EventRepositoryImpl());

// Filter state provider
final eventFilterProvider = StateProvider<EventFilter>((ref) => EventFilter.upcoming);

// Events provider with auto-refresh based on filter
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final filter = ref.watch(eventFilterProvider);
  final repository = ref.read(eventRepositoryProvider);
  return repository.getEventsByFilter(filter);
});

// Event actions controller
final eventActionsProvider = Provider<EventActions>((ref) {
  final repository = ref.read(eventRepositoryProvider);
  return EventActions(repository, ref);
});

// Event actions class - simplified business logic
class EventActions {
  final EventRepository _repository;
  final Ref _ref;

  EventActions(this._repository, this._ref);

  Future<void> createEvent(Event event) async {
    await _repository.createEvent(event);
    _refreshEvents();
  }

  Future<void> updateEvent(Event event) async {
    await _repository.updateEvent(event);
    _refreshEvents();
  }

  Future<void> deleteEvent(String id) async {
    await _repository.deleteEvent(id);
    _refreshEvents();
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    await _repository.registerForEvent(eventId, userId);
    _refreshEvents();
  }

  Future<void> unregisterFromEvent(String eventId, String userId) async {
    await _repository.unregisterFromEvent(eventId, userId);
    _refreshEvents();
  }

  Future<List<Event>> searchEvents(String query) async {
    return _repository.searchEvents(query);
  }

  void _refreshEvents() {
    _ref.invalidate(eventsProvider);
  }
}
