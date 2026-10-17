import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/study_guide/study_guide.dart';

class UpcomingQuiz {
  final String id;
  final String subject;
  final String topic;
  final DateTime dateTime;
  final int duration; // in minutes
  final int totalQuestions;
  final IconData icon;
  final Color color;
  final String? description;
  final String? activityType;
  final String? courseCode;

  UpcomingQuiz({
    required this.id,
    required this.subject,
    required this.topic,
    required this.dateTime,
    required this.duration,
    required this.totalQuestions,
    required this.icon,
    required this.color,
    this.description,
    this.activityType,
    this.courseCode,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) return 'Today, ${_formatTime(dateTime)}';
    if (difference.inDays == 1) return 'Tomorrow, ${_formatTime(dateTime)}';

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (difference.inDays <= 7)
      return '${weekdays[dateTime.weekday - 1]}, ${_formatTime(dateTime)}';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
