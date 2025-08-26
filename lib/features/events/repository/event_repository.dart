import 'package:campus_event_mgmt_system/models/event.dart';

abstract class EventRepository {
  Future<List<Event>> getAllEvents();
  Future<List<Event>> getEventsByFilter(EventFilter filter);
  Future<Event> getEventById(String id);
  Future<void> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
  Future<void> registerForEvent(String eventId, String userId);
  Future<void> unregisterFromEvent(String eventId, String userId);
  Future<List<Event>> searchEvents(String query);
}

class EventRepositoryImpl implements EventRepository {
  static const _delay = Duration(milliseconds: 300);

  // Sample data - replace with actual data source
  static final List<Event> _sampleEvents = [
    Event(
      id: '1',
      title: 'Tech Seminar 2024',
      description: 'Learn about the latest technologies in software development',
      dateTime: DateTime.now().add(const Duration(days: 5)),
      venue: 'Main Auditorium',
      organizerId: 'admin1',
      organizerName: 'Computer Science Department',
      registeredUsers: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Event(
      id: '2',
      title: 'Basketball Competition',
      description: 'Inter-department basketball championship',
      dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      venue: 'Sports Complex',
      organizerId: 'admin2',
      organizerName: 'Physical Education Department',
      registeredUsers: 80,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Event(
      id: '3',
      title: 'Cultural Festival',
      description: 'Annual cultural celebration with music and dance',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      venue: 'Open Air Theater',
      organizerId: 'admin3',
      organizerName: 'Cultural Committee',
      registeredUsers: 120,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Event(
      id: '4',
      title: 'Workshop on AI',
      description: 'Hands-on workshop on artificial intelligence basics and practical applications',
      dateTime: DateTime.now().add(const Duration(days: 10)),
      venue: 'Computer Lab 101',
      organizerId: 'admin1',
      organizerName: 'AI Research Center',
      registeredUsers: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Event(
      id: '5',
      title: 'Career Fair 2024',
      description: 'Connect with top companies and explore career opportunities',
      dateTime: DateTime.now().add(const Duration(days: 15)),
      venue: 'Student Center',
      organizerId: 'admin4',
      organizerName: 'Career Services',
      registeredUsers: 200,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Event(
      id: '6',
      title: 'Science Exhibition',
      description: 'Showcase of student research projects and scientific innovations',
      dateTime: DateTime.now().add(const Duration(days: 8)),
      venue: 'Science Building',
      organizerId: 'admin5',
      organizerName: 'Science Department',
      registeredUsers: 60,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Event(
      id: '7',
      title: 'Music Concert',
      description: 'Live performance by the university orchestra and choir',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      venue: 'Concert Hall',
      organizerId: 'admin6',
      organizerName: 'Music Department',
      registeredUsers: 150,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
  ];

  @override
  Future<List<Event>> getAllEvents() async {
    await Future.delayed(_delay);
    return List.from(_sampleEvents);
  }

  @override
  Future<List<Event>> getEventsByFilter(EventFilter filter) async {
    final allEvents = await getAllEvents();
    
    return allEvents.where((event) {
      switch (filter) {
        case EventFilter.upcoming:
          return event.isUpcoming;
        case EventFilter.ongoing:
          return event.isOngoing;
        case EventFilter.past:
          return event.isPast;
      }
    }).toList();
  }

  @override
  Future<Event> getEventById(String id) async {
    final events = await getAllEvents();
    return events.firstWhere((event) => event.id == id);
  }

  @override
  Future<void> createEvent(Event event) async {
    await Future.delayed(_delay);
    _sampleEvents.add(event);
  }

  @override
  Future<void> updateEvent(Event event) async {
    await Future.delayed(_delay);
    final index = _sampleEvents.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _sampleEvents[index] = event;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    await Future.delayed(_delay);
    _sampleEvents.removeWhere((event) => event.id == id);
  }

  @override
  Future<void> registerForEvent(String eventId, String userId) async {
    await Future.delayed(_delay);
    // TODO: Implement actual registration logic
  }

  @override
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    await Future.delayed(_delay);
    // TODO: Implement actual unregistration logic
  }

  @override
  Future<List<Event>> searchEvents(String query) async {
    final allEvents = await getAllEvents();
    final searchQuery = query.toLowerCase();
    
    return allEvents.where((event) => 
      event.title.toLowerCase().contains(searchQuery) ||
      event.description.toLowerCase().contains(searchQuery) ||
      event.venue.toLowerCase().contains(searchQuery)
    ).toList();
  }
}