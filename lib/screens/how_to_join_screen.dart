import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. IMPORT
import 'package:flutter/material.dart';

class HowToJoinScreen extends StatelessWidget {
  const HowToJoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Become a Volunteer'),
      ),
      // <-- 2. WRAP with a StreamBuilder
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final bool isLoggedIn = snapshot.hasData;

          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Colors.green,
                  ),
            ),
            child: Stepper(
              currentStep: isLoggedIn ? 1 : 0, // Show first step as active
              steps: [
                Step(
                  // <-- 3. MAKE step dynamic
                  title: Text(
                    isLoggedIn ? 'Sign Up (Completed!)' : '1. Sign Up',
                  ),
                  content: Text(
                    isLoggedIn
                        ? 'You are already logged in and have completed this step. Well done!'
                        : 'Register your name and contact details with our organization to get started.',
                  ),
                  isActive: isLoggedIn, // Mark as active if logged in
                  state: isLoggedIn
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('2. Pick an Event'),
                  content: const Text(
                      'Browse through our list of opportunities and choose one that you feel passionate about.'),
                  isActive: true,
                ),
                Step(
                  title: const Text('3. Arrive On Time'),
                  content: const Text(
                      'Punctuality is key. Please arrive at the specified location at least 15 minutes early.'),
                  isActive: true,
                ),
                Step(
                  title: const Text('4. Participate!'),
                  content: const Text(
                      'Engage with the community, follow the coordinator\'s lead, and make a real difference!'),
                  isActive: true,
                ),
              ],
              // Remove buttons as this is for display only
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}