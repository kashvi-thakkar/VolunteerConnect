// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:volunteer_connect/screens/org_manage_events_screen.dart';
import 'org_manage_events_screen.dart'; // This import will now work
import 'org_dashboard_screen.dart'; // Make sure this file exists
import 'profile_screen.dart';     // Make sure this file exists

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Start on Dashboard

  static const List<Widget> _widgetOptions = <Widget>[
    OrgManageEventsScreen(),
    OrgDashboardScreen(), // Changed to OrgDashboardScreen
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Manage Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade800,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}