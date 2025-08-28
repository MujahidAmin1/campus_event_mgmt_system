

import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String venue;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String organizerName;
  final int registeredUsers;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.startDateTime,
    required this.endDateTime,
    required this.organizerName,
    this.registeredUsers = 0,
  });

  factory Event.fromJson(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Event(
    id: doc.id,
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    venue: data['venue'] ?? '',
    startDateTime: (data['startDateTime'] is Timestamp)
        ? (data['startDateTime'] as Timestamp).toDate()
        : DateTime.now(), // fallback
    endDateTime: (data['endDateTime'] is Timestamp)
        ? (data['endDateTime'] as Timestamp).toDate()
        : DateTime.now(), // fallback
    organizerName: data['organizerName'] ?? '',
    registeredUsers: data['registeredUsers'] ?? 0,
  );
}


  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'venue': venue,
        'startDateTime': Timestamp.fromDate(startDateTime),
        'endDateTime': Timestamp.fromDate(endDateTime),
        'organizerName': organizerName,
        'registeredUsers': registeredUsers,
      };

  bool get isUpcoming => startDateTime.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startDateTime) && DateTime.now().isBefore(endDateTime);
  bool get isPast => endDateTime.isBefore(DateTime.now());
}
