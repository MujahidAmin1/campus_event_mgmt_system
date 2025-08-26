class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String venue;
  final String organizerId;
  final String organizerName;
  final int registeredUsers;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.organizerId,
    required this.organizerName,
    this.registeredUsers = 0,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      venue: json['venue'],
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      registeredUsers: json['registeredUsers'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'venue': venue,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'registeredUsers': registeredUsers,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper methods for filtering
  bool get isUpcoming => dateTime.isAfter(DateTime.now());
  bool get isOngoing => dateTime.isBefore(DateTime.now()) && 
                       dateTime.add(const Duration(hours: 3)).isAfter(DateTime.now());
  bool get isPast => dateTime.add(const Duration(hours: 3)).isBefore(DateTime.now());
}

enum EventFilter {
  upcoming,
  ongoing,
  past,
}

