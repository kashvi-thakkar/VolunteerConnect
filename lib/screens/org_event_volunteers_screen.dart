import 'package:flutter/material.dart';
import 'package:volunteer_connect/services/volunteer_service.dart'; // Import service
import '../models/volunteer_profile.dart';

class OrgEventVolunteersScreen extends StatefulWidget {
  final String opportunityId;
  final String eventName;

  const OrgEventVolunteersScreen({
    super.key,
    required this.opportunityId,
    required this.eventName,
  });

  @override
  State<OrgEventVolunteersScreen> createState() =>
      _OrgEventVolunteersScreenState();
}

class _OrgEventVolunteersScreenState extends State<OrgEventVolunteersScreen> {
  late Future<List<VolunteerProfile>> _volunteersFuture;
  final VolunteerService _volunteerService = VolunteerService();

  @override
  void initState() {
    super.initState();
    _volunteersFuture =
        _volunteerService.getVolunteersForEvent(widget.opportunityId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteers for ${widget.eventName}'),
      ),
      body: FutureBuilder<List<VolunteerProfile>>(
        future: _volunteersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading volunteers: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No volunteers have registered for this event yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final volunteers = snapshot.data!;

          return ListView.builder(
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final volunteer = volunteers[index];
              final initial = volunteer.name.isNotEmpty
                  ? volunteer.name[0].toUpperCase()
                  : '?';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: volunteer.imageUrl != null
                      ? NetworkImage(volunteer.imageUrl!)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: volunteer.imageUrl == null ? Text(initial) : null,
                ),
                title: Text(volunteer.name),
                subtitle: Text(volunteer.email),
                // Add more actions later if needed (e.g., contact volunteer)
              );
            },
          );
        },
      ),
    );
  }
}