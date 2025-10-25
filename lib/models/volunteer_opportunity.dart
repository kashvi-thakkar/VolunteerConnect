import 'package:flutter/material.dart';
import '../models/volunteer_opportunity.dart';

class VolunteerOpportunity {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String category;
  final String imageUrl;

  VolunteerOpportunity({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.category,
    required this.imageUrl,
  });
}