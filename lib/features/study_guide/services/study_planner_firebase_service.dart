
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/learning/controllers/scholon_curriculum_planner_adapter.dart';
import 'package:isapp/features/study_guide/models/activity_type.dart';
import 'package:isapp/features/study_guide/models/daily_activity.dart';
import 'package:isapp/features/study_guide/models/learning_profile.dart';
import 'package:isapp/features/study_guide/models/study_schedule.dart';

class StudyPlannerFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _schedulesCollection = 'studentSchedules';
  static const String _activitiesCollection = 'dailyActivities';
  static const String _progressCollection = 'studentProgress';
  static const String _analyticsCollection = 'studentAnalytics';

  Future<void> saveSchedule({
    required String studentId,
    required StudySchedule schedule,
    required AdaptedScholonCurriculum curriculum,
  }) async {
    try {
      print('💾 Saving schedule to Firebase for student: $studentId');

      final batch = _firestore.batch();
      final scheduleRef = _firestore
          .collection(_schedulesCollection)
          .doc(studentId);

      batch.set(scheduleRef, {
        'studentId': studentId,
        'profile': schedule.profile.toString().split('.').last,
        'startDate': Timestamp.fromDate(schedule.startDate),
        'endDate': Timestamp.fromDate(schedule.endDate),
        'subjectWeights': schedule.subjectWeights,
        'totalStudyDays': schedule.totalStudyDays,
        'completedDays': schedule.completedDays,
        'overallProgress': schedule.overallProgress,
        'scholonCurriculum': true,
        'curriculumVersion': curriculum.academicYear,
        'curriculumName': curriculum.curriculum,
        'totalCourses': curriculum.courses.length,
        'totalWeeks': curriculum.schedule.totalWeeks,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      int activityCount = 0;
      for (final entry in schedule.dailyActivities.entries) {
        final date = entry.key;
        final activities = entry.value;

        for (final activity in activities) {
          final activityRef = scheduleRef
              .collection(_activitiesCollection)
              .doc(activity.id);

          batch.set(activityRef, {
            'date': Timestamp.fromDate(date),
            'title': activity.title,
            'description': activity.description,
            'type': activity.type.name,
            'estimatedMinutes': activity.estimatedDuration.inMinutes,
            'courseCodes': activity.courseCodes,
            'progress': activity.progress,
            'isCompleted': false,
            'metadata': activity.metadata,
            'scholonEnhanced': true,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'scheduled',
            'priority': _calculateActivityPriority(activity.type),
            'requiresAttention':
                activity.type == ActivityType.monthlyExam ||
                activity.type == ActivityType.projectWork,
          });
          activityCount++;
        }
      }

      await batch.commit();
      print('✅ Schedule saved with $activityCount activities');

      await _initializeProgressTracking(studentId, activityCount);
    } catch (e, stackTrace) {
      print('❌ Error saving schedule: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  int _calculateActivityPriority(ActivityType type) {
    return switch (type) {
      ActivityType.monthlyExam => 1,
      ActivityType.weeklyMockTest => 2,
      ActivityType.projectWork => 3,
      ActivityType.researchWork => 4,
      ActivityType.dailyQuiz => 5,
      ActivityType.dailyLesson => 6,
      ActivityType.practiceSession => 7,
      ActivityType.revisionSession => 8,
      ActivityType.readingSession => 9,
      ActivityType.groupDiscussion => 10,
      ActivityType.experimentLab => 11,
      ActivityType.problemSolving => 12,
    };
  }

  Future<void> _initializeProgressTracking(
    String studentId,
    int totalActivities,
  ) async {
    try {
      await _firestore.collection(_progressCollection).doc(studentId).set({
        'studentId': studentId,
        'totalActivities': totalActivities,
        'completedActivities': 0,
        'averageScore': 0.0,
        'streak': 0,
        'weeklyHours': 0.0,
        'consistencyScore': 0.0,
        'subjectPerformance': {},
        'lastActivityDate': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection(_analyticsCollection).doc(studentId).set({
        'studentId': studentId,
        'totalStudyDays': 0,
        'totalStudyHours': 0.0,
        'learningEfficiency': 0.0,
        'focusTime': 0.0,
        'retentionRate': 0.0,
        'weeklyGoals': 0,
        'goalsAchieved': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error initializing progress tracking: $e');
    }
  }

  Future<StudySchedule?> loadSchedule(String studentId) async {
    try {
      final scheduleDoc = await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .get();

      if (!scheduleDoc.exists) {
        return null;
      }

      final data = scheduleDoc.data()!;
      final startDate = (data['startDate'] as Timestamp).toDate();
      final endDate = (data['endDate'] as Timestamp).toDate();

      // Load ALL activities for the entire schedule duration
      final activitiesSnapshot = await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .collection(_activitiesCollection)
          .orderBy('date')
          .get();

      final dailyActivities = <DateTime, List<DailyActivity>>{};

      for (var doc in activitiesSnapshot.docs) {
        final activity = DailyActivity.fromJson(doc.data());
        final dateKey = DateTime(
          activity.date.year,
          activity.date.month,
          activity.date.day,
        );
        dailyActivities.putIfAbsent(dateKey, () => []).add(activity);
      }

      return StudySchedule(
        studentId: studentId,
        profile: LearningProfile.values.firstWhere(
          (p) => p.toString().split('.').last == data['profile'],
          orElse: () => LearningProfile.balancedStudent,
        ),
        startDate: startDate,
        endDate: endDate,
        dailyActivities: dailyActivities,
        subjectWeights: Map<String, double>.from(data['subjectWeights'] ?? {}),
        totalStudyDays: (data['totalStudyDays'] as int?) ?? 0,
        completedDays: (data['completedDays'] as int?) ?? 0,
        overallProgress: (data['overallProgress'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('Error loading schedule: $e');
      return null;
    }
  }

  Future<List<DailyActivity>> loadTodayActivities(String studentId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      // First try to load from Firebase
      final snapshot = await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .collection(_activitiesCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('date')
          .get();

      final activities = snapshot.docs
          .map((doc) => DailyActivity.fromJson(doc.data()))
          .where(
            (activity) => activity.id.isNotEmpty && activity.title.isNotEmpty,
          )
          .toList();

      if (activities.isNotEmpty) {
        print('✅ Found ${activities.length} activities for today');
        return activities;
      }

      // If no activities for today, check if schedule exists and generate upcoming activities
      final scheduleDoc = await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .get();

      if (scheduleDoc.exists) {
        print(
          '📅 Schedule exists but no activities for today, showing next scheduled activity',
        );
        // Get the next upcoming activity
        final upcomingSnapshot = await _firestore
            .collection(_schedulesCollection)
            .doc(studentId)
            .collection(_activitiesCollection)
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .orderBy('date')
            .limit(1)
            .get();

        if (upcomingSnapshot.docs.isNotEmpty) {
          final nextActivity = DailyActivity.fromJson(
            upcomingSnapshot.docs.first.data(),
          );
          print(
            '📌 Next activity: ${nextActivity.title} on ${DateFormat('MMM d').format(nextActivity.date)}',
          );

          // Create a "preview" activity for today
          return [
            DailyActivity(
              id: 'preview_${now.millisecondsSinceEpoch}',
              date: now,
              title: 'Preview: ${nextActivity.title}',
              description:
                  'Next scheduled activity: ${DateFormat('EEEE, MMM d').format(nextActivity.date)}\n\n${nextActivity.description}',
              type: ActivityType.dailyLesson,
              estimatedDuration: Duration(minutes: 30),
              courseCodes: nextActivity.courseCodes,
              metadata: {
                ...nextActivity.metadata,
                'isPreview': true,
                'actualDate': nextActivity.date.toIso8601String(),
                'actualActivityId': nextActivity.id,
              },
            ),
          ];
        }
      }

      print('📭 No activities found for today or upcoming');
      return [];
    } catch (e) {
      print('❌ Error loading today activities: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> loadProgressData(String studentId) async {
    try {
      final progressDoc = await _firestore
          .collection(_progressCollection)
          .doc(studentId)
          .get();

      final analyticsDoc = await _firestore
          .collection(_analyticsCollection)
          .doc(studentId)
          .get();

      return {...progressDoc.data() ?? {}, ...analyticsDoc.data() ?? {}};
    } catch (e) {
      print('Error loading progress data: $e');
      return {};
    }
  }

  Future<void> markActivityComplete({
    required String studentId,
    required String activityId,
    required double score,
  }) async {
    try {
      await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .collection(_activitiesCollection)
          .doc(activityId)
          .update({
            'isCompleted': true,
            'progress': 1.0,
            'completedAt': FieldValue.serverTimestamp(),
            'actualScore': score,
          });

      await _recordActivityCompletion(studentId, activityId, score);

      await _updateOverallProgress(studentId, score);
    } catch (e) {
      print('Error marking activity complete: $e');
      rethrow;
    }
  }

  Future<void> _recordActivityCompletion(
    String studentId,
    String activityId,
    double score,
  ) async {
    await _firestore
        .collection(_progressCollection)
        .doc(studentId)
        .collection('completedActivities')
        .doc(activityId)
        .set({
          'activityId': activityId,
          'score': score,
          'completedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _updateOverallProgress(String studentId, double score) async {
    await _firestore.runTransaction((transaction) async {
      final progressRef = _firestore
          .collection(_progressCollection)
          .doc(studentId);
      final doc = await transaction.get(progressRef);

      if (!doc.exists) return;

      final data = doc.data()!;
      final currentScore = (data['averageScore'] as num?)?.toDouble() ?? 0.0;
      final completedCount = (data['completedActivities'] as int?) ?? 0;
      final streak = (data['streak'] as int?) ?? 0;
      final lastActivityDate = (data['lastActivityDate'] as Timestamp?)
          ?.toDate();

      final newAverage = currentScore == 0
          ? score
          : (currentScore * completedCount + score) / (completedCount + 1);

      final newStreak = _calculateNewStreak(streak, lastActivityDate);

      transaction.update(progressRef, {
        'averageScore': newAverage,
        'completedActivities': completedCount + 1,
        'streak': newStreak,
        'lastActivityDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  int _calculateNewStreak(int currentStreak, DateTime? lastActivityDate) {
    if (lastActivityDate == null) return 1;

    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    if (lastActivityDate.year == yesterday.year &&
        lastActivityDate.month == yesterday.month &&
        lastActivityDate.day == yesterday.day) {
      return currentStreak + 1;
    }

    if (lastActivityDate.year == today.year &&
        lastActivityDate.month == today.month &&
        lastActivityDate.day == today.day) {
      return currentStreak;
    }

    return 1;
  }
}
