import 'package:campus_event_mgmt_system/models/user.dart';

class Student extends User {
  List<String>? registeredEventIds; // Track registered events

  Student({
    String? id,
    String? name,
    String? email,
    this.registeredEventIds,
  }) : super(id: id, name: name, email: email);
}