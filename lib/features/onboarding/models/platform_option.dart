import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PlatformOption {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final IconData icon;
  final Color color;
  final String image;
  final List<String> features;

  PlatformOption({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.color,
    required this.image,
    required this.features,
  });
}
