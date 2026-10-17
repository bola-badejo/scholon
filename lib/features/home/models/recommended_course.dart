import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/study_guide/study_guide.dart';

class RecommendedCourse {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String level;
  final int lessons;
  final double progress;
  final String? courseCode;
  final String? subject;
  final int totalActivities;
  final int completedActivities;

  RecommendedCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.level,
    required this.lessons,
    required this.progress,
    this.courseCode,
    this.subject,
    this.totalActivities = 0,
    this.completedActivities = 0,
  });
}
