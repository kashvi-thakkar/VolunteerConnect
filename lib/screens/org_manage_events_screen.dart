import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_connect/models/volunteer_opportunity.dart';
import 'package:volunteer_connect/screens/org_add_edit_event_screen.dart';
import 'package:volunteer_connect/screens/org_event_volunteers_screen.dart'; // <-- 1. Import screen

class OrgManageEventsScreen extends StatefulWidget {
  const OrgManageEventsScreen({super.key});

  @override
  State<OrgManageEventsScreen> createState() => _OrgManageEventsScreenState();
}

class _OrgManageEventsScreenState extends State<OrgManageEventsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Stream<List<VolunteerOpportunity>> _getOrganizationEvents() {
    // ... (This method is unchanged)
    if (_currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('opportunities')
        .where('ownerId', isEqualTo: _currentUser.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
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
    });
  }

  void _navigateToAddEditScreen({VolunteerOpportunity? event}) {
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrgAddEditEventScreen(event: event),
      ),
    );
  }

  Future<void> _deleteEvent(String eventId, String eventName) async {
     // ... (This method is unchanged)
     final bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete the event "$eventName"? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );
      if (confirmDelete == true) {
        try {
          await _firestore.collection('opportunities').doc(eventId).delete();
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event deleted successfully'), backgroundColor: Colors.green));
          }
        } catch (e) {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error deleting event: $e'), backgroundColor: Colors.red));
           }
        }
      }
  }


  Widget _buildEventTile(VolunteerOpportunity event) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(event.imageUrl),
        onBackgroundImageError: (_, __) {},
        backgroundColor: Colors.grey[200],
        child: event.imageUrl.isEmpty
            ? const Icon(Icons.event, color: Colors.grey)
            : null,
      ),
      title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
          '${DateFormat('d MMM yyyy').format(event.date)} - ${event.location}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton( // Edit Button
            icon: Icon(Icons.edit, color: Colors.blue[600]),
            tooltip: 'Edit Event',
            onPressed: () => _navigateToAddEditScreen(event: event),
          ),
          IconButton( // Delete Button
            icon: Icon(Icons.delete, color: Colors.red[600]),
            tooltip: 'Delete Event',
            onPressed: () => _deleteEvent(event.id, event.name),
          ),
        ],
      ),
      // --- 2. UPDATE: Make ListTile tappable to view volunteers ---
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrgEventVolunteersScreen(
              opportunityId: event.id,
              eventName: event.name,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Events'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add New Event'),
        backgroundColor: Colors.green[800],
        onPressed: () => _navigateToAddEditScreen(), // Add event
      ),
      body: StreamBuilder<List<VolunteerOpportunity>>(
        stream: _getOrganizationEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'You haven\'t created any events yet.\nTap the "+" button to add one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Padding for FAB
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _buildEventTile(events[index]);
            },
          );
        },
      ),
    );
  }
}