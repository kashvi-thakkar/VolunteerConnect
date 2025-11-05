// lib/services/volunteer_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/volunteer_opportunity.dart'; // Ensure you have this model
import '../models/volunteer_profile.dart'; // <-- Import your new model

class VolunteerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- ALL YOUR ORIGINAL EVENT & REGISTRATION METHODS ---

  Future<List<VolunteerOpportunity>> getOpportunities() async {
    try {
      final snapshot =
          await _firestore.collection('opportunities').orderBy('date').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        Timestamp timestamp = data['date'] ?? Timestamp.now();
        return VolunteerOpportunity(
          id: doc.id,
          name: data['name'] ?? 'No Name',
          date: timestamp.toDate(),
          location: data['location'] ?? 'No Location',
          description: data['description'] ?? 'No Description',
          category: data['category'] ?? 'General',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error fetching opportunities: $e");
      return [];
    }
  }

  Future<String> signUpForOpportunity(String opportunityId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Error: You must be logged in to register.';
    try {
      final querySnapshot = await _firestore
          .collection('registrations')
          .where('userId', isEqualTo: user.uid)
          .where('opportunityId', isEqualTo: opportunityId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) return 'Already Registered';
      await _firestore.collection('registrations').add({
        'userId': user.uid,
        'opportunityId': opportunityId,
        'registrationDate': Timestamp.now(),
      });
      return 'Success';
    } catch (e) {
      print("Error signing up for opportunity: $e");
      return 'Error: An unexpected error occurred.';
    }
  }

  Future<bool> isUserRegistered(String opportunityId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final querySnapshot = await _firestore
          .collection('registrations')
          .where('userId', isEqualTo: user.uid)
          .where('opportunityId', isEqualTo: opportunityId)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking registration status: $e");
      return false;
    }
  }

  Future<List<VolunteerOpportunity>> getMyRegisteredEvents() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    try {
      final regSnapshot = await _firestore
          .collection('registrations')
          .where('userId', isEqualTo: user.uid)
          .get();
      if (regSnapshot.docs.isEmpty) return [];
      final opportunityIds = regSnapshot.docs
          .map((doc) => doc.data()['opportunityId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      if (opportunityIds.isEmpty) return [];

      if (opportunityIds.length > 30) {
        print(
            "Warning: Fetching registered events limited to 30 due to Firestore constraints.");
      }
      final queryIds = opportunityIds.take(30).toList();

      final oppSnapshot = await _firestore
          .collection('opportunities')
          .where(FieldPath.documentId, whereIn: queryIds)
          .get();
      return oppSnapshot.docs.map((doc) {
        final data = doc.data();
        Timestamp timestamp = data['date'] ?? Timestamp.now();
        return VolunteerOpportunity(
          id: doc.id,
          name: data['name'] ?? 'No Name',
          date: timestamp.toDate(),
          location: data['location'] ?? 'No Location',
          description: data['description'] ?? 'No Description',
          category: data['category'] ?? 'General',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error fetching registered events: $e");
      return [];
    }
  }

  Future<String> cancelRegistration(String opportunityId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Error: You must be logged in.';
    try {
      final querySnapshot = await _firestore
          .collection('registrations')
          .where('userId', isEqualTo: user.uid)
          .where('opportunityId', isEqualTo: opportunityId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return 'Error: Registration not found.';
      final docId = querySnapshot.docs.first.id;
      await _firestore.collection('registrations').doc(docId).delete();
      return 'Success';
    } catch (e) {
      print("Error cancelling registration: $e");
      return 'Error: An unexpected error occurred.';
    }
  }

  Future<Map<String, int>> getOrganizationStats() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'totalEvents': 0, 'totalRegistrations': 0};
    }
    int totalEvents = 0;
    int totalRegistrations = 0;
    try {
      final eventsSnapshot = await _firestore
          .collection('opportunities')
          .where('ownerId', isEqualTo: user.uid)
          .count()
          .get();
      totalEvents = eventsSnapshot.count ?? 0;

      final ownedEventsSnapshot = await _firestore
          .collection('opportunities')
          .where('ownerId', isEqualTo: user.uid)
          .get();
      final ownedEventIds =
          ownedEventsSnapshot.docs.map((doc) => doc.id).toList();

      if (ownedEventIds.isNotEmpty) {
        final queryIds = ownedEventIds.take(30).toList();
        final regsSnapshot = await _firestore
            .collection('registrations')
            .where('opportunityId', whereIn: queryIds)
            .count()
            .get();
        totalRegistrations = regsSnapshot.count ?? 0;
      }

      return {
        'totalEvents': totalEvents,
        'totalRegistrations': totalRegistrations
      };
    } catch (e) {
      print("Error fetching organization stats: $e");
      return {'totalEvents': 0, 'totalRegistrations': 0};
    }
  }

  Future<List<VolunteerProfile>> getVolunteersForEvent(
      String opportunityId) async {
    try {
      final regSnapshot = await _firestore
          .collection('registrations')
          .where('opportunityId', isEqualTo: opportunityId)
          .get();

      if (regSnapshot.docs.isEmpty) {
        return [];
      }

      final userIds = regSnapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      if (userIds.isEmpty) return [];

      final queryIds = userIds.take(30).toList();
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: queryIds)
          .get();

      return usersSnapshot.docs.map((doc) {
        // Use the factory constructor from your model
        return VolunteerProfile.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();
    } catch (e) {
      print("Error fetching volunteers for event: $e");
      return [];
    }
  }

  Future<VolunteerOpportunity?> getOpportunityById(String opportunityId) async {
    try {
      final doc =
          await _firestore.collection('opportunities').doc(opportunityId).get();
      if (doc.exists) {
        final data = doc.data()!;
        Timestamp timestamp = data['date'] ?? Timestamp.now();
        return VolunteerOpportunity(
          id: doc.id,
          name: data['name'] ?? 'No Name',
          date: timestamp.toDate(),
          location: data['location'] ?? 'No Location',
          description: data['description'] ?? 'No Description',
          category: data['category'] ?? 'General',
          imageUrl: data['imageUrl'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print("Error fetching opportunity by ID: $e");
      return null;
    }
  }

  // --- ALL YOUR NEW PROFILE METHODS ---

  Future<String> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
      return 'Success';
    } catch (e) {
      print("Error updating user profile: $e");
      return 'Error: Failed to update profile';
    }
  }

  Future<VolunteerProfile?> getCurrentUserProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return VolunteerProfile.fromSnapshot(
            doc);
      }
      return null;
    } catch (e) {
      print("Error fetching current user profile: $e");
      return null;
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final ref =
          _storage.ref().child('profile_images').child('${user.uid}.jpg');
      
      UploadTask uploadTask;
      if (kIsWeb) {
        // Handle web
        uploadTask = ref.putData(await imageFile.readAsBytes());
      } else {
        // Handle mobile
        uploadTask = ref.putFile(imageFile);
      }
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading profile image: $e");
      throw Exception('Image upload failed');
    }
  }
}