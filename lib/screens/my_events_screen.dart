import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_connect/models/volunteer_opportunity.dart';
import 'package:volunteer_connect/services/volunteer_service.dart';
import 'package:volunteer_connect/screens/opportunity_detail_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

// --- UPDATED: Add 'with TickerProviderStateMixin' for the TabController ---
class _MyEventsScreenState extends State<MyEventsScreen>
    with TickerProviderStateMixin {
  late Future<List<VolunteerOpportunity>> _myEventsFuture;
  final VolunteerService _volunteerService = VolunteerService();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _myEventsFuture = _volunteerService.getMyRegisteredEvents();
    });
  }

  // (This widget is unchanged)
  Widget _buildOpportunityListItem(VolunteerOpportunity event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Image.network(
            event.imageUrl,
            height: 130,
            width: 110,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              height: 130,
              width: 110,
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(event.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: TextButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label:
                          const Text('Cancel', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () async {
                        final bool? confirm = await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Cancellation'),
                            content: const Text(
                                'Are you sure you want to cancel your registration for this event?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Yes, Cancel'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final result = await _volunteerService
                              .cancelRegistration(event.id);
                          if (mounted) {
                            if (result == 'Success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Registration successfully cancelled.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadEvents(); // Refresh the list
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(result),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.chevron_right, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // --- NEW: Helper widget for the list view to avoid repetition ---
  Widget _buildEventList(List<VolunteerOpportunity> events) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'No Events Yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You have no events in this category.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OpportunityDetailScreen(opportunity: events[index]),
                      ),
                    );
                    _loadEvents(); // Refresh when returning
                  },
                  child: _buildOpportunityListItem(events[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Upcoming and Past
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Registered Events'),
          // --- NEW: Add the TabBar to the AppBar ---
          bottom: TabBar(
            indicatorColor: Colors.green[800],
            labelColor: Colors.green[800],
            unselectedLabelColor: Colors.grey[600],
            tabs: const [
              Tab(text: 'UPCOMING'),
              Tab(text: 'PAST'),
            ],
          ),
        ),
        // --- UPDATED: The body is now a TabBarView ---
        body: FutureBuilder<List<VolunteerOpportunity>>(
          future: _myEventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Show a generic "no events" message if the list is completely empty
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'No Events Yet',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have not registered for any events. Check the "Opportunities" tab to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            // --- NEW: Split the list into upcoming and past ---
            final allEvents = snapshot.data!;
            final now = DateTime.now();
            
            final upcomingEvents = allEvents
                .where((event) => event.date.isAfter(now))
                .toList();
            
            final pastEvents = allEvents
                .where((event) => event.date.isBefore(now))
                .toList();

            return TabBarView(
              children: [
                // 1. Upcoming Events Tab
                _buildEventList(upcomingEvents),
                // 2. Past Events Tab
                _buildEventList(pastEvents),
              ],
            );
          },
        ),
      ),
    );
  }
}