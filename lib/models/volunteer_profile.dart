// lib/models/volunteer_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- CORRECT PATH

class VolunteerProfile {
  final String uid;
  final String name;
  final String email;
  final String? imageUrl;
  final String role; // <-- Added role!

  VolunteerProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.imageUrl,
  });

  // Helper method to create a profile from a snapshot
  factory VolunteerProfile.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VolunteerProfile(
      uid: doc.id,
      name: data['fullName'] ?? 'No Name',
      email: data['email'] ?? 'No Email',
      role: data['role'] ?? 'volunteer', // Default to volunteer
      imageUrl: data['imageUrl'],
    );
  }
}