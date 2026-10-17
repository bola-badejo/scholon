import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/study_guide/study_guide.dart';

class CourseProgress {
  final String courseCode;
  int totalActivities;
  int completedActivities;
  double totalProgress;

  CourseProgress({
    required this.courseCode,
    required this.totalActivities,
    required this.completedActivities,
    required this.totalProgress,
  });
}
