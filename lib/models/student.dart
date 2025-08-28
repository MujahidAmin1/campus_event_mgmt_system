import 'package:campus_event_mgmt_system/models/user.dart';

class Student extends User {
  List<String>? registeredEventIds; // Track registered events

  Student({
    required String id,
    required String username,
    required String email,
    required String role,
    this.registeredEventIds,
  }) : super(
          id: id,
          username: username,
          email: email,
          role: role,
        );
}