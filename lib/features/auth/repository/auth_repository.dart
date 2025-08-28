import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/user.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  Future<User?> getCurrentUser() async {
    final current = _auth.currentUser;
    if (current != null) {
      // Try to get user data from Firestore first
      try {
        final userDoc = await _firestore.collection('users').doc(current.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          return User(
            id: current.uid,
            username: data['username'] ?? current.displayName ?? 'Anonymous',
            email: current.email ?? '',
            role: data['role'] ?? 'student',
          );
        }
      } catch (e) {
        // If Firestore fails, fall back to Firebase Auth data
        print('Error fetching user from Firestore: $e');
      }
      
      // Fallback to Firebase Auth data
      return User(
        id: current.uid,
        username: current.displayName ?? 'Anonymous',
        email: current.email ?? '',
        role: 'student', // default role
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
    
    // Try to get user data from Firestore
    try {
      final userDoc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return User(
          id: fbUser.uid,
          username: data['username'] ?? fbUser.displayName ?? 'Anonymous',
          email: fbUser.email ?? '',
          role: data['role'] ?? 'student',
        );
      }
    } catch (e) {
      print('Error fetching user from Firestore during login: $e');
    }
    
    // Fallback to Firebase Auth data
    return User(
      id: fbUser.uid,
      username: fbUser.displayName ?? 'Anonymous',
      email: fbUser.email ?? '',
      role: 'student', // default role
    );
  }

  /// Register
  Future<User> signUp(String username, String email, String password, String role) async {
    final credentials = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = credentials.user!;
    
    // Update display name
    await fbUser.updateDisplayName(username);
    
    // Store user data in Firestore
    final userData = {
      'username': username,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    try {
      await _firestore.collection('users').doc(fbUser.uid).set(userData);
    } catch (e) {
      print('Error saving user to Firestore: $e');
      // Don't throw error here, user is still created in Firebase Auth
    }
    
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