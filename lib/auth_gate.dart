// lib/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volunteer_connect/main.dart'; // Imports MainScreen
import 'package:volunteer_connect/screens/landing_screen.dart'; // <-- IMPORT LANDING SCREEN
import 'package:volunteer_connect/screens/role_selection_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  Future<DocumentSnapshot?> getUserData(User user) async {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        
        // 1. User is not logged in
        if (!authSnapshot.hasData) {
          // --- THIS IS THE FIX ---
          // Show your LandingScreen, not LoginScreen
          return const LandingScreen(); 
        }

        final user = authSnapshot.data!;

        // 2. User is logged in, check their 'users' document
        return FutureBuilder<DocumentSnapshot?>(
          future: getUserData(user),
          builder: (context, userDocSnapshot) {
            
            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // 3. User is logged in but has no document (first-time sign-up)
            if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
              // This sends them to pick a role after signing up
              return const RoleSelectionScreen();
            }

            // 4. User is logged in and HAS a document/role
            // Send them to MainScreen, which will handle the role-based UI.
            return const MainScreen();
          },
        );
      },
    );
  }
}