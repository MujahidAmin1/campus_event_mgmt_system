import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/user.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  Future<User?> getCurrentUser() async {
    final current = _auth.currentUser;
    if (current != null) {
      return User(
        id: current.uid,
        username: current.displayName ?? 'Anonymous',
        email: current.email ?? '',
        role: 'student', // default role, or fetch from Firestore if stored
      );
    }
    return null;
  }

  /// Sign in
  Future<User> signIn(String email, String password) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = credentials.user!;
    return User(
      id: fbUser.uid,
      username: fbUser.displayName ?? 'Anonymous',
      email: fbUser.email ?? '',
      role: 'student', // adjust if storing role elsewhere
    );
  }

  /// Register
  Future<User> signUp(String username, String email, String password, String role) async {
    final credentials = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = credentials.user!;
    await fbUser.updateDisplayName(username);
    return User(
      id: fbUser.uid,
      username: username,
      email: email,
      role: role,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
