import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_event_mgmt_system/models/event.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Event>> getAllEvents() async {
    final snapshot = await _firestore.collection('events').get();
    return snapshot.docs.map((doc) => Event.fromJson(doc)).toList();
  }

  Future<void> registerUserForEvent(String userId, Event event) async {
  final userEventRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('registeredEvents')
      .doc(event.id);

  final existing = await userEventRef.get();
  if (existing.exists) {
    throw Exception("Already registered for this event");
  }

  await userEventRef.set({
    'eventId': event.id,
    'title': event.title,
    'registeredAt': FieldValue.serverTimestamp(),
  });

  final eventRef = _firestore.collection('events').doc(event.id);
  await eventRef.update({
    'registeredUsers': FieldValue.increment(1),
  });
}


  Future<List<Event>> getUserRegisteredEvents(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('registeredEvents')
        .get();

    return snapshot.docs.map((doc) => Event.fromJson(doc)).toList();
  }

  /// 🔹 Create a new event
  Future<void> createEvent(Event event) async {
    final eventRef = _firestore.collection('events').doc(event.id);
    await eventRef.set(event.toJson());
  }
}
