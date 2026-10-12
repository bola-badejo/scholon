// lib/Models/learning_profile.dart
import 'package:isapp/Learning/study_planner_screen.dart';

enum LearningProfile {
  pacedLearner, 
  balancedStudent,
  acceleratedLearner
}

enum ActivityType {
  dailyLesson('dailyLesson'),
  dailyQuiz('dailyQuiz'),
  weeklyMockTest('weeklyMockTest'),
  monthlyExam('monthlyExam'),
  practiceSession('practiceSession'),
  revisionSession('revisionSession'),
  projectWork('projectWork'),
  readingSession('readingSession');

  final String name;
  const ActivityType(this.name);
}

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

  double get completionRate => totalStudyDays > 0 
      ? completedDays / totalStudyDays 
      : 0.0;

      Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'profile': profile.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalStudyDays': totalStudyDays,
      'completedDays': completedDays,
      'overallProgress': overallProgress,
      'subjectWeights': subjectWeights,
      'dailyActivities': _dailyActivitiesToJson(dailyActivities),
    };
  }

  Map<String, dynamic> _dailyActivitiesToJson(Map<DateTime, List<DailyActivity>> activities) {
    final Map<String, dynamic> result = {};
    
    for (final entry in activities.entries) {
      final dateKey = entry.key.toIso8601String();
      result[dateKey] = entry.value.map((activity) => activity.toJson()).toList();
    }
    
    return result;
  }
}

class SubjectFocus {
  final String subjectCode;
  final String subjectName;
  final double weight; // 0.0 to 1.0
  final List<String> topics;
  final int weeklyHours;
  final double currentMastery; // 0.0 to 1.0

  SubjectFocus({
    required this.subjectCode,
    required this.subjectName,
    required this.weight,
    required this.topics,
    required this.weeklyHours,
    this.currentMastery = 0.0,
  });
}