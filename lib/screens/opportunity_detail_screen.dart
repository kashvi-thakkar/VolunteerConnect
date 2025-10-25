import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_connect/services/auth_service.dart';
import 'package:volunteer_connect/services/volunteer_service.dart';
import '../models/volunteer_opportunity.dart';

// We need to convert this to a StatefulWidget to manage state
class OpportunityDetailScreen extends StatefulWidget {
  final VolunteerOpportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final VolunteerService _volunteerService = VolunteerService();
  late Future<bool> _isRegisteredFuture;

  @override
  void initState() {
    super.initState();
    // Check the registration status when the screen loads
    _isRegisteredFuture =
        _volunteerService.isUserRegistered(widget.opportunity.id);
  }

  // This helper builds the info rows
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  // --- NEW ---
  // This builds the correct button based on the registration status
  Widget _buildActionButton(bool isRegistered) {
    // --- 1. If user IS registered, show CANCEL button ---
    if (isRegistered) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancel Registration'),
        onPressed: () async {
          final result =
              await _volunteerService.cancelRegistration(widget.opportunity.id);
          if (mounted) {
            if (result == 'Success') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration successfully cancelled.'),
                  backgroundColor: Colors.green,
                ),
              );
              // Update the button state
              setState(() {
                _isRegisteredFuture = Future.value(false);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result), backgroundColor: Colors.red),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.red[700], // Red color for cancel
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // --- 2. If user is NOT registered, show SIGN UP button ---
    return ElevatedButton.icon(
      icon: const Icon(Icons.how_to_reg),
      label: const Text('Sign Up to Volunteer'),
      onPressed: () async {
        final result =
            await _volunteerService.signUpForOpportunity(widget.opportunity.id);

        if (mounted) {
          if (result == 'Success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully registered for the event!'),
                backgroundColor: Colors.green,
              ),
            );
            // Update the button state
            setState(() {
              _isRegisteredFuture = Future.value(true);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result), backgroundColor: Colors.red),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.green[800], // Green color for sign up
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      // The button is now built using a FutureBuilder
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<bool>(
          future: _isRegisteredFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a disabled loading button while checking
              return ElevatedButton.icon(
                icon: const Icon(Icons.hourglass_empty),
                label: const Text('Loading...'),
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
            // Once loaded, build the correct button
            // If snapshot has error or is null, default to 'false' (not registered)
            final bool isRegistered = snapshot.data ?? false;
            return _buildActionButton(isRegistered);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Section (Info + Image) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.opportunity.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(widget.opportunity.category),
                        backgroundColor: Colors.green.shade100,
                        side: BorderSide.none,
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                        Icons.calendar_today,
                        DateFormat('EEE, d MMMM yyyy')
                            .format(widget.opportunity.date),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.location_on,
                        widget.opportunity.location,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.opportunity.imageUrl,
                      fit: BoxFit.cover,
                      height: 180,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child:
                            Icon(Icons.broken_image, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // --- Bottom Section (Description) ---
            Text(
              'About this opportunity',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.opportunity.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}