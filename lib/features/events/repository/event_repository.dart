import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_event_mgmt_system/models/event.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';

  Stream<List<Event>> getEventsStream() {
    return _firestore.collection(_collection).orderBy('date').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return Event.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList(),
    );
  }

  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    final docRef = await _firestore.collection(_collection).add(eventData);
    final doc = await docRef.get();
    return Event.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  Future<Event> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    final docRef = _firestore.collection(_collection).doc(eventId);
    await docRef.update(eventData);
    final updatedDoc = await docRef.get();
    return Event.fromJson({
      'id': updatedDoc.id,
      ...updatedDoc.data()!,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collection).doc(eventId).delete();
  }
}
