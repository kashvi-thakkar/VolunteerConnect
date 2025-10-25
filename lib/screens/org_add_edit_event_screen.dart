import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_connect/models/volunteer_opportunity.dart';

class OrgAddEditEventScreen extends StatefulWidget {
  final VolunteerOpportunity? event; // Pass event for editing, null for adding

  const OrgAddEditEventScreen({super.key, this.event});

  @override
  State<OrgAddEditEventScreen> createState() => _OrgAddEditEventScreenState();
}

class _OrgAddEditEventScreenState extends State<OrgAddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCategory = 'Community'; // Default category
  XFile? _selectedImageFile; // For the picked image file
  String? _existingImageUrl; // To store URL if editing

  bool _isLoading = false;

  final List<String> _categories = [
    'Community',
    'Environment',
    'Education',
    'Health',
    'Charity',
    'Animals'
  ];

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing event data
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _locationController.text = widget.event!.location;
      _descriptionController.text = widget.event!.description;
      _selectedDate = widget.event!.date;
      _selectedCategory = widget.event!.category;
      _existingImageUrl = widget.event!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Image Picking Logic ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = image;
      });
    }
  }

  // --- Date Picking Logic ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      // Allow selecting time as well
       final TimeOfDay? pickedTime = await showTimePicker(
         context: context,
         initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
       );
       if (pickedTime != null) {
         setState(() {
           _selectedDate = DateTime(
             picked.year,
             picked.month,
             picked.day,
             pickedTime.hour,
             pickedTime.minute,
           );
         });
       }
    }
  }

  // --- Form Submission Logic ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) {
      return; // Validation failed or no user
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time.')));
      return;
    }
    // Need an image if creating, optional if editing and one exists
    if (_selectedImageFile == null && _existingImageUrl == null) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image for the event.')));
       return;
    }


    setState(() => _isLoading = true);

    String? imageUrl = _existingImageUrl; // Start with existing image URL

    try {
      // --- 1. Upload Image (if a new one was selected) ---
      if (_selectedImageFile != null) {
        final String fileName =
            'opportunity_images/${DateTime.now().millisecondsSinceEpoch}_${_selectedImageFile!.name}';
        final Reference storageRef = _storage.ref().child(fileName);

        if (kIsWeb) {
          await storageRef.putData(await _selectedImageFile!.readAsBytes());
        } else {
          await storageRef.putFile(File(_selectedImageFile!.path));
        }
        imageUrl = await storageRef.getDownloadURL(); // Get the new URL
      }

      // --- 2. Prepare Data for Firestore ---
      final eventData = {
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'date': Timestamp.fromDate(_selectedDate!),
        'imageUrl': imageUrl,
        'ownerId': _currentUser!.uid, // Link event to the organization
      };

      // --- 3. Save or Update Firestore Document ---
      if (widget.event == null) {
        // Add new document
        await _firestore.collection('opportunities').add(eventData);
      } else {
        // Update existing document
        await _firestore
            .collection('opportunities')
            .doc(widget.event!.id)
            .update(eventData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Event ${widget.event == null ? 'added' : 'updated'} successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Go back after saving
      }
    } catch (e) {
      print('Error saving event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving event: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Add New Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Event Name ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter event name' : null,
              ),
              const SizedBox(height: 16),

              // --- Location ---
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),

              // --- Date & Time Picker ---
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(_selectedDate == null
                    ? 'Select Date & Time'
                    : DateFormat('EEE, d MMM yyyy - hh:mm a').format(_selectedDate!)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // --- Category Dropdown ---
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- Description ---
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 24),

              // --- Image Picker ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedImageFile != null
                          ? 'Image Selected: ${_selectedImageFile!.name}'
                          : (_existingImageUrl != null
                              ? 'Current Image Selected'
                              : 'No Image Selected'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: Text(_existingImageUrl != null || _selectedImageFile != null
                            ? 'Change Image'
                            : 'Select Image'),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              // --- Image Preview (Optional but nice) ---
              if (_selectedImageFile != null || _existingImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _selectedImageFile != null
                          ? (kIsWeb
                              ? Image.network(_selectedImageFile!.path, height: 150)
                              : Image.file(File(_selectedImageFile!.path), height: 150))
                          : Image.network(_existingImageUrl!, height: 150),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // --- Submit Button ---
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update Event' : 'Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}