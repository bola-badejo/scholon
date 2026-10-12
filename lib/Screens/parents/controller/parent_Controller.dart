// lib/Screens/Parent/controllers/parent_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:isapp/Models/user.dart';

class ParentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Parent user
  final Rx<ParentUser?> parentUser = Rx<ParentUser?>(null);

  // Children data
  final RxList<StudentUser> children = <StudentUser>[].obs;
  final RxList<Map<String, dynamic>> schoolConnections = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> teacherConnections = <Map<String, dynamic>>[].obs;

  // Analytics
  final RxMap<String, dynamic> familyAnalytics = RxMap({});
  final RxMap<String, Map<String, dynamic>> childAnalytics = RxMap({});

  // Loading states
  final RxBool isLoadingChildren = false.obs;
  final RxBool isLoadingAnalytics = false.obs;
  final RxBool isLoadingConnections = false.obs;

  // Stats
  final RxInt totalChildren = 0.obs;
  final RxDouble averageProgress = 0.0.obs;
  final RxInt totalAssignments = 0.obs;
  final RxInt completedAssignments = 0.obs;
  final RxInt averageScore = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _loadParentUser(user.uid);
      await _loadChildren();
      await _loadAnalytics();
      await _loadConnections();
    } catch (e) {
      print('Parent controller initialization error: $e');
    }
  }

  Future<void> _loadParentUser(String userId) async {
    try {
      final doc = await _firestore.collection('parent_details').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['userType'] = 'parent';
        parentUser.value = ParentUser.fromMap(data);
      }
    } catch (e) {
      print('Error loading parent user: $e');
    }
  }

  Future<void> _loadChildren() async {
    try {
      isLoadingChildren.value = true;
      final parentId = _auth.currentUser?.uid;
      if (parentId == null) return;

      // Load children from parent profile
      if (parentUser.value != null) {
        final childrenIds = parentUser.value!.children;
        final childrenList = <StudentUser>[];

        for (final childId in childrenIds) {
          final doc = await _firestore.collection('student_details').doc(childId).get();
          if (doc.exists) {
            final data = doc.data()!;
            data['userType'] = 'student';
            childrenList.add(StudentUser.fromMap(data));
          }
        }

        children.value = childrenList;
        totalChildren.value = childrenList.length;
      }
    } catch (e) {
      print('Error loading children: $e');
    } finally {
      isLoadingChildren.value = false;
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      isLoadingAnalytics.value = true;

      double totalProgress = 0;
      int totalAssign = 0;
      int completedAssign = 0;
      int totalScore = 0;
      int count = 0;

      for (final child in children) {
        final analytics = await _getChildAnalytics(child.uid);
        childAnalytics[child.uid] = analytics;

        totalProgress += analytics['overallProgress'] ?? 0;
        totalAssign += int.parse(analytics['totalAssignments']) ?? 0;
        completedAssign += int.parse(analytics['completedAssignments']) ?? 0;
        totalScore += int.parse(analytics['averageScore']) ?? 0;
        count++;
      }

      if (count > 0) {
        averageProgress.value = totalProgress / count;
        averageScore.value = totalScore ~/ count;
      }
      
      totalAssignments.value = totalAssign;
      completedAssignments.value = completedAssign;

      familyAnalytics.value = {
        'averageProgress': averageProgress.value,
        'averageScore': averageScore.value,
        'completionRate': totalAssign > 0 ? (completedAssign / totalAssign * 100) : 0,
        'totalStudyTime': await _getTotalStudyTime(),
        'activeDays': await _getActiveDays(),
      };
    } catch (e) {
      print('Error loading analytics: $e');
    } finally {
      isLoadingAnalytics.value = false;
    }
  }

  Future<Map<String, dynamic>> _getChildAnalytics(String childId) async {
    try {
      final progressSnapshot = await _firestore
          .collection('student_progress')
          .doc(childId)
          .get();

      final assignmentsSnapshot = await _firestore
          .collection('assignments')
          .where('studentId', isEqualTo: childId)
          .get();

      final scoresSnapshot = await _firestore
          .collection('quiz_scores')
          .where('studentId', isEqualTo: childId)
          .get();

      final assignments = assignmentsSnapshot.docs;
      final completedAssignments = assignments.where((doc) => 
          doc.data()['status'] == 'completed').length;

      final scores = scoresSnapshot.docs;
      final averageScore = scores.isNotEmpty ? 
          scores.fold(0, (sum, doc) => sum + (int.parse(doc.data()['score']) ?? 0)) / scores.length : 0;

      return {
        'overallProgress': progressSnapshot.data()?['overallProgress'] ?? 0,
        'totalAssignments': assignments.length,
        'completedAssignments': completedAssignments,
        'averageScore': averageScore.toInt(),
        'courses': progressSnapshot.data()?['courses'] ?? [],
        'lastActive': progressSnapshot.data()?['lastActive'],
      };
    } catch (e) {
      print('Error getting child analytics: $e');
      return {};
    }
  }

  Future<void> _loadConnections() async {
    try {
      isLoadingConnections.value = true;

      final schools = <Map<String, dynamic>>[];
      final teachers = <Map<String, dynamic>>[];

      for (final child in children) {
        // Load school connections
        if (child.schoolName != null && child.schoolName!.isNotEmpty) {
          final school = {
            'id': child.schoolName,
            'name': child.schoolName,
            'student': child.name,
            'grade': child.classGrade?.toString() ?? 'N/A',
            'connectionDate': DateTime.now(),
          };
          schools.add(school);
        }

        // Load teacher connections (this would need actual teacher data)
        // For now, we'll simulate
        teachers.addAll([
          {
            'id': 'teacher1_${child.uid}',
            'name': 'Mr. Johnson',
            'subject': 'Mathematics',
            'student': child.name,
            'school': child.schoolName,
          },
          {
            'id': 'teacher2_${child.uid}',
            'name': 'Ms. Williams',
            'subject': 'English',
            'student': child.name,
            'school': child.schoolName,
          },
        ]);
      }

      schoolConnections.value = schools;
      teacherConnections.value = teachers;
    } catch (e) {
      print('Error loading connections: $e');
    } finally {
      isLoadingConnections.value = false;
    }
  }

  Future<int> _getTotalStudyTime() async {
    int totalMinutes = 0;
    for (final child in children) {
      totalMinutes += child.totalStudyTime;
    }
    return totalMinutes;
  }

  Future<int> _getActiveDays() async {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    int activeDays = 0;

    // This would need actual activity data from Firestore
    // For now, return estimated active days
    return children.length * 3;
  }

  void refreshAll() async {
    await Future.wait([
      _loadChildren(),
      _loadAnalytics(),
      _loadConnections(),
    ]);
  }

  String getCompletionRate() {
    final rate = totalAssignments.value > 0 
        ? (completedAssignments.value / totalAssignments.value * 100) 
        : 0;
    return '${rate.toStringAsFixed(1)}%';
  }

  String getFormattedStudyTime() {
    final hours = (familyAnalytics['totalStudyTime'] ?? 0) ~/ 60;
    final minutes = (familyAnalytics['totalStudyTime'] ?? 0) % 60;
    return '${hours}h ${minutes}m';
  }
}