import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/core/services/api_service.dart';

class EventRepository {
  final ApiService _apiService;

  EventRepository(this._apiService);

  Future<List<Event>> getEvents() async {
    return await _apiService.getEvents();
  }

  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    return await _apiService.createEvent(eventData);
  }

  Future<Event> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    return await _apiService.updateEvent(eventId, eventData);
  }

  Future<void> deleteEvent(String eventId) async {
    await _apiService.deleteEvent(eventId);
  }
}