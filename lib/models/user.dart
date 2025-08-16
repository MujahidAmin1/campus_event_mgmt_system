

enum UserRole {
  user,
  admin,
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final List<String> registeredEventIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.createdAt,
    required this.registeredEventIds,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      registeredEventIds: List<String>.from(json['registeredEventIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'registeredEventIds': registeredEventIds,
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;
}