// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/volunteer_service.dart'; // Adjust path
import '../models/volunteer_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final VolunteerService _volunteerService = VolunteerService();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  VolunteerProfile? _profile;
  File? _imageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; });
    _profile = await _volunteerService.getCurrentUserProfile();
    if (_profile != null) {
      _nameController.text = _profile!.name;
    }
    setState(() { _isLoading = false; });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;
    setState(() { _isLoading = true; });

    try {
      String? imageUrl;
      // 1. Upload new image if one was selected
      if (_imageFile != null) {
        imageUrl = await _volunteerService.uploadProfileImage(_imageFile!);
      }

      // 2. Prepare update data
      Map<String, dynamic> updates = {
        'fullName': _nameController.text,
      };
      if (imageUrl != null) {
        updates['imageUrl'] = imageUrl;
      }

      // 3. Update the profile in Firestore
      await _volunteerService.updateUserProfile(_profile!.uid, updates);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      // Refresh profile data
      _loadProfile();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }
  
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to login screen
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => LoginScreen()), 
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Could not load profile.'))
              : ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (_profile?.imageUrl != null
                                    ? NetworkImage(_profile!.imageUrl!)
                                    : null) as ImageProvider?,
                            child: _imageFile == null && _profile?.imageUrl == null
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profile!.email,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _logout,
                      child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
    );
  }
}