import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volunteer_connect/auth_gate.dart';
import 'firebase_options.dart';
import 'screens/opportunities_screen.dart';
import 'screens/how_to_join_screen.dart';
import 'screens/my_events_screen.dart';
import 'screens/profile_screen.dart';
import 'package:volunteer_connect/screens/org_manage_events_screen.dart';
import 'package:volunteer_connect/screens/org_dashboard_screen.dart';
// TODO: Create organization-specific screens later
// import 'screens/org_manage_events_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const VolunteerConnectApp());
}

class VolunteerConnectApp extends StatelessWidget {
  const VolunteerConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VolunteerConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _userRole = 'volunteer';
  bool _isLoadingRole = true;

  static const List<Widget> _volunteerScreens = <Widget>[
    OpportunitiesScreen(),
    MyEventsScreen(),
    HowToJoinScreen(),
    ProfileScreen(),
  ];

  // --- THIS IS THE FIX ---
  // The list now has 3 items to match the 3 organization nav tabs.
  // The placeholder Scaffold has been removed.
  static const List<Widget> _organizationScreens = <Widget>[
    OrgManageEventsScreen(), // Index 0
    OrgDashboardScreen(),    // Index 1
    ProfileScreen(),         // Index 2
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userRole = data['role'] ?? 'volunteer';
            _isLoadingRole = false;
          });
        } else {
          setState(() => _isLoadingRole = false);
        }
      } catch (e) {
        print("Error fetching user role: $e");
        setState(() => _isLoadingRole = false);
      }
    } else {
      setState(() => _isLoadingRole = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> currentScreens =
        _userRole == 'organization' ? _organizationScreens : _volunteerScreens;

    final List<BottomNavigationBarItem> currentNavItems =
        _userRole == 'organization'
            ? _buildOrganizationNavItems()
            : _buildVolunteerNavItems();

    if (_selectedIndex >= currentNavItems.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: currentScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: currentNavItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        // Your FIX 2 comment points to this, which is already correct.
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
      ),
    );
  }

  List<BottomNavigationBarItem> _buildVolunteerNavItems() {
    return const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.volunteer_activism),
        label: 'Opportunities',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.event_available),
        label: 'My Events',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.how_to_reg),
        label: 'How to Join',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ];
  }

  List<BottomNavigationBarItem> _buildOrganizationNavItems() {
    return const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.edit_calendar),
        label: 'Manage Events',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ];
  }
}