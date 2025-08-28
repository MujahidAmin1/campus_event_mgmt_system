class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String organiser;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.organiser,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      organiser: json['organiser'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'organiser': organiser,
    };
  }

  // Computed properties for event status
  bool get isPast => date.isBefore(DateTime.now());
  bool get isOngoing => !isPast && date.isBefore(DateTime.now().add(const Duration(hours: 3)));
  bool get isUpcoming => !isPast && !isOngoing;

  // For backward compatibility with existing UI
  DateTime get dateTime => date;
  String get venue => location;
  String get organizerName => organiser;
  int get registeredUsers => 0; // This will need to be updated when you have registration API
}

