import 'package:flutter/material.dart';
import 'package:volunteer_connect/services/auth_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        // The 'actions' property belongs inside the AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              // Call the signOut method from your service
              AuthService().signOut();
              // The AuthGate will automatically handle navigation
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ensure you have a 'logo.png' file in your root assets folder
            Image.asset('assets/images/logo.png', height: 150),
            const SizedBox(height: 16),
            Text(
              "VolunteerConnect",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our Mission",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.green[800]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "\"Creating a cleaner, greener, and kinder community through the power of dedicated volunteers.\"",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              "Contact Us",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email),
                SizedBox(width: 8),
                Text("helpinghands@email.com"),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone),
                SizedBox(width: 8),
                Text("+91-9876543210"),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.facebook, size: 30, color: Colors.blue),
                // Using placeholder icons for others
                Icon(Icons.camera_alt, size: 30, color: Colors.pink),
                Icon(Icons.link, size: 30, color: Colors.blueAccent),
              ],
            )
          ],
        ),
      ),
    );
  }
}