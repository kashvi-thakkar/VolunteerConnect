// lib/services/auth_service.dart (Reverted)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIGN UP METHOD (Removed imageUrl field)
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.reload();

        // Save user data to Firestore (without imageUrl)
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email.trim(),
          'uid': user.uid,
          'createdAt': Timestamp.now(),
          'role': role,
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("Error signing up: ${e.message}");
      return null;
    }
  }

  // SIGN IN METHOD (Unchanged)
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error signing in: ${e.message}");
      return null;
    }
  }

  // SIGN OUT METHOD (Unchanged)
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Updates the user's name (Unchanged)
  Future<String> updateUserName(String newName) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return 'Error: No user logged in.';
    }
    try {
      await user.updateDisplayName(newName);
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': newName,
      });
      return 'Success';
    } catch (e) {
      print('Error updating name: $e');
      return 'Error: Could not update name.';
    }
  }

  // uploadProfilePicture method REMOVED
}