import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:isapp/features/study_guide/models/daily_activity.dart';
import 'package:isapp/features/study_guide/models/learning_profile.dart';

// Study Schedule Model
class StudySchedule {
  final String studentId;
  final LearningProfile profile;
  final DateTime startDate;
  final DateTime endDate;
  final Map<DateTime, List<DailyActivity>> dailyActivities;
  final Map<String, double> subjectWeights;
  final int totalStudyDays;
  final int completedDays;
  final double overallProgress;

  StudySchedule({
    required this.studentId,
    required this.profile,
    required this.startDate,
    required this.endDate,
    required this.dailyActivities,
    required this.subjectWeights,
    this.totalStudyDays = 0,
    this.completedDays = 0,
    this.overallProgress = 0.0,
  });

  double get completionRate =>
      totalStudyDays > 0 ? completedDays / totalStudyDays : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'profile': profile.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'subjectWeights': subjectWeights,
      'totalStudyDays': totalStudyDays,
      'completedDays': completedDays,
      'overallProgress': overallProgress,
    };
  }
}
