import 'package:campus_event_mgmt_system/models/user.dart';

class Student extends User {
  Student({
    String? id,
    String? name,
    String? email,
    List<String>? registeredEventIds,
  }) : super(
    id: id ?? '',
    name: name ?? '',
    email: email ?? '',
    role: UserRole.user,
    createdAt: DateTime.now(),
    registeredEventIds: registeredEventIds ?? [],
  );
}