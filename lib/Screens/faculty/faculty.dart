// ========== INTEGRATED CONNECT & FACULTY SYSTEM ==========

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isapp/Models/user.dart';
import 'package:isapp/Notifications/notifications_service.dart';
import 'package:isapp/Screens/home/connect.dart';

// ========== NIGERIAN EDUCATION SYSTEM ENUMS ==========

enum NigerianClass {
  // Basic Education: Primary 1-6 (ages 6-11)
  primary1('Primary 1', 'Basic', 1, Colors.blue, Icons.child_care_rounded),
  primary2('Primary 2', 'Basic', 2, Colors.blue, Icons.child_care_rounded),
  primary3('Primary 3', 'Basic', 3, Colors.blue, Icons.child_care_rounded),
  primary4('Primary 4', 'Basic', 4, Colors.blue, Icons.child_care_rounded),
  primary5('Primary 5', 'Basic', 5, Colors.blue, Icons.child_care_rounded),
  primary6('Primary 6', 'Basic', 6, Colors.blue, Icons.child_care_rounded),

  // Junior Secondary School: JSS 1-3 (ages 12-14)
  jss1('JSS 1', 'Junior Secondary', 7, Colors.green, Icons.school_rounded),
  jss2('JSS 2', 'Junior Secondary', 8, Colors.green, Icons.school_rounded),
  jss3('JSS 3', 'Junior Secondary', 9, Colors.green, Icons.school_rounded),

  // Senior Secondary School: SSS 1-3 (ages 15-17)
  sss1('SSS 1', 'Senior Secondary', 10, Colors.purple, Icons.school_rounded),
  sss2('SSS 2', 'Senior Secondary', 11, Colors.purple, Icons.school_rounded),
  sss3('SSS 3', 'Senior Secondary', 12, Colors.purple, Icons.school_rounded);

  final String displayName;
  final String level;
  final int grade;
  final Color color;
  final IconData icon;

  const NigerianClass(
    this.displayName,
    this.level,
    this.grade,
    this.color,
    this.icon,
  );

  bool get isPrimary => level == 'Basic';
  bool get isJuniorSecondary => level == 'Junior Secondary';
  bool get isSeniorSecondary => level == 'Senior Secondary';

  String get fullName => '$level $displayName';

  static List<NigerianClass> get primaryClasses =>
      values.where((c) => c.isPrimary).toList();

  static List<NigerianClass> get juniorSecondaryClasses =>
      values.where((c) => c.isJuniorSecondary).toList();

  static List<NigerianClass> get seniorSecondaryClasses =>
      values.where((c) => c.isSeniorSecondary).toList();
}

enum SchoolDepartment {
  // Core Departments
  sciences('Sciences', Icons.science_rounded, Colors.blue),
  artsHumanities('Arts & Humanities', Icons.palette_rounded, Colors.purple),
  commercial('Commercial', Icons.business_rounded, Colors.green),
  technical('Technical', Icons.build_rounded, Colors.orange),
  languages('Languages', Icons.language_rounded, Colors.red),

  // Administrative
  administration(
    'Administration',
    Icons.admin_panel_settings_rounded,
    Colors.teal,
  ),
  guidance('Guidance & Counseling', Icons.psychology_rounded, Colors.pink),
  sports('Sports & PE', Icons.sports_rounded, Colors.amber),
  library('Library', Icons.library_books_rounded, Colors.brown);

  final String name;
  final IconData icon;
  final Color color;

  const SchoolDepartment(this.name, this.icon, this.color);
}

enum NigerianPosition {
  classTeacher('Class Teacher', Icons.class_rounded, 1),
  subjectTeacher('Subject Teacher', Icons.book_rounded, 1),
  headOfDepartment('Head of Department', Icons.leaderboard_rounded, 2),
  vicePrincipal('Vice Principal', Icons.supervisor_account_rounded, 3),
  principal('Principal', Icons.school_rounded, 4),
  bursar('Bursar', Icons.attach_money_rounded, 2),
  librarian('Librarian', Icons.library_books_rounded, 1),
  counselor('Counselor', Icons.psychology_rounded, 1),
  sportsCoach('Sports Coach', Icons.sports_rounded, 1),
  labTechnician('Lab Technician', Icons.science_rounded, 1);

  final String title;
  final IconData icon;
  final int authorityLevel;

  const NigerianPosition(this.title, this.icon, this.authorityLevel);
}

// ========== ENHANCED SCHOOL PROFILE MODEL ==========

class SchoolUserProfile {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final UserType userType;

  // School-specific data
  final String? schoolId;
  final String? schoolName;
  final String? schoolCode;

  // Role-based data
  final NigerianClass? studentClass;
  final SchoolDepartment? teacherDepartment;
  final NigerianPosition? staffPosition;
  final String? employeeId;
  final String? studentId;
  final String? parentGuardianId;

  // Academic data
  final List<String> assignedSubjects;
  final List<String> enrolledSubjects;
  final Map<String, String> classResponsibilities;
  final bool isClassCaptain;
  final bool isPrefect;
  final String? prefectPosition;

  // Parent-specific
  final List<String> childrenIds;
  final List<String> childrenNames;
  final String? relationshipToChild;

  // Administrative
  final DateTime? joinedDate;
  final DateTime? enrollmentDate;
  final bool isActive;
  final bool isVerified;
  final Map<String, dynamic> privileges;

  // Additional info
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? medicalInfo;

  SchoolUserProfile({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userType,
    this.schoolId,
    this.schoolName,
    this.schoolCode,
    this.studentClass,
    this.teacherDepartment,
    this.staffPosition,
    this.employeeId,
    this.studentId,
    this.parentGuardianId,
    this.assignedSubjects = const [],
    this.enrolledSubjects = const [],
    this.classResponsibilities = const {},
    this.isClassCaptain = false,
    this.isPrefect = false,
    this.prefectPosition,
    this.childrenIds = const [],
    this.childrenNames = const [],
    this.relationshipToChild,
    this.joinedDate,
    this.enrollmentDate,
    this.isActive = true,
    this.isVerified = false,
    this.privileges = const {},
    this.profileImageUrl,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.medicalInfo,
  });

  factory SchoolUserProfile.fromFirestore(Map<String, dynamic> data) {
    return SchoolUserProfile(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.name == (data['userType'] ?? 'student'),
        orElse: () => UserType.student,
      ),
      schoolId: data['schoolId'],
      schoolName: data['schoolName'],
      schoolCode: data['schoolCode'],
      studentClass: data['studentClass'] != null
          ? NigerianClass.values.firstWhere(
              (e) => e.displayName == data['studentClass'],
              orElse: () => NigerianClass.primary1,
            )
          : null,
      teacherDepartment: data['teacherDepartment'] != null
          ? SchoolDepartment.values.firstWhere(
              (e) => e.name == data['teacherDepartment'],
              orElse: () => SchoolDepartment.sciences,
            )
          : null,
      staffPosition: data['staffPosition'] != null
          ? NigerianPosition.values.firstWhere(
              (e) => e.title == data['staffPosition'],
              orElse: () => NigerianPosition.subjectTeacher,
            )
          : null,
      employeeId: data['employeeId'],
      studentId: data['studentId'],
      parentGuardianId: data['parentGuardianId'],
      assignedSubjects: List<String>.from(data['assignedSubjects'] ?? []),
      enrolledSubjects: List<String>.from(data['enrolledSubjects'] ?? []),
      classResponsibilities: Map<String, String>.from(
        data['classResponsibilities'] ?? {},
      ),
      isClassCaptain: data['isClassCaptain'] ?? false,
      isPrefect: data['isPrefect'] ?? false,
      prefectPosition: data['prefectPosition'],
      childrenIds: List<String>.from(data['childrenIds'] ?? []),
      childrenNames: List<String>.from(data['childrenNames'] ?? []),
      relationshipToChild: data['relationshipToChild'],
      joinedDate: data['joinedDate'] != null
          ? (data['joinedDate'] as Timestamp).toDate()
          : null,
      enrollmentDate: data['enrollmentDate'] != null
          ? (data['enrollmentDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      privileges: Map<String, dynamic>.from(data['privileges'] ?? {}),
      profileImageUrl: data['profileImageUrl'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: data['gender'],
      bloodGroup: data['bloodGroup'],
      medicalInfo: data['medicalInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userType': userType.name,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'schoolCode': schoolCode,
      'studentClass': studentClass?.displayName,
      'teacherDepartment': teacherDepartment?.name,
      'staffPosition': staffPosition?.title,
      'employeeId': employeeId,
      'studentId': studentId,
      'parentGuardianId': parentGuardianId,
      'assignedSubjects': assignedSubjects,
      'enrolledSubjects': enrolledSubjects,
      'classResponsibilities': classResponsibilities,
      'isClassCaptain': isClassCaptain,
      'isPrefect': isPrefect,
      'prefectPosition': prefectPosition,
      'childrenIds': childrenIds,
      'childrenNames': childrenNames,
      'relationshipToChild': relationshipToChild,
      'joinedDate': joinedDate != null ? Timestamp.fromDate(joinedDate!) : null,
      'enrollmentDate': enrollmentDate != null
          ? Timestamp.fromDate(enrollmentDate!)
          : null,
      'isActive': isActive,
      'isVerified': isVerified,
      'privileges': privileges,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'medicalInfo': medicalInfo,
      'updatedAt': Timestamp.now(),
    };
  }

  bool get isTeacher => userType == UserType.teacher;
  bool get isStudent => userType == UserType.student;
  bool get isParent => userType == UserType.parent;
  bool get isSchoolAdmin => userType == UserType.schoolAdmin;

  String get displayRole {
    if (isTeacher)
      return '${staffPosition?.title ?? "Teacher"} - ${teacherDepartment?.name ?? "Department"}';
    if (isStudent) return 'Student - ${studentClass?.displayName ?? "Class"}';
    if (isParent)
      return 'Parent${relationshipToChild != null ? " ($relationshipToChild)" : ""}';
    return 'School Admin';
  }

  bool get canManageStudents =>
      isSchoolAdmin || (isTeacher && staffPosition!.authorityLevel >= 2);

  bool get canAssignGrades => isTeacher;
  bool get canViewReports => isTeacher || isParent || isSchoolAdmin;
}

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

// ========== RESULT CLASSES ==========

class SchoolUserResult {
  final bool success;
  final String? error;
  final String? profileId;

  SchoolUserResult._({this.success = false, this.error, this.profileId});

  factory SchoolUserResult.success([String? profileId]) {
    return SchoolUserResult._(success: true, profileId: profileId);
  }

  factory SchoolUserResult.error(String error) {
    return SchoolUserResult._(error: error);
  }
}

// ========== INTEGRATED FACULTY PAGE ==========

class FacultyPage extends StatefulWidget {
  const FacultyPage({super.key});

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FacultyController schoolController = Get.put(FacultyController());
  ConnectController? _connectController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    try {
      _connectController = Get.find<ConnectController>();
    } catch (e) {
      print('ConnectController not found: $e');
    }
  }

  void _onTabChanged() {
    schoolController.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Enhanced School Header
            SliverAppBar(
              expandedHeight: 300,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
              shadowColor: Colors.grey.withOpacity(0.3),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildSchoolHeader(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.deepPurple,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.deepPurple,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(
                            text: 'Staff',
                            icon: Icon(Icons.school_rounded, size: 20),
                          ),
                          Tab(
                            text: 'Students',
                            icon: Icon(Icons.people_rounded, size: 20),
                          ),
                          Tab(
                            text: 'Parents',
                            icon: Icon(Icons.family_restroom_rounded, size: 20),
                          ),
                          Tab(
                            text: 'Classes',
                            icon: Icon(Icons.class_rounded, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Add User Button
                IconButton(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                  tooltip: 'Add User to School',
                ),
                // Announcement Button
                IconButton(
                  onPressed: _showAnnouncementDialog,
                  icon: const Icon(
                    Icons.announcement_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  tooltip: 'Send Announcement',
                ),
              ],
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStaffTab(),
            _buildStudentsTab(),
            _buildParentsTab(),
            _buildClassesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolHeader() {
    return Obx(() {
      final schoolName = schoolController.currentSchoolName.value;
      final schoolCode = schoolController.currentSchoolCode.value;
      final stats = schoolController.schoolStats;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade600, Colors.purple.shade600],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schoolName ?? 'No School Selected',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        if (schoolCode != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Code: $schoolCode',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                        const SizedBox(height: 15),

                        // Statistics Row
                        _buildStatisticsRow(),
                      ],
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeaderStat({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildStatisticsRow() {
    final stats = schoolController.schoolStats;

    // Check if stats are still loading or empty
    if (stats.isEmpty || stats['totalTeachers'] == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) => _buildStatSkeleton()),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _StatItem(
          value: stats['totalTeachers']?.toString() ?? '0',
          label: 'Teachers',
          icon: Icons.school_rounded,
          color: Colors.white,
        ),
        SizedBox(width: 6),
        _StatItem(
          value: stats['totalStudents']?.toString() ?? '0',
          label: 'Students',
          icon: Icons.person_rounded,
          color: Colors.white,
        ),
        SizedBox(width: 6),
        _StatItem(
          value: stats['totalParents']?.toString() ?? '0',
          label: 'Parents',
          icon: Icons.family_restroom_rounded,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildStatSkeleton() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStaffTab() {
    return RefreshIndicator(
      onRefresh: () => schoolController.refreshData(),
      child: CustomScrollView(
        slivers: [
          _buildSearchSection('Search staff...'),
          _buildStaffFilters(),
          Obx(() => _buildStaffList()),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return RefreshIndicator(
      onRefresh: () => schoolController.refreshData(),
      child: CustomScrollView(
        slivers: [
          _buildSearchSection('Search students...'),
          _buildStudentFilters(),
          Obx(() => _buildStudentList()),
        ],
      ),
    );
  }

  Widget _buildParentsTab() {
    return RefreshIndicator(
      onRefresh: () => schoolController.refreshData(),
      child: CustomScrollView(
        slivers: [
          _buildSearchSection('Search parents...'),
          Obx(() => _buildParentList()),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    return RefreshIndicator(
      onRefresh: () => schoolController.refreshData(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Class Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manage classes, assign teachers, and monitor student distribution',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          _buildClassFilters(),
          Obx(() => _buildClassList()),
        ],
      ),
    );
  }

  // ========== SEARCH SECTIONS ==========

  SliverToBoxAdapter _buildSearchSection(String hintText) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      schoolController.searchQuery.value = value;
                    },
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(fontSize: 15),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== FILTER SECTIONS ==========

  SliverToBoxAdapter _buildStaffFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Department Filters
            _buildFilterSection(
              title: 'Departments',
              filters: SchoolDepartment.values.map((dept) {
                return Obx(() {
                  final selected =
                      schoolController.selectedDepartment.value == dept;
                  return FilterChip(
                    label: Text(dept.name),
                    selected: selected,
                    onSelected: (_) {
                      schoolController.selectedDepartment.value = selected
                          ? null
                          : dept;
                    },
                    backgroundColor: dept.color.withOpacity(0.1),
                    selectedColor: dept.color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : dept.color,
                      fontWeight: FontWeight.w500,
                    ),
                    avatar: selected
                        ? Icon(dept.icon, size: 16, color: Colors.white)
                        : Icon(dept.icon, size: 16, color: dept.color),
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStudentFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Obx(() {
          // Use activeClasses if available, otherwise show all classes
          final classes = schoolController.activeClasses.isNotEmpty
              ? schoolController.activeClasses
              : NigerianClass.values.toList();

          if (classes.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              _buildFilterSection(
                title: 'Classes',
                filters: classes.map((grade) {
                  final selected =
                      schoolController.selectedClass.value == grade;
                  return FilterChip(
                    label: Text(grade.displayName),
                    selected: selected,
                    onSelected: (_) {
                      schoolController.selectedClass.value = selected
                          ? null
                          : grade;
                    },
                    backgroundColor: grade.color.withOpacity(0.1),
                    selectedColor: grade.color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : grade.color,
                      fontWeight: FontWeight.w500,
                    ),
                    avatar: selected
                        ? Icon(grade.icon, size: 16, color: Colors.white)
                        : Icon(grade.icon, size: 16, color: grade.color),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ),
    );
  }

  SliverToBoxAdapter _buildClassFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Primary'),
              selected: false,
              onSelected: (_) {
                // Filter primary classes
              },
              backgroundColor: Colors.blue.withOpacity(0.1),
              selectedColor: Colors.blue,
            ),
            FilterChip(
              label: const Text('Junior Secondary'),
              selected: false,
              onSelected: (_) {
                // Filter JSS classes
              },
              backgroundColor: Colors.green.withOpacity(0.1),
              selectedColor: Colors.green,
            ),
            FilterChip(
              label: const Text('Senior Secondary'),
              selected: false,
              onSelected: (_) {
                // Filter SSS classes
              },
              backgroundColor: Colors.purple.withOpacity(0.1),
              selectedColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Widget> filters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: filters),
      ],
    );
  }

  // ========== LISTS ==========

  SliverList _buildStaffList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final staffList = schoolController.schoolTeachers;
        if (index >= staffList.length) return null;
        final staff = staffList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _StaffProfileCard(
            profile: staff,
            onTap: () => _showStaffDetails(staff),
          ),
        );
      }, childCount: schoolController.schoolTeachers.length),
    );
  }

  SliverList _buildStudentList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final studentList = schoolController.schoolStudents;
        if (index >= studentList.length) return null;
        final student = studentList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _StudentProfileCard(
            profile: student,
            onTap: () => _showStudentDetails(student),
          ),
        );
      }, childCount: schoolController.schoolStudents.length),
    );
  }

  SliverList _buildParentList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final parentList = schoolController.schoolParents;
        if (index >= parentList.length) return null;
        final parent = parentList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _ParentProfileCard(
            profile: parent,
            onTap: () => _showParentDetails(parent),
          ),
        );
      }, childCount: schoolController.schoolParents.length),
    );
  }

  SliverGrid _buildClassList() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final classes = schoolController.activeClasses;
        if (index >= classes.length) return null;
        final studentClass = classes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _ClassCard(
            studentClass: studentClass,
            onTap: () => _showClassDetails(studentClass),
          ),
        );
      }, childCount: schoolController.activeClasses.length),
    );
  }

  // ========== DIALOGS ==========

  void _showAddUserDialog() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Add User to School',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
            // User Type Selection
            Expanded(child: _buildConnectedUsersList()),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  Widget _buildConnectedUsersList() {
    final connectedUsers = _connectController?.connections ?? [];
    final schoolUsersIds = schoolController.schoolUsers
        .map((u) => u.userId)
        .toSet();

    // Filter out users already in school
    final availableUsers = connectedUsers
        .where((user) => !schoolUsersIds.contains(user.uid))
        .toList();

    if (availableUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Connected Users',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Connect with users first to add them to your school',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: availableUsers.length,
      itemBuilder: (context, index) {
        final user = availableUsers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ConnectUserCard(
            user: user,
            onSelect: () => _showUserRoleDialog(user),
          ),
        );
      },
    );
  }

  void _showUserRoleDialog(BaseUser user) {
    Get.back();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add ${user.name} to School',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select user role in school',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              // Role Selection
              ...UserType.values.map((role) {
                if (role == UserType.schoolAdmin) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getRoleColor(role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getRoleIcon(role),
                        color: _getRoleColor(role),
                      ),
                    ),
                    title: Text(role.displayName),
                    subtitle: Text(_getRoleDescription(role)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showRoleForm(user, role),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleForm(BaseUser user, UserType role) {
    Get.back();

    switch (role) {
      case UserType.teacher:
        Get.to(() => AddTeacherForm(user: user));
        break;
      case UserType.student:
        Get.to(() => AddStudentForm(user: user));
        break;
      case UserType.parent:
        Get.to(() => AddParentForm(user: user));
        break;
      default:
        break;
    }
  }

  void _showAnnouncementDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send Announcement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Send announcement
                        Get.back();
                        Get.snackbar(
                          'Announcement Sent',
                          'Your announcement has been sent',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStaffDetails(SchoolUserProfile staff) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color:
                          staff.teacherDepartment?.color.withOpacity(0.1) ??
                          Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        staff.userName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: staff.teacherDepartment?.color ?? Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          staff.displayRole,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Details
              _buildDetailSection(
                title: 'Contact Information',
                children: [
                  _buildDetailItem(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: staff.userEmail,
                  ),
                  if (staff.phoneNumber != null)
                    _buildDetailItem(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: staff.phoneNumber!,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection(
                title: 'Professional Information',
                children: [
                  if (staff.employeeId != null)
                    _buildDetailItem(
                      icon: Icons.badge_rounded,
                      label: 'Employee ID',
                      value: staff.employeeId!,
                    ),
                  if (staff.teacherDepartment != null)
                    _buildDetailItem(
                      icon: staff.teacherDepartment!.icon,
                      label: 'Department',
                      value: staff.teacherDepartment!.name,
                      color: staff.teacherDepartment!.color,
                    ),
                  if (staff.staffPosition != null)
                    _buildDetailItem(
                      icon: staff.staffPosition!.icon,
                      label: 'Position',
                      value: staff.staffPosition!.title,
                    ),
                  if (staff.assignedSubjects.isNotEmpty)
                    _buildDetailItem(
                      icon: Icons.subject_rounded,
                      label: 'Subjects',
                      value: staff.assignedSubjects.join(', '),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _editStaffProfile(staff),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showStudentDetails(SchoolUserProfile student) {
    // Similar to staff details but for students
  }

  void _showParentDetails(SchoolUserProfile parent) {
    // Similar to staff details but for parents
  }

  void _showClassDetails(NigerianClass studentClass) {
    Get.to(() => ClassDetailsPage(studentClass: studentClass));
  }

  void _editStaffProfile(SchoolUserProfile staff) {
    Get.to(() => EditProfileForm(profile: staff));
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (color ?? Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color ?? Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserType role) {
  switch (role) {
    case UserType.teacher:
      return Colors.blue;
    case UserType.student:
      return Colors.purple;
    case UserType.parent:
      return Colors.deepOrange;
    case UserType.schoolAdmin:
      return Colors.teal;
    case UserType.kidling:
      return Colors.red;
  }
}

  IconData _getRoleIcon(UserType role) {
  switch (role) {
    case UserType.teacher:
      return Icons.school_rounded;
    case UserType.student:
      return Icons.person_rounded;
    case UserType.parent:
      return Icons.family_restroom_rounded;
    case UserType.schoolAdmin:
      return Icons.admin_panel_settings_rounded;
    case UserType.kidling:
      return Icons.child_care_rounded;
  }
}

  String _getRoleDescription(UserType role) {
  switch (role) {
    case UserType.teacher:
      return 'Teach subjects, assign grades, manage classes';
    case UserType.student:
      return 'Attend classes, submit assignments, participate';
    case UserType.parent:
      return 'Monitor child progress, receive updates';
    case UserType.schoolAdmin:
      return 'Manage school operations, users, and settings';
    case UserType.kidling:
      return 'Fun learning adventures for early childhood education';
  }
}

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ========== PROFILE CARDS ==========

class _StaffProfileCard extends StatelessWidget {
  final SchoolUserProfile profile;
  final VoidCallback onTap;

  const _StaffProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (profile.teacherDepartment?.color ?? Colors.blue)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: profile.teacherDepartment?.color ?? Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.staffPosition != null)
                      Text(
                        profile.staffPosition!.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (profile.teacherDepartment != null)
                      Text(
                        profile.teacherDepartment!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: profile.teacherDepartment!.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              // Action
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentProfileCard extends StatelessWidget {
  final SchoolUserProfile profile;
  final VoidCallback onTap;

  const _StudentProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (profile.studentClass?.color ?? Colors.purple)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: profile.studentClass?.color ?? Colors.purple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.studentClass != null)
                      Text(
                        profile.studentClass!.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: profile.studentClass!.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (profile.studentId != null)
                      Text(
                        'ID: ${profile.studentId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              // Leadership badges
              if (profile.isClassCaptain || profile.isPrefect) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.isClassCaptain ? 'Captain' : 'Prefect',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentProfileCard extends StatelessWidget {
  final SchoolUserProfile profile;
  final VoidCallback onTap;

  const _ParentProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.childrenNames.isNotEmpty)
                      Text(
                        '${profile.childrenNames.length} children',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.deepOrange,
                        ),
                      ),
                    if (profile.relationshipToChild != null)
                      Text(
                        profile.relationshipToChild!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final NigerianClass studentClass;
  final VoidCallback onTap;

  const _ClassCard({required this.studentClass, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: studentClass.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: studentClass.color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(studentClass.icon, color: studentClass.color, size: 32),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: studentClass.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      studentClass.level.substring(0, 1),
                      style: TextStyle(
                        fontSize: 11,
                        color: studentClass.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                studentClass.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                studentClass.level,
                style: TextStyle(
                  fontSize: 13,
                  color: studentClass.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 14,
                    color: studentClass.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '24 Students', // You would get this from stats
                    style: TextStyle(fontSize: 12, color: studentClass.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectUserCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onSelect;

  const _ConnectUserCard({required this.user, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final color = _getUserColor(user);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.userType.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user is StudentUser)
                    Text(
                      (user as StudentUser).schoolName ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUserColor(BaseUser user) {
    switch (user.userType) {
      case UserType.teacher:
        return Colors.blue;
      case UserType.kidling:
        return Colors.red;
      case UserType.student:
        return Colors.purple;
      case UserType.parent:
        return Colors.deepOrange;
      case UserType.schoolAdmin:
        return Colors.teal;
    }
  }
}

// ========== FORM PAGES ==========

class AddTeacherForm extends StatefulWidget {
  final BaseUser user;

  const AddTeacherForm({super.key, required this.user});

  @override
  State<AddTeacherForm> createState() => _AddTeacherFormState();
}

class _AddTeacherFormState extends State<AddTeacherForm> {
  final FacultyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController employeeIdController = TextEditingController();
  final Rx<SchoolDepartment?> selectedDepartment = Rx(null);
  final Rx<NigerianPosition?> selectedPosition = Rx(
    NigerianPosition.subjectTeacher,
  );
  final RxList<String> selectedSubjects = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.user.name} as Teacher'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              _buildUserInfoCard(),
              const SizedBox(height: 32),
              // Teacher Details
              _buildFormSection(
                title: 'Teacher Details',
                children: [
                  TextFormField(
                    controller: employeeIdController,
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Department Selection
                  _buildDepartmentSelection(),
                  const SizedBox(height: 16),
                  // Position Selection
                  _buildPositionSelection(),
                  const SizedBox(height: 16),
                  // Subjects
                  _buildSubjectsSelection(),
                ],
              ),
              const SizedBox(height: 40),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Teacher'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildDepartmentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Department', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SchoolDepartment.values.map((dept) {
            return Obx(() {
              final selected = selectedDepartment.value == dept;
              return ChoiceChip(
                label: Text(dept.name),
                selected: selected,
                onSelected: (_) => selectedDepartment.value = dept,
                backgroundColor: dept.color.withOpacity(0.1),
                selectedColor: dept.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : dept.color,
                ),
                avatar: Icon(dept.icon, size: 16),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPositionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Position', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NigerianPosition.values.map((position) {
            return Obx(() {
              final selected = selectedPosition.value == position;
              return ChoiceChip(
                label: Text(position.title),
                selected: selected,
                onSelected: (_) => selectedPosition.value = position,
                backgroundColor: Colors.blue.withOpacity(0.1),
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.blue,
                ),
                avatar: Icon(position.icon, size: 16),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectsSelection() {
    final subjects = [
      'Mathematics',
      'English',
      'Physics',
      'Chemistry',
      'Biology',
      'Economics',
      'Geography',
      'History',
      'Government',
      'Literature',
      'French',
      'Arabic',
      'Fine Arts',
      'Music',
      'Home Economics',
      'Agricultural Science',
      'Technical Drawing',
      'Computer Studies',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subjects', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects.map((subject) {
              final selected = selectedSubjects.contains(subject);
              return FilterChip(
                label: Text(subject),
                selected: selected,
                onSelected: (value) {
                  if (value) {
                    selectedSubjects.add(subject);
                  } else {
                    selectedSubjects.remove(subject);
                  }
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.green,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedDepartment.value != null) {
      final result = await controller.addUserToSchool(
        userId: widget.user.uid,
        userType: UserType.teacher,
        department: selectedDepartment.value,
        position: selectedPosition.value,
        employeeId: employeeIdController.text,
        assignedSubjects: selectedSubjects.toList(),
      );

      if (result.success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Teacher added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result.error ?? 'Failed to add teacher',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}

// Similar forms for AddStudentForm and AddParentForm would follow the same pattern

class AddStudentForm extends StatefulWidget {
  final BaseUser user;

  const AddStudentForm({super.key, required this.user});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final FacultyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController studentIdController = TextEditingController();
  final Rx<NigerianClass?> selectedClass = Rx(null);
  final RxString selectedGender = RxString('male');
  final TextEditingController dateOfBirthController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.user.name} as Student'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoCard(),
              const SizedBox(height: 32),
              // Student Details
              _buildFormSection(
                title: 'Student Details',
                children: [
                  TextFormField(
                    controller: studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Class Selection
                  _buildClassSelection(),
                  const SizedBox(height: 16),
                  // Gender Selection
                  _buildGenderSelection(),
                  const SizedBox(height: 16),
                  // Date of Birth
                  TextFormField(
                    controller: dateOfBirthController,
                    readOnly: true,
                    onTap: () => _selectDateOfBirth(),
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () => _selectDateOfBirth(),
                        icon: const Icon(Icons.calendar_today_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Student'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        // Primary Classes
        const Text('Primary', style: TextStyle(fontSize: 14)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NigerianClass.primaryClasses.map((grade) {
            return Obx(() {
              final selected = selectedClass.value == grade;
              return ChoiceChip(
                label: Text(grade.displayName),
                selected: selected,
                onSelected: (_) => selectedClass.value = grade,
                backgroundColor: grade.color.withOpacity(0.1),
                selectedColor: grade.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : grade.color,
                ),
              );
            });
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Junior Secondary
        const Text('Junior Secondary', style: TextStyle(fontSize: 14)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NigerianClass.juniorSecondaryClasses.map((grade) {
            return Obx(() {
              final selected = selectedClass.value == grade;
              return ChoiceChip(
                label: Text(grade.displayName),
                selected: selected,
                onSelected: (_) => selectedClass.value = grade,
                backgroundColor: grade.color.withOpacity(0.1),
                selectedColor: grade.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : grade.color,
                ),
              );
            });
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Senior Secondary
        const Text('Senior Secondary', style: TextStyle(fontSize: 14)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NigerianClass.seniorSecondaryClasses.map((grade) {
            return Obx(() {
              final selected = selectedClass.value == grade;
              return ChoiceChip(
                label: Text(grade.displayName),
                selected: selected,
                onSelected: (_) => selectedClass.value = grade,
                backgroundColor: grade.color.withOpacity(0.1),
                selectedColor: grade.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : grade.color,
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => RadioListTile(
                  title: const Text('Male'),
                  value: 'male',
                  groupValue: selectedGender.value,
                  onChanged: (value) => selectedGender.value = value!,
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => RadioListTile(
                  title: const Text('Female'),
                  value: 'female',
                  groupValue: selectedGender.value,
                  onChanged: (value) => selectedGender.value = value!,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dateOfBirthController.text =
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedClass.value != null) {
      final result = await controller.addUserToSchool(
        userId: widget.user.uid,
        userType: UserType.student,
        studentClass: selectedClass.value,
        studentId: studentIdController.text,
      );

      if (result.success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Student added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result.error ?? 'Failed to add student',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}

class AddParentForm extends StatefulWidget {
  final BaseUser user;

  const AddParentForm({super.key, required this.user});

  @override
  State<AddParentForm> createState() => _AddParentFormState();
}

class _AddParentFormState extends State<AddParentForm> {
  final FacultyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController parentIdController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();
  final RxList<String> selectedChildren = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.user.name} as Parent'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoCard(),
              const SizedBox(height: 32),
              // Parent Details
              _buildFormSection(
                title: 'Parent Details',
                children: [
                  TextFormField(
                    controller: parentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Parent ID (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: relationshipController,
                    decoration: const InputDecoration(
                      labelText: 'Relationship to Child',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Father, Mother, Guardian',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Children Selection
                  _buildChildrenSelection(),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Parent'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildChildrenSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link Children',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final students = controller.schoolStudents;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: students.map((student) {
              final selected = selectedChildren.contains(student.id);
              return FilterChip(
                label: Text(student.userName),
                selected: selected,
                onSelected: (value) {
                  if (value) {
                    selectedChildren.add(student.id);
                  } else {
                    selectedChildren.remove(student.id);
                  }
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.deepOrange,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final childrenNames = controller.schoolStudents
          .where((student) => selectedChildren.contains(student.id))
          .map((student) => student.userName)
          .toList();

      final result = await controller.addUserToSchool(
        userId: widget.user.uid,
        userType: UserType.parent,
        parentGuardianId: parentIdController.text.isEmpty
            ? null
            : parentIdController.text,
        additionalInfo: {
          'relationship': relationshipController.text,
          'childrenNames': childrenNames,
        },
      );

      if (result.success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Parent added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result.error ?? 'Failed to add parent',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}

// ========== CLASS DETAILS PAGE ==========

class ClassDetailsPage extends StatefulWidget {
  final NigerianClass studentClass;

  const ClassDetailsPage({super.key, required this.studentClass});

  @override
  State<ClassDetailsPage> createState() => _ClassDetailsPageState();
}

class _ClassDetailsPageState extends State<ClassDetailsPage> {
  final FacultyController controller = Get.find();
  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.studentClass.displayName)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: controller.getClassStats(widget.studentClass),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Header
                _buildClassHeader(stats),
                const SizedBox(height: 32),
                // Statistics
                _buildStatistics(stats),
                const SizedBox(height: 32),
                // Students
                _buildStudentsSection(),
                const SizedBox(height: 32),
                // Teachers
                _buildTeachersSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassHeader(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.studentClass.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.studentClass.color),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: widget.studentClass.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.studentClass.icon,
              color: widget.studentClass.color,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentClass.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.studentClass.level,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.studentClass.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: widget.studentClass.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats['totalStudents']} Students',
                      style: TextStyle(color: widget.studentClass.color),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: widget.studentClass.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Average Age: ${stats['averageAge'].toStringAsFixed(1)}',
                      style: TextStyle(color: widget.studentClass.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _StatCard(
              value: stats['totalStudents'].toString(),
              label: 'Total Students',
              color: Colors.blue,
              icon: Icons.people_rounded,
            ),
            _StatCard(
              value: stats['maleStudents'].toString(),
              label: 'Male Students',
              color: Colors.blue.shade700,
              icon: Icons.male_rounded,
            ),
            _StatCard(
              value: stats['femaleStudents'].toString(),
              label: 'Female Students',
              color: Colors.pink,
              icon: Icons.female_rounded,
            ),
            _StatCard(
              value: stats['assignedTeachers'].toString(),
              label: 'Teachers',
              color: Colors.green,
              icon: Icons.school_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Students',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                // View all students
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final students = controller.schoolStudents
              .where((s) => s.studentClass == widget.studentClass)
              .take(5)
              .toList();

          return Column(
            children: students.map((student) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: widget.studentClass.color.withOpacity(0.1),
                  child: Text(
                    student.userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: widget.studentClass.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(student.userName),
                subtitle: Text(student.studentId ?? 'No ID'),
                trailing: student.isClassCaptain || student.isPrefect
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          student.isClassCaptain ? 'Captain' : 'Prefect',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTeachersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Teachers',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final teachers = controller.schoolTeachers.where((teacher) {
            return teacher.classResponsibilities.containsKey(
              widget.studentClass.displayName,
            );
          }).toList();

          if (teachers.isEmpty) {
            return const Center(
              child: Text('No teachers assigned to this class'),
            );
          }

          return Column(
            children: teachers.map((teacher) {
              final subject = teacher
                  .classResponsibilities[widget.studentClass.displayName];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(
                    teacher.userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(teacher.userName),
                subtitle: Text(
                  '$subject • ${teacher.staffPosition?.title ?? 'Teacher'}',
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ========== EDIT PROFILE FORM ==========

class EditProfileForm extends StatefulWidget {
  final SchoolUserProfile profile;

  const EditProfileForm({super.key, required this.profile});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final FacultyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: () {
              // Save changes
            },
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Form fields based on user type
              if (widget.profile.isTeacher) _buildTeacherForm(),
              if (widget.profile.isStudent) _buildStudentForm(),
              if (widget.profile.isParent) _buildParentForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherForm() {
    return Column(
      children: [
        // Teacher-specific fields
      ],
    );
  }

  Widget _buildStudentForm() {
    return Column(
      children: [
        // Student-specific fields
      ],
    );
  }

  Widget _buildParentForm() {
    return Column(
      children: [
        // Parent-specific fields
      ],
    );
  }
}

class SchoolManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FacultyController());
  }
}

// ========== STAT ITEM WIDGET ==========
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Icon(icon, color: color, size: 10)),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
