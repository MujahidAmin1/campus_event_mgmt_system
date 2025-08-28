import 'package:campus_event_mgmt_system/models/user.dart';

class Admin extends User {
  Admin({
    required String id,
    required String username,
    required String email,
    required String role,
  }) : super(
          id: id,
          username: username,
          email: email,
          role: role,
        );
}
