import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/notifications/services/notifications_service.dart';
import 'package:isapp/features/school/models/nigerian_class.dart';
import 'package:isapp/features/school/models/nigerian_position.dart';
import 'package:isapp/features/school/models/school_department.dart';
import 'package:isapp/features/school/models/school_user_profile.dart';
import 'package:isapp/features/school/models/school_user_result.dart';

class FacultyController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Current school
  final Rx<String?> currentSchoolId = Rx(null);
  final Rx<String?> currentSchoolName = Rx(null);
  final Rx<String?> currentSchoolCode = Rx(null);

  // User profiles in school
  final RxList<SchoolUserProfile> schoolUsers = <SchoolUserProfile>[].obs;
  final RxList<SchoolUserProfile> schoolTeachers = <SchoolUserProfile>[].obs;
  final RxList<SchoolUserProfile> schoolStudents = <SchoolUserProfile>[].obs;
  final RxList<SchoolUserProfile> schoolParents = <SchoolUserProfile>[].obs;

  // Classes and Departments
  final RxList<NigerianClass> activeClasses = <NigerianClass>[].obs;
  final RxList<SchoolDepartment> activeDepartments = <SchoolDepartment>[].obs;

  // Statistics
  final RxMap<String, dynamic> schoolStats = RxMap({
    'totalTeachers': 0,
    'totalStudents': 0,
    'totalParents': 0,
    'totalClasses': 0,
    'classDistribution': {},
    'departmentDistribution': {},
  });

  Map<String, dynamic> get statistics {
    return {
      'totalStaff': schoolTeachers.length,
      'totalTeachers': schoolTeachers.length,
      'totalStudents': schoolStudents.length,
      'totalParents': schoolParents.length,
      'totalClasses': activeClasses.length,
    };
  }

  // State
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<NigerianClass?> selectedClass = Rx(null);
  final Rx<SchoolDepartment?> selectedDepartment = Rx(null);
  final Rx<UserType?> selectedUserType = Rx(null);

  // Form Controllers
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController parentIdController = TextEditingController();
  final TextEditingController classCaptainController = TextEditingController();
  final TextEditingController prefectPositionController =
      TextEditingController();

  // Stream Subscriptions
  StreamSubscription? _schoolUsersSubscription;
  StreamSubscription? _schoolSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeSchool();
    _setupSearchListener();
  }

  @override
  void onClose() {
    _schoolUsersSubscription?.cancel();
    _schoolSubscription?.cancel();
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    studentIdController.dispose();
    employeeIdController.dispose();
    parentIdController.dispose();
    classCaptainController.dispose();
    prefectPositionController.dispose();
  }

  Future<void> _initializeSchool() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _loadCurrentSchool(user.uid);
      if (currentSchoolId.value != null) {
        _setupSchoolListeners();
        await _loadSchoolStats();
      }
    } catch (e) {
      print('School initialization error: $e');
      Get.snackbar('Error', 'Failed to initialize school data');
    }
  }

  Future<void> _loadCurrentSchool(String userId) async {
    try {
      // Check if user is a school admin
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final user = createUserFromMap(userData);

        if (user is SchoolAdminUser) {
          currentSchoolId.value = userId; // School admin is the school
          currentSchoolName.value = user.schoolName;
          currentSchoolCode.value = user.schoolCode;
        } else {
          // Check if user has a school profile
          final schoolProfile = await _firestore
              .collection('school_user_profiles')
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

          if (schoolProfile.docs.isNotEmpty) {
            final profile = SchoolUserProfile.fromFirestore(
              schoolProfile.docs.first.data(),
            );
            currentSchoolId.value = profile.schoolId;
            currentSchoolName.value = profile.schoolName;
            currentSchoolCode.value = profile.schoolCode;
          }
        }
      }
    } catch (e) {
      print('Error loading school: $e');
    }
  }

  void _setupSchoolListeners() {
    if (currentSchoolId.value == null) return;

    // Listen to school users
    _schoolUsersSubscription = _firestore
        .collection('school_user_profiles')
        .where('schoolId', isEqualTo: currentSchoolId.value)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          final users = snapshot.docs
              .map((doc) => SchoolUserProfile.fromFirestore(doc.data()))
              .toList();

          schoolUsers.value = users;
          schoolTeachers.value = users.where((u) => u.isTeacher).toList();
          schoolStudents.value = users.where((u) => u.isStudent).toList();
          schoolParents.value = users.where((u) => u.isParent).toList();

          _updateActiveClasses();
          _updateActiveDepartments();
          _updateSchoolStats();
        });

    // Listen to school updates
    _schoolSubscription = _firestore
        .collection('users')
        .doc(currentSchoolId.value)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final user = createUserFromMap(snapshot.data()!);
            if (user is SchoolAdminUser) {
              currentSchoolName.value = user.schoolName;
              currentSchoolCode.value = user.schoolCode;
            }
          }
        });
  }

  void _updateActiveClasses() {
    try {
      final classes = <NigerianClass>{};
      for (final student in schoolStudents) {
        if (student.studentClass != null) {
          classes.add(student.studentClass!);
        }
      }

      // If no classes found from students, use all Nigerian classes
      if (classes.isEmpty) {
        print('No student classes found. Using default classes.');
        activeClasses.value = NigerianClass.values.toList()
          ..sort((a, b) => a.grade.compareTo(b.grade));
      } else {
        activeClasses.value = classes.toList()
          ..sort((a, b) => a.grade.compareTo(b.grade));
      }
    } catch (e) {
      print('Error updating active classes: $e');
      // Fallback to all classes
      activeClasses.value = NigerianClass.values.toList()
        ..sort((a, b) => a.grade.compareTo(b.grade));
    }
  }

  void _updateActiveDepartments() {
    final departments = <SchoolDepartment>{};
    for (final teacher in schoolTeachers) {
      if (teacher.teacherDepartment != null) {
        departments.add(teacher.teacherDepartment!);
      }
    }
    activeDepartments.value = departments.toList();
  }

  void _updateSchoolStats() {
    try {
      final stats = Map<String, dynamic>.from({
        'totalTeachers': schoolTeachers.length,
        'totalStudents': schoolStudents.length,
        'totalParents': schoolParents.length,
        'totalClasses': activeClasses.length,
        'classDistribution': {},
        'departmentDistribution': {},
      });

      // Class distribution
      final classDist = <String, int>{};
      for (final student in schoolStudents) {
        if (student.studentClass != null) {
          final className = student.studentClass!.displayName;
          classDist[className] = (classDist[className] ?? 0) + 1;
        }
      }
      stats['classDistribution'] = classDist;

      // Department distribution
      final deptDist = <String, int>{};
      for (final teacher in schoolTeachers) {
        if (teacher.teacherDepartment != null) {
          final deptName = teacher.teacherDepartment!.name;
          deptDist[deptName] = (deptDist[deptName] ?? 0) + 1;
        }
      }
      stats['departmentDistribution'] = deptDist;

      schoolStats.value = stats;
      print('Updated school stats: $stats');
    } catch (e) {
      print('Error updating school stats: $e');
    }
  }

  void _setupSearchListener() {
    debounce(searchQuery, (_) {
      _filterUsers();
    }, time: const Duration(milliseconds: 300));
  }

  void _filterUsers() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return;

    final filtered = schoolUsers.where((user) {
      return user.userName.toLowerCase().contains(query) ||
          user.userEmail.toLowerCase().contains(query) ||
          (user.studentId?.toLowerCase().contains(query) ?? false) ||
          (user.employeeId?.toLowerCase().contains(query) ?? false) ||
          user.displayRole.toLowerCase().contains(query) ||
          (user.studentClass?.displayName.toLowerCase().contains(query) ??
              false) ||
          (user.teacherDepartment?.name.toLowerCase().contains(query) ?? false);
    }).toList();

    // Update specific lists
    schoolTeachers.value = filtered.where((u) => u.isTeacher).toList();
    schoolStudents.value = filtered.where((u) => u.isStudent).toList();
    schoolParents.value = filtered.where((u) => u.isParent).toList();
  }

  Future<void> _loadSchoolStats() async {
    // Stats are updated in listeners
  }

  Future<SchoolUserResult> addUserToSchool({
    required String userId,
    required UserType userType,
    NigerianClass? studentClass,
    SchoolDepartment? department,
    NigerianPosition? position,
    String? studentId,
    String? employeeId,
    String? parentGuardianId,
    List<String>? assignedSubjects,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      if (currentSchoolId.value == null) {
        return SchoolUserResult.error('No school selected');
      }

      // Get user info
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return SchoolUserResult.error('User not found');
      }

      final userData = userDoc.data()!;
      final user = createUserFromMap(userData);

      // Check if user already has a school profile
      final existingProfile = await _firestore
          .collection('school_user_profiles')
          .where('userId', isEqualTo: userId)
          .where('schoolId', isEqualTo: currentSchoolId.value)
          .limit(1)
          .get();

      if (existingProfile.docs.isNotEmpty) {
        return SchoolUserResult.error('User already exists in this school');
      }

      final profileId = 'school_profile_${userId}_${currentSchoolId.value}';

      final profile = SchoolUserProfile(
        id: profileId,
        userId: userId,
        userEmail: user.email,
        userName: user.name,
        userType: userType,
        schoolId: currentSchoolId.value,
        schoolName: currentSchoolName.value,
        schoolCode: currentSchoolCode.value,
        studentClass: studentClass,
        teacherDepartment: department,
        staffPosition: position,
        employeeId: employeeId,
        studentId: studentId,
        parentGuardianId: parentGuardianId,
        assignedSubjects: assignedSubjects ?? [],
        joinedDate: DateTime.now(),
        enrollmentDate: userType == UserType.student ? DateTime.now() : null,
        isActive: true,
        isVerified: true,
        privileges: _getDefaultPrivileges(userType, position),
      );

      // Save to Firestore
      await _firestore
          .collection('school_user_profiles')
          .doc(profileId)
          .set(profile.toFirestore());

      // Send notification
      await _notificationService.showActivityNotification(
        title: 'School Profile Created',
        body: 'You have been added to ${currentSchoolName.value}',
        payload: 'school_profile_created_$profileId',
      );

      // Update connection status
      await _updateConnectionStatus(userId, true);

      return SchoolUserResult.success(profileId);
    } catch (e) {
      print('Add user to school error: $e');
      return SchoolUserResult.error('Failed to add user to school');
    }
  }

  Map<String, dynamic> _getDefaultPrivileges(
    UserType userType,
    NigerianPosition? position,
  ) {
    switch (userType) {
      case UserType.teacher:
        final level = position?.authorityLevel ?? 1;
        return {
          'canViewStudents': true,
          'canAssignGrades': level >= 1,
          'canManageAttendance': level >= 1,
          'canCreateAssignments': level >= 1,
          'canViewReports': true,
          'canMessageParents': true,
        };
      case UserType.student:
        return {
          'canViewGrades': true,
          'canSubmitAssignments': true,
          'canViewMaterials': true,
          'canMessageTeachers': true,
        };
      case UserType.parent:
        return {
          'canViewChildGrades': true,
          'canViewAttendance': true,
          'canMessageTeachers': true,
          'canReceiveNotifications': true,
        };
      case UserType.schoolAdmin:
        return {
          'canManageUsers': true,
          'canManageClasses': true,
          'canManageDepartments': true,
          'canViewAllReports': true,
          'canAssignRoles': true,
          'canConfigureSystem': true,
        };
      case UserType.kidling:
        return {
          'canAccessKidlingContent': true,
          'canTrackChildProgress': true,
          'canManageChildProfile': true,
          'canAccessActivities': true,
          'canViewReports': true,
          'canReceiveRecommendations': true,
        };
    }
  }

  Future<void> _updateConnectionStatus(String userId, bool isConnected) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore
          .collection('connections')
          .doc('${currentUserId}_$userId')
          .update({
            'schoolConnected': isConnected,
            'schoolConnectionDate': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      print('Error updating connection status: $e');
    }
  }

  Future<SchoolUserResult> updateUserProfile(
    String profileId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection('school_user_profiles')
          .doc(profileId)
          .update(updates);

      // Get profile to send notification
      final profileDoc = await _firestore
          .collection('school_user_profiles')
          .doc(profileId)
          .get();

      if (profileDoc.exists) {
        final profile = SchoolUserProfile.fromFirestore(profileDoc.data()!);

        await _notificationService.showActivityNotification(
          title: 'Profile Updated',
          body: 'Your school profile at ${profile.schoolName} has been updated',
          payload: 'school_profile_updated_$profileId',
        );
      }

      return SchoolUserResult.success(profileId);
    } catch (e) {
      return SchoolUserResult.error('Failed to update profile');
    }
  }

  Future<void> removeUserFromSchool(String profileId) async {
    try {
      // Get profile before deleting
      final profileDoc = await _firestore
          .collection('school_user_profiles')
          .doc(profileId)
          .get();

      if (profileDoc.exists) {
        final profile = SchoolUserProfile.fromFirestore(profileDoc.data()!);

        // Send notification
        await _notificationService.showActivityNotification(
          title: 'School Profile Removed',
          body: 'Your profile at ${profile.schoolName} has been removed',
          payload: 'school_profile_removed_$profileId',
        );

        // Update connection status
        await _updateConnectionStatus(profile.userId, false);
      }

      // Delete profile
      await _firestore.collection('school_user_profiles').doc(profileId).update(
        {'isActive': false, 'updatedAt': Timestamp.now()},
      );
    } catch (e) {
      print('Error removing user from school: $e');
      rethrow;
    }
  }

  // ========== CLASS & DEPARTMENT MANAGEMENT ==========

  Future<void> assignClassTeacher({
    required String teacherProfileId,
    required NigerianClass studentClass,
    required String subject,
  }) async {
    try {
      await _firestore
          .collection('school_user_profiles')
          .doc(teacherProfileId)
          .update({
            'classResponsibilities.${studentClass.displayName}': subject,
            'updatedAt': Timestamp.now(),
          });

      // Get teacher info for notification
      final teacherDoc = await _firestore
          .collection('school_user_profiles')
          .doc(teacherProfileId)
          .get();

      if (teacherDoc.exists) {
        final teacher = SchoolUserProfile.fromFirestore(teacherDoc.data()!);

        await _notificationService.showActivityNotification(
          title: 'Class Assignment',
          body:
              'Dear $teacher., You have been assigned to teach ${studentClass.displayName} - $subject',
          payload: 'class_assigned_${studentClass.displayName}',
        );
      }
    } catch (e) {
      print('Error assigning class teacher: $e');
      rethrow;
    }
  }

  Future<void> assignClassCaptain({
    required String studentProfileId,
    required NigerianClass studentClass,
    required String position,
  }) async {
    try {
      await _firestore
          .collection('school_user_profiles')
          .doc(studentProfileId)
          .update({
            'isClassCaptain': true,
            'classResponsibilities.${studentClass.displayName}': position,
            'updatedAt': Timestamp.now(),
          });

      // Get student info for notification
      final studentDoc = await _firestore
          .collection('school_user_profiles')
          .doc(studentProfileId)
          .get();

      if (studentDoc.exists) {
        final student = SchoolUserProfile.fromFirestore(studentDoc.data()!);

        await _notificationService.showActivityNotification(
          title: 'Leadership Role',
          body:
              'You have been appointed as $position of ${studentClass.displayName}',
          payload: 'class_captain_assigned_${studentClass.displayName}',
        );
      }
    } catch (e) {
      print('Error assigning class captain: $e');
      rethrow;
    }
  }

  Future<void> assignPrefect({
    required String studentProfileId,
    required String position,
    String? department,
  }) async {
    try {
      await _firestore
          .collection('school_user_profiles')
          .doc(studentProfileId)
          .update({
            'isPrefect': true,
            'prefectPosition': position,
            'classResponsibilities.Prefect': department ?? 'General',
            'updatedAt': Timestamp.now(),
          });

      // Get student info for notification
      final studentDoc = await _firestore
          .collection('school_user_profiles')
          .doc(studentProfileId)
          .get();

      if (studentDoc.exists) {
        final student = SchoolUserProfile.fromFirestore(studentDoc.data()!);

        await _notificationService.showActivityNotification(
          title: 'Prefect Appointment',
          body:
              'You have been appointed as $position${department != null ? " ($department)" : ""}',
          payload: 'prefect_appointed_$position',
        );
      }
    } catch (e) {
      print('Error assigning prefect: $e');
      rethrow;
    }
  }

  // ========== QUERY METHODS ==========

  Future<List<SchoolUserProfile>> getUsersByClass(
    NigerianClass studentClass,
  ) async {
    final users = schoolStudents
        .where((user) => user.studentClass == studentClass)
        .toList();
    return users;
  }

  Future<List<SchoolUserProfile>> getUsersByDepartment(
    SchoolDepartment department,
  ) async {
    final users = schoolTeachers
        .where((user) => user.teacherDepartment == department)
        .toList();
    return users;
  }

  Future<SchoolUserProfile?> getUserProfile(String userId) async {
    try {
      final query = await _firestore
          .collection('school_user_profiles')
          .where('userId', isEqualTo: userId)
          .where('schoolId', isEqualTo: currentSchoolId.value)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return SchoolUserProfile.fromFirestore(query.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getClassStats(NigerianClass studentClass) async {
    final students = await getUsersByClass(studentClass);
    final teachers = schoolTeachers
        .where(
          (teacher) => teacher.classResponsibilities.containsKey(
            studentClass.displayName,
          ),
        )
        .toList();

    return {
      'className': studentClass.displayName,
      'classLevel': studentClass.level,
      'totalStudents': students.length,
      'maleStudents': students.where((s) => s.gender == 'male').length,
      'femaleStudents': students.where((s) => s.gender == 'female').length,
      'assignedTeachers': teachers.length,
      'classCaptain': students.firstWhereOrNull((s) => s.isClassCaptain),
      'classPrefects': students.where((s) => s.isPrefect).toList(),
      'averageAge': _calculateAverageAge(students),
    };
  }

  double _calculateAverageAge(List<SchoolUserProfile> students) {
    if (students.isEmpty) return 0.0;

    final now = DateTime.now();
    int totalAge = 0;
    int count = 0;

    for (final student in students) {
      if (student.dateOfBirth != null) {
        final age = now.year - student.dateOfBirth!.year;
        totalAge += age;
        count++;
      }
    }

    return count > 0 ? totalAge / count : 0.0;
  }

  // ========== HELPER METHODS ==========

  void clearFilters() {
    searchQuery.value = '';
    selectedClass.value = null;
    selectedDepartment.value = null;
    selectedUserType.value = null;
  }

  void resetForm() {
    studentIdController.clear();
    employeeIdController.clear();
    parentIdController.clear();
    classCaptainController.clear();
    prefectPositionController.clear();
  }

  Future<void> refreshData() async {
    await _initializeSchool();
    await _loadSchoolStats();
  }

  // ========== NOTIFICATION INTEGRATION ==========

  Future<void> sendSchoolAnnouncement({
    required String title,
    required String message,
    UserType? targetUserType,
    NigerianClass? targetClass,
    SchoolDepartment? targetDepartment,
  }) async {
    try {
      List<SchoolUserProfile> recipients = [];

      if (targetUserType != null) {
        switch (targetUserType) {
          case UserType.teacher:
            recipients = schoolTeachers;
            break;
          case UserType.student:
            recipients = schoolStudents;
            break;
          case UserType.parent:
            recipients = schoolParents;
            break;
          case UserType.schoolAdmin:
            recipients = schoolUsers.where((u) => u.isSchoolAdmin).toList();
            break;
          case UserType.kidling:
            recipients = schoolParents;
            break;
        }
      } else {
        recipients = schoolUsers;
      }

      if (targetClass != null) {
        recipients = recipients
            .where((u) => u.studentClass == targetClass)
            .toList();
      }

      if (targetDepartment != null) {
        recipients = recipients
            .where((u) => u.teacherDepartment == targetDepartment)
            .toList();
      }

      // Send notifications to each recipient
      for (final recipient in recipients) {
        await _notificationService.showActivityNotification(
          title: title,
          body: message,
          payload:
              'school_announcement_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      Get.snackbar(
        'Announcement Sent',
        'Sent to ${recipients.length} recipients',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error sending announcement: $e');
      Get.snackbar(
        'Error',
        'Failed to send announcement',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> notifyParentAboutChild({
    required String parentProfileId,
    required String childName,
    required String message,
    required String notificationType,
  }) async {
    try {
      final profile = await getUserProfile(parentProfileId);
      if (profile != null) {
        await _notificationService.showActivityNotification(
          title: 'Update about $childName',
          body: message,
          payload: 'parent_notification_$notificationType',
        );
      }
    } catch (e) {
      print('Error notifying parent: $e');
    }
  }
}
