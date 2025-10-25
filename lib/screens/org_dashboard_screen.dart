// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../services/volunteer_service.dart'; // Adjust path as needed

class OrgDashboardScreen extends StatefulWidget {
  const OrgDashboardScreen({Key? key}) : super(key: key);

  @override
  _OrgDashboardScreenState createState() => _OrgDashboardScreenState();
}

class _OrgDashboardScreenState extends State<OrgDashboardScreen> {
  final VolunteerService _volunteerService = VolunteerService();
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _volunteerService.getOrganizationStats();
  }

  // Helper method to build the stat cards
  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      elevation: 2.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green.shade700),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50.withOpacity(0.5),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Add navigation logic if needed
          },
        ),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found.'));
          }

          final stats = snapshot.data!;
          final totalEvents = stats['totalEvents'] ?? 0;
          final totalSignups = stats['totalRegistrations'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Events Created',
                  totalEvents,
                  Icons.calendar_today,
                ),
                _buildStatCard(
                  'Total Volunteer Sign-ups',
                  totalSignups,
                  Icons.people,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}