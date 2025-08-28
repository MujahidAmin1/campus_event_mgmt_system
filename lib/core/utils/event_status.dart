import 'package:campus_event_mgmt_system/models/event.dart';

extension EventStatus on Event {
  bool get isPast => endDateTime.isBefore(DateTime.now());

  bool get isOngoing =>
      startDateTime.isBefore(DateTime.now()) &&
      endDateTime.isAfter(DateTime.now());

  bool get isUpcoming => startDateTime.isAfter(DateTime.now());
}
