import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:isapp/Models/user.dart';
import 'package:isapp/Screens/faculty/faculty.dart';
import 'package:isapp/Screens/home/connect.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

// ========== MODELS ==========

class SchoolData {
  final String id;
  final String name;
  final String? code;

  SchoolData({required this.id, required this.name, this.code});
}

class TeacherSchool {
  final String schoolId;
  final String schoolName;
  final String schoolCode;
  final NigerianPosition position;
  final List<String> assignedClasses;
  final bool isActive;
  final DateTime joinedDate;

  TeacherSchool({
    required this.schoolId,
    required this.schoolName,
    required this.schoolCode,
    required this.position,
    required this.assignedClasses,
    required this.isActive,
    required this.joinedDate,
  });
}

enum ContentType {
  note('Note', Icons.note_rounded, Colors.blue),
  material('Material', Icons.description_rounded, Colors.green),
  video('Video', Icons.video_library_rounded, Colors.red),
  assignment('Assignment', Icons.assignment_rounded, Colors.orange),
  test('Test', Icons.quiz_rounded, Colors.purple),
  exam('Exam', Icons.assignment_turned_in_rounded, Colors.deepPurple);

  final String displayName;
  final IconData icon;
  final Color color;

  const ContentType(this.displayName, this.icon, this.color);
}

enum ClassType {
  school('School Class', Icons.school_rounded, Colors.blue),
  personal('Personal Class', Icons.person_rounded, Colors.green),
  group('Study Group', Icons.group_rounded, Colors.orange);

  final String displayName;
  final IconData icon;
  final Color color;

  const ClassType(this.displayName, this.icon, this.color);
}

class TeacherClass {
  final String id;
  final String teacherId;
  final String title;
  final String description;
  final String subject;
  final NigerianClass? gradeLevel;
  final ClassType type;
  final String? schoolId;
  final String? schoolName;
  final int maxStudents;
  final int currentStudents;
  final List<String> studentIds;
  final List<String> contentIds;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final String joinCode;

  TeacherClass({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.subject,
    this.gradeLevel,
    required this.type,
    this.schoolId,
    this.schoolName,
    this.maxStudents = 50,
    this.currentStudents = 0,
    this.studentIds = const [],
    this.contentIds = const [],
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.isActive = true,
    required this.joinCode,
  });

  factory TeacherClass.fromMap(Map<String, dynamic> map) {
    return TeacherClass(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] != null
          ? NigerianClass.values.firstWhere(
              (e) => e.displayName == map['gradeLevel'],
              orElse: () => NigerianClass.primary1,
            )
          : null,
      type: ClassType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'personal'),
        orElse: () => ClassType.personal,
      ),
      schoolId: map['schoolId'],
      schoolName: map['schoolName'],
      maxStudents: map['maxStudents'] ?? 50,
      currentStudents: map['currentStudents'] ?? 0,
      studentIds: List<String>.from(map['studentIds'] ?? []),
      contentIds: List<String>.from(map['contentIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      isActive: map['isActive'] ?? true,
      joinCode: map['joinCode'] ?? _generateJoinCode(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'subject': subject,
      'gradeLevel': gradeLevel?.displayName,
      'type': type.name,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'maxStudents': maxStudents,
      'currentStudents': currentStudents,
      'studentIds': studentIds,
      'contentIds': contentIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'joinCode': joinCode,
      'updatedAt': Timestamp.now(),
    };
  }

  static String _generateJoinCode() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final code = StringBuffer();

    for (var i = 0; i < 6; i++) {
      final index = (random + i) % chars.length;
      code.write(chars[index]);
    }

    return code.toString();
  }

  bool get isSchoolClass => type == ClassType.school;
  bool get isPersonalClass => type == ClassType.personal;
  bool get isStudyGroup => type == ClassType.group;
  bool get hasCapacity => currentStudents < maxStudents;
}

class ClassContent {
  final String id;
  final String classId;
  final String teacherId;
  final String title;
  final String description;
  final ContentType type;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int? points;
  final Map<String, dynamic> contentData;
  final List<String> attachments;
  final bool isPublished;
  final int viewCount;
  final int submissionCount;

  ClassContent({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.dueDate,
    this.points,
    this.contentData = const {},
    this.attachments = const [],
    this.isPublished = false,
    this.viewCount = 0,
    this.submissionCount = 0,
  });

  factory ClassContent.fromMap(Map<String, dynamic> map) {
    return ClassContent(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ContentType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'note'),
        orElse: () => ContentType.note,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      points: map['points'],
      contentData: Map<String, dynamic>.from(map['contentData'] ?? {}),
      attachments: List<String>.from(map['attachments'] ?? []),
      isPublished: map['isPublished'] ?? false,
      viewCount: map['viewCount'] ?? 0,
      submissionCount: map['submissionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'points': points,
      'contentData': contentData,
      'attachments': attachments,
      'isPublished': isPublished,
      'viewCount': viewCount,
      'submissionCount': submissionCount,
      'updatedAt': Timestamp.now(),
    };
  }

  bool get isAssignment => type == ContentType.assignment;
  bool get isTestOrExam => type == ContentType.test || type == ContentType.exam;
  bool get isPastDue => dueDate != null && dueDate!.isBefore(DateTime.now());
  bool get hasAttachments => attachments.isNotEmpty;
}

class Question {
  final String id;
  final String text;
  final String type; // 'multiple_choice', 'true_false', 'short_answer', 'essay'
  final List<String> options;
  final List<int> correctOptions;
  final String? correctAnswer;
  final int points;
  final String? explanation;
  final Map<String, dynamic> metadata;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    this.correctOptions = const [],
    this.correctAnswer,
    this.points = 1,
    this.explanation,
    this.metadata = const {},
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'multiple_choice',
      options: List<String>.from(map['options'] ?? []),
      correctOptions: List<int>.from(map['correctOptions'] ?? []),
      correctAnswer: map['correctAnswer'],
      points: map['points'] ?? 1,
      explanation: map['explanation'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'type': type,
      'options': options,
      'correctOptions': correctOptions,
      'correctAnswer': correctAnswer,
      'points': points,
      'explanation': explanation,
      'metadata': metadata,
    };
  }

  bool get hasMultipleAnswers => correctOptions.length > 1;
  bool get isMultipleChoice => type == 'multiple_choice';
  bool get isTrueFalse => type == 'true_false';
}

// ========== CONTROLLER ==========

// ========== ENHANCED BOARD CONTROLLER - COMPLETE IMPLEMENTATION ==========

class BoardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  FacultyController? _facultyController;

  // Current teacher
  final Rx<String?> currentTeacherId = Rx(null);
  final Rx<String?> currentTeacherName = Rx('Teacher');
  final Rx<String?> currentTeacherEmail = Rx(null);

  // School information
  final Rx<SchoolUserProfile?> teacherSchoolProfile = Rx(null);

  // Multi-school support
  final RxList<TeacherSchool> teacherSchools = <TeacherSchool>[].obs;
  final Rx<TeacherSchool?> selectedSchool = Rx(null);
  final RxList<SchoolUserProfile> schoolStudents = <SchoolUserProfile>[].obs;

  // Classes management
  final RxList<TeacherClass> teacherClasses = <TeacherClass>[].obs;
  final Rx<TeacherClass?> selectedClass = Rx(null);
  final RxList<TeacherClass> filteredClasses = <TeacherClass>[].obs;

  // Content management
  final RxList<ClassContent> classContents = <ClassContent>[].obs;
  final RxMap<String, List<ClassContent>> contentByClass = RxMap({});
  final Rx<ContentType?> selectedContentType = Rx(null);

  // UI State
  final RxInt selectedTab = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<ClassType?> selectedClassType = Rx(null);
  final RxList<NigerianClass> selectedGradeLevels = <NigerianClass>[].obs;

  // Form controllers
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController classDescriptionController =
      TextEditingController();
  final TextEditingController classSubjectController = TextEditingController();
  final TextEditingController classMaxStudentsController =
      TextEditingController(text: '30');

  final TextEditingController contentTitleController = TextEditingController();
  final TextEditingController contentDescriptionController =
      TextEditingController();
  final TextEditingController contentMarkdownController =
      TextEditingController();
  final TextEditingController contentPointsController = TextEditingController();
  final TextEditingController contentDurationController = TextEditingController(
    text: '60',
  );

  final TextEditingController questionTextController = TextEditingController();
  final TextEditingController questionPointsController = TextEditingController(
    text: '1',
  );

  // File handling
  final RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;
  final RxString videoUrl = RxString('');
  final Rx<VideoPlayerController?> videoPlayerController = Rx(null);
  final Rx<ChewieController?> chewieController = Rx(null);

  // Questions for tests/exams
  final RxList<Question> currentQuestions = <Question>[].obs;
  final RxList<TextEditingController> optionControllers =
      <TextEditingController>[].obs;
  final RxInt selectedCorrectOption = 0.obs;
  final RxString selectedQuestionType = RxString('multiple_choice');

  // Analytics
  final RxMap<String, dynamic> classAnalytics = RxMap({});
  final RxMap<String, dynamic> contentAnalytics = RxMap({});

  // Stream subscriptions
  StreamSubscription? _classesSubscription;
  StreamSubscription? _contentSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeTeacher();
    _setupSearchListener();

    // Initialize option controllers for multiple choice
    for (int i = 0; i < 4; i++) {
      optionControllers.add(TextEditingController());
    }

    // Try to get FacultyController
    try {
      _facultyController = Get.find<FacultyController>();
    } catch (e) {
      print('FacultyController not found: $e');
    }
  }

  @override
  void onClose() {
    _classesSubscription?.cancel();
    _contentSubscription?.cancel();
    videoPlayerController.value?.dispose();
    chewieController.value?.dispose();
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    classNameController.dispose();
    classDescriptionController.dispose();
    classSubjectController.dispose();
    classMaxStudentsController.dispose();

    contentTitleController.dispose();
    contentDescriptionController.dispose();
    contentMarkdownController.dispose();
    contentPointsController.dispose();
    contentDurationController.dispose();

    questionTextController.dispose();
    questionPointsController.dispose();

    // Dispose option controllers
    for (final controller in optionControllers) {
      controller.dispose();
    }
    optionControllers.clear();
  }

  // ========== SETUP & INITIALIZATION ==========

  Future<void> _initializeTeacher() async {
    try {
      isLoading.value = true;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        currentTeacherId.value = currentUser.uid;
        currentTeacherEmail.value = currentUser.email;

        // Get teacher name from various sources
        await _loadTeacherName(currentUser.uid);

        // Load teacher's schools with priority
        await _loadTeacherSchools(currentUser.uid);

        // If no schools found, check FacultyController
        if (teacherSchools.isEmpty && _facultyController != null) {
          await _loadSchoolFromFacultyController(currentUser.uid);
        }

        // Setup real-time listeners
        _setupRealtimeListeners(currentUser.uid);
      }
    } catch (e) {
      _showError('Failed to initialize: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTeacherName(String teacherId) async {
    try {
      // Try multiple sources for teacher name
      final userDoc = await _firestore.collection('users').doc(teacherId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        currentTeacherName.value = userData['name'] ?? 'Teacher';
        return;
      }

      // Try teacher_details collection
      final teacherDoc = await _firestore
          .collection('teacher_details')
          .doc(teacherId)
          .get();

      if (teacherDoc.exists) {
        final data = teacherDoc.data()!;
        currentTeacherName.value = data['name'] ?? 'Teacher';
        return;
      }

      // Try school_user_profiles
      final profile = await _firestore
          .collection('school_user_profiles')
          .where('userId', isEqualTo: teacherId)
          .where('userType', isEqualTo: UserType.teacher.name)
          .limit(1)
          .get();

      if (profile.docs.isNotEmpty) {
        final data = profile.docs.first.data();
        currentTeacherName.value = data['userName'] ?? 'Teacher';
      }
    } catch (e) {
      print('Error loading teacher name: $e');
    }
  }

  void _setupRealtimeListeners(String teacherId) {
    // Listen to classes
    _classesSubscription = _firestore
        .collection('teacher_classes')
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final classes = snapshot.docs
              .map((doc) => TeacherClass.fromMap(doc.data()..['id'] = doc.id))
              .toList();

          teacherClasses.value = classes;
          filteredClasses.value = classes;
          _calculateClassAnalytics();
        });

    // Listen to content updates
    _contentSubscription = _firestore
        .collection('class_contents')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final contents = snapshot.docs
              .map((doc) => ClassContent.fromMap(doc.data()..['id'] = doc.id))
              .toList();

          classContents.value = contents;
          _organizeContentByClass();
          _calculateContentAnalytics();
        });
  }

  void _setupSearchListener() {
    debounce(searchQuery, (_) {
      _filterClasses();
    }, time: const Duration(milliseconds: 300));
  }

  void _filterClasses() {
    final query = searchQuery.value.toLowerCase();

    if (query.isEmpty &&
        selectedClassType.value == null &&
        selectedGradeLevels.isEmpty) {
      filteredClasses.value = teacherClasses;
      return;
    }

    filteredClasses.value = teacherClasses.where((classItem) {
      // Search query filter
      final matchesQuery =
          query.isEmpty ||
          classItem.title.toLowerCase().contains(query) ||
          classItem.description.toLowerCase().contains(query) ||
          classItem.subject.toLowerCase().contains(query);

      // Class type filter
      final matchesType =
          selectedClassType.value == null ||
          classItem.type == selectedClassType.value;

      // Grade level filter
      final matchesGrade =
          selectedGradeLevels.isEmpty ||
          (classItem.gradeLevel != null &&
              selectedGradeLevels.contains(classItem.gradeLevel));

      return matchesQuery && matchesType && matchesGrade;
    }).toList();
  }

  Future<void> _loadTeacherSchoolProfile(String teacherId) async {
    try {
      // Try to get from FacultyController first
      if (_facultyController != null) {
        final schoolUsers = _facultyController!.schoolTeachers;
        final teacherProfile = schoolUsers.firstWhereOrNull(
          (profile) => profile.userId == teacherId,
        );

        if (teacherProfile != null) {
          teacherSchoolProfile.value = teacherProfile;
          currentTeacherName.value = teacherProfile.userName;
          return;
        }
      }

      // Fallback to Firestore
      final profile = await _firestore
          .collection('school_user_profiles')
          .where('userId', isEqualTo: teacherId)
          .where('userType', isEqualTo: 'teacher')
          .limit(1)
          .get();

      if (profile.docs.isNotEmpty) {
        final data = profile.docs.first.data();
        currentTeacherName.value = data['userName'] ?? 'Teacher';

        // Create teacher profile
        teacherSchoolProfile.value = SchoolUserProfile.fromFirestore(data);
      }
    } catch (e) {
      print('Error loading teacher school profile: $e');
    }
  }

  Future<void> _loadTeacherSchools(String teacherId) async {
    try {
      // Method 1: Check school_user_profiles collection
      final profiles = await _firestore
          .collection('school_user_profiles')
          .where('userId', isEqualTo: teacherId)
          .where('userType', isEqualTo: UserType.teacher.name)
          .where('isActive', isEqualTo: true)
          .get();

      final schools = <TeacherSchool>[];

      for (final doc in profiles.docs) {
        final data = doc.data();
        final schoolId = data['schoolId'];

        if (schoolId != null && schoolId.isNotEmpty) {
          // Try multiple sources for school data
          SchoolData? schoolData = await _getSchoolData(schoolId);

          if (schoolData != null) {
            final school = TeacherSchool(
              schoolId: schoolId,
              schoolName: schoolData.name,
              schoolCode: schoolData.code ?? '',
              position: NigerianPosition.values.firstWhere(
                (e) => e.title == (data['staffPosition'] ?? 'Subject Teacher'),
                orElse: () => NigerianPosition.subjectTeacher,
              ),
              assignedClasses: List<String>.from(data['assignedClasses'] ?? []),
              isActive: data['isActive'] ?? true,
              joinedDate: data['joinedDate'] != null
                  ? (data['joinedDate'] as Timestamp).toDate()
                  : DateTime.now(),
            );
            schools.add(school);
          }
        }
      }

      // Method 2: Check connections collection
      if (schools.isEmpty) {
        final connections = await _firestore
            .collection('connections')
            .where('userId', isEqualTo: teacherId)
            .where(
              'connectionType',
              whereIn: ['school', ConnectionType.school.name],
            )
            .where('status', isEqualTo: 'accepted')
            .get();

        for (final doc in connections.docs) {
          final data = doc.data();
          final schoolId = data['connectedUserId'];

          if (schoolId != null && schoolId.isNotEmpty) {
            final schoolData = await _getSchoolData(schoolId);

            if (schoolData != null &&
                !schools.any((s) => s.schoolId == schoolId)) {
              final school = TeacherSchool(
                schoolId: schoolId,
                schoolName: schoolData.name,
                schoolCode: schoolData.code ?? '',
                position: NigerianPosition.subjectTeacher, // Default position
                assignedClasses: [],
                isActive: true,
                joinedDate: DateTime.now(),
              );
              schools.add(school);
            }
          }
        }
      }

      teacherSchools.value = schools;

      if (schools.isNotEmpty) {
        selectedSchool.value = schools.first;
        await _loadSchoolStudents(schools.first.schoolId);
      }
    } catch (e) {
      print('Error loading teacher schools: $e');
      // Fallback to FacultyController if available
      if (_facultyController != null &&
          _facultyController!.currentSchoolId.value != null) {
        await _loadSchoolFromFacultyController(teacherId);
      }
    }
  }

  Future<SchoolData?> _getSchoolData(String schoolId) async {
    try {
      // Try school_details collection
      final schoolDoc = await _firestore
          .collection('school_details')
          .doc(schoolId)
          .get();

      if (schoolDoc.exists) {
        final data = schoolDoc.data()!;
        return SchoolData(
          id: schoolId,
          name: data['schoolName'] ?? 'Unknown School',
          code: data['schoolCode'],
        );
      }

      // Try users collection (for SchoolAdmin users)
      final userDoc = await _firestore.collection('users').doc(schoolId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final user = createUserFromMap(userData);

        if (user is SchoolAdminUser) {
          return SchoolData(
            id: schoolId,
            name: user.schoolName ?? 'Unknown School',
            code: user.schoolCode,
          );
        }
      }

      return null;
    } catch (e) {
      print('Error getting school data: $e');
      return null;
    }
  }

  Future<void> _loadSchoolFromFacultyController(String teacherId) async {
    try {
      if (_facultyController != null) {
        // Check if teacher exists in FacultyController's school
        final teacherProfile = _facultyController!.schoolTeachers
            .firstWhereOrNull((profile) => profile.userId == teacherId);

        if (teacherProfile != null && teacherProfile.schoolId != null) {
          final school = TeacherSchool(
            schoolId: teacherProfile.schoolId!,
            schoolName: teacherProfile.schoolName ?? 'Unknown School',
            schoolCode: teacherProfile.schoolCode ?? '',
            position:
                teacherProfile.staffPosition ?? NigerianPosition.subjectTeacher,
            assignedClasses: teacherProfile.assignedSubjects,
            isActive: teacherProfile.isActive,
            joinedDate: teacherProfile.joinedDate ?? DateTime.now(),
          );

          teacherSchools.value = [school];
          selectedSchool.value = school;
          await _loadSchoolStudents(school.schoolId);
        }
      }
    } catch (e) {
      print('Error loading from FacultyController: $e');
    }
  }

  Future<void> _loadSchoolStudents(String schoolId) async {
    try {
      // Method 1: Check school_user_profiles collection
      final students = await _firestore
          .collection('school_user_profiles')
          .where('schoolId', isEqualTo: schoolId)
          .where('userType', isEqualTo: UserType.student.name)
          .where('isActive', isEqualTo: true)
          .get();

      if (students.docs.isNotEmpty) {
        schoolStudents.value = students.docs
            .map((doc) => SchoolUserProfile.fromFirestore(doc.data()))
            .toList();
        return;
      }

      // Method 2: Check connections
      final teacherId = currentTeacherId.value;
      if (teacherId != null) {
        final connections = await _firestore
            .collection('connections')
            .where('userId', isEqualTo: teacherId)
            .where('status', isEqualTo: 'accepted')
            .get();

        final studentIds = connections.docs
            .where((doc) {
              final data = doc.data();
              final type = data['connectionType'] as String? ?? '';
              return type == ConnectionType.student.name ||
                  type == ConnectionType.classmate.name ||
                  type == 'student';
            })
            .map((doc) => doc.data()['connectedUserId'] as String?)
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>()
            .toSet()
            .toList();

        if (studentIds.isNotEmpty) {
          // Fetch student details
          final studentsData = await Future.wait(
            studentIds.map((id) async {
              final doc = await _firestore.collection('users').doc(id).get();
              if (doc.exists) {
                final user = createUserFromMap(doc.data()!);
                if (user is StudentUser) {
                  return SchoolUserProfile(
                    id: 'temp_$id',
                    userId: id,
                    userEmail: user.email,
                    userName: user.name,
                    userType: UserType.student,
                    schoolId: schoolId,
                    schoolName: user.schoolName,
                    studentId: user.studentId,
                    enrollmentDate: user.createdAt,
                    isActive: true,
                  );
                }
              }
              return null;
            }),
          );

          schoolStudents.value = studentsData
              .whereType<SchoolUserProfile>()
              .toList();
        }
      }
    } catch (e) {
      print('Error loading school students: $e');
      schoolStudents.value = [];
    }
  }

  // ========== CLASS CONTENT MANAGEMENT ==========

  Future<void> _loadClassContent(String classId) async {
    try {
      final content = await _firestore
          .collection('class_contents')
          .where('classId', isEqualTo: classId)
          .orderBy('createdAt', descending: true)
          .get();

      final contentList = content.docs
          .map((doc) => ClassContent.fromMap(doc.data()..['id'] = doc.id))
          .toList();

      contentByClass[classId] = contentList;

      // Update class analytics
      _calculateContentAnalytics();
    } catch (e) {
      print('Error loading class content: $e');
    }
  }

  void _organizeContentByClass() {
    final Map<String, List<ClassContent>> organized = {};

    for (final content in classContents) {
      if (!organized.containsKey(content.classId)) {
        organized[content.classId] = [];
      }
      organized[content.classId]!.add(content);
    }

    contentByClass.value = organized;
  }

  // ========== ANALYTICS CALCULATION ==========

  void _calculateClassAnalytics() {
    final analytics = {
      'totalClasses': teacherClasses.length,
      'schoolClasses': teacherClasses.where((c) => c.isSchoolClass).length,
      'personalClasses': teacherClasses.where((c) => c.isPersonalClass).length,
      'studyGroups': teacherClasses.where((c) => c.isStudyGroup).length,
      'totalStudents': teacherClasses.fold<int>(
        0,
        (sum, c) => sum + c.currentStudents,
      ),
      'totalCapacity': teacherClasses.fold<int>(
        0,
        (sum, c) => sum + c.maxStudents,
      ),
      'activeClasses': teacherClasses.where((c) => c.isActive).length,
      'classesBySubject': _groupBySubject(),
      'classesByGrade': _groupByGrade(),
    };

    classAnalytics.value = analytics;
  }

  Map<String, int> _groupBySubject() {
    final Map<String, int> subjects = {};
    for (final classItem in teacherClasses) {
      subjects[classItem.subject] = (subjects[classItem.subject] ?? 0) + 1;
    }
    return subjects;
  }

  Map<String, int> _groupByGrade() {
    final Map<String, int> grades = {};
    for (final classItem in teacherClasses) {
      if (classItem.gradeLevel != null) {
        final grade = classItem.gradeLevel!.displayName;
        grades[grade] = (grades[grade] ?? 0) + 1;
      }
    }
    return grades;
  }

  void _calculateContentAnalytics() {
    final analytics = {
      'totalContent': classContents.length,
      'notes': classContents.where((c) => c.type == ContentType.note).length,
      'materials': classContents
          .where((c) => c.type == ContentType.material)
          .length,
      'videos': classContents.where((c) => c.type == ContentType.video).length,
      'assignments': classContents
          .where((c) => c.type == ContentType.assignment)
          .length,
      'tests': classContents.where((c) => c.type == ContentType.test).length,
      'exams': classContents.where((c) => c.type == ContentType.exam).length,
      'publishedContent': classContents.where((c) => c.isPublished).length,
      'totalViews': classContents.fold<int>(0, (sum, c) => sum + c.viewCount),
      'totalSubmissions': classContents.fold<int>(
        0,
        (sum, c) => sum + c.submissionCount,
      ),
    };

    contentAnalytics.value = analytics;
  }

  // ========== CLASS MANAGEMENT ==========

  Future<void> createClass({
    required String title,
    required String description,
    required String subject,
    required ClassType type,
    NigerianClass? gradeLevel,
    String? schoolId,
    int? maxStudents,
    List<String>? studentIds,
  }) async {
    try {
      isLoading.value = true;

      final teacherId = currentTeacherId.value;
      if (teacherId == null) {
        throw Exception('Teacher not logged in');
      }

      final classId =
          'class_${DateTime.now().millisecondsSinceEpoch}_$teacherId';

      // Determine school info
      String? targetSchoolId = schoolId;
      String? targetSchoolName;

      if (type == ClassType.school) {
        if (selectedSchool.value != null) {
          targetSchoolId = selectedSchool.value!.schoolId;
          targetSchoolName = selectedSchool.value!.schoolName;
        }
      }

      final newClass = TeacherClass(
        id: classId,
        teacherId: teacherId,
        title: title,
        description: description,
        subject: subject,
        gradeLevel: gradeLevel,
        type: type,
        schoolId: targetSchoolId,
        schoolName: targetSchoolName,
        maxStudents: maxStudents ?? 50,
        studentIds: studentIds ?? [],
        createdAt: DateTime.now(),
        startDate: DateTime.now(),
        joinCode: TeacherClass._generateJoinCode(),
      );

      await _firestore
          .collection('teacher_classes')
          .doc(classId)
          .set(newClass.toMap());

      // If it's a school class, link to school
      if (type == ClassType.school && targetSchoolId != null) {
        await _linkClassToSchool(classId, targetSchoolId);
      }

      _showSuccess('Class created successfully!');

      // Clear form
      classNameController.clear();
      classDescriptionController.clear();
      classSubjectController.clear();
      classMaxStudentsController.text = '30';
    } catch (e) {
      _showError('Failed to create class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _linkClassToSchool(String classId, String schoolId) async {
    try {
      await _firestore
          .collection('school_classes')
          .doc('${schoolId}_$classId')
          .set({
            'schoolId': schoolId,
            'classId': classId,
            'teacherId': currentTeacherId.value,
            'linkedAt': Timestamp.now(),
            'status': 'active',
          });
    } catch (e) {
      print('Error linking class to school: $e');
    }
  }

  Future<void> updateClass(String classId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('teacher_classes').doc(classId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });

      _showSuccess('Class updated successfully!');
    } catch (e) {
      _showError('Failed to update class: ${e.toString()}');
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      // Archive instead of delete
      await _firestore.collection('teacher_classes').doc(classId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });

      _showSuccess('Class archived successfully!');
    } catch (e) {
      _showError('Failed to delete class: ${e.toString()}');
    }
  }

  // ========== CONTENT MANAGEMENT ==========

  Future<void> createContent({
    required String classId,
    required String title,
    required String description,
    required ContentType type,
    Map<String, dynamic>? contentData,
    List<String>? attachments,
    int? points,
    DateTime? dueDate,
  }) async {
    try {
      isLoading.value = true;

      final teacherId = currentTeacherId.value;
      if (teacherId == null) {
        throw Exception('Teacher not logged in');
      }

      final contentId =
          'content_${DateTime.now().millisecondsSinceEpoch}_$teacherId';

      // Upload attachments if any
      final uploadedAttachments = <String>[];
      if (selectedFiles.isNotEmpty) {
        for (final file in selectedFiles) {
          final url = await _uploadFile(file);
          if (url != null) uploadedAttachments.add(url);
        }
      }

      final newContent = ClassContent(
        id: contentId,
        classId: classId,
        teacherId: teacherId,
        title: title,
        description: description,
        type: type,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        points: points,
        contentData: contentData ?? {},
        attachments: attachments ?? uploadedAttachments,
        isPublished: true,
      );

      await _firestore
          .collection('class_contents')
          .doc(contentId)
          .set(newContent.toMap());

      // Update class content list
      await _firestore.collection('teacher_classes').doc(classId).update({
        'contentIds': FieldValue.arrayUnion([contentId]),
        'updatedAt': Timestamp.now(),
      });

      _showSuccess('${type.displayName} created successfully!');

      // Clear form
      contentTitleController.clear();
      contentDescriptionController.clear();
      contentMarkdownController.clear();
      contentPointsController.clear();
      contentDurationController.text = '60';
      selectedFiles.clear();
      videoUrl.value = '';
    } catch (e) {
      _showError('Failed to create content: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _uploadFile(PlatformFile file) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = _storage.ref().child('class_content/$fileName');

      final fileBytes = File(file.path!).readAsBytesSync();
      await ref.putData(fileBytes);

      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // ========== QUESTION MANAGEMENT ==========

  void addQuestion() {
    if (questionTextController.text.isEmpty) {
      _showError('Please enter question text');
      return;
    }

    final questionId = 'q_${DateTime.now().millisecondsSinceEpoch}';

    final question = Question(
      id: questionId,
      text: questionTextController.text,
      type: selectedQuestionType.value,
      options: selectedQuestionType.value == 'multiple_choice'
          ? optionControllers
                .map((c) => c.text)
                .where((t) => t.isNotEmpty)
                .toList()
          : [],
      correctOptions: selectedQuestionType.value == 'multiple_choice'
          ? [selectedCorrectOption.value]
          : [],
      correctAnswer: selectedQuestionType.value == 'short_answer'
          ? questionTextController.text
          : null,
      points: int.tryParse(questionPointsController.text) ?? 1,
    );

    currentQuestions.add(question);

    // Clear form
    clearQuestionForm();

    _showSuccess('Question added!');
  }

  void addOption() {
    optionControllers.add(TextEditingController());
  }

  void removeOption(int index) {
    if (optionControllers.length > 2) {
      final controller = optionControllers[index];
      controller.dispose();
      optionControllers.removeAt(index);

      // Adjust selected correct option if needed
      if (selectedCorrectOption.value >= index &&
          selectedCorrectOption.value > 0) {
        selectedCorrectOption.value--;
      }
    }
  }

  void clearQuestionForm() {
    questionTextController.clear();
    questionPointsController.text = '1';
    selectedQuestionType.value = 'multiple_choice';
    selectedCorrectOption.value = 0;

    // Clear option controllers
    for (final controller in optionControllers) {
      controller.clear();
    }

    // Reset to 4 options
    while (optionControllers.length > 4) {
      optionControllers.removeLast().dispose();
    }
    while (optionControllers.length < 4) {
      optionControllers.add(TextEditingController());
    }
  }

  // ========== ANALYTICS VIEWING ==========

  void viewClassAnalytics(TeacherClass classItem) {
    Get.to(() => _ClassAnalyticsPage(classItem: classItem));
  }

  void viewContentAnalytics(ClassContent content) {
    Get.to(() => _ContentAnalyticsPage(content: content));
  }

  // ========== UTILITIES ==========

  void shareClassCode(TeacherClass classItem) {
    Get.dialog(
      AlertDialog(
        title: const Text('Class Join Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this code with students to join your class:'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                classItem.joinCode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Students can join by entering this code in their app',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              // Copy to clipboard
              // Clipboard.setData(ClipboardData(text: classItem.joinCode));
              Get.back();
              _showSuccess('Code copied to clipboard!');
            },
            child: const Text('Copy Code'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedClassType.value = null;
    selectedGradeLevels.clear();
    selectedContentType.value = null;
    _filterClasses();
  }

  void refreshData() async {
    if (currentTeacherId.value != null) {
      await _loadTeacherClasses(currentTeacherId.value!);
    }
  }

  Future<void> _loadTeacherClasses(String teacherId) async {
    try {
      final classes = await _firestore
          .collection('teacher_classes')
          .where('teacherId', isEqualTo: teacherId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      teacherClasses.value = classes.docs
          .map((doc) => TeacherClass.fromMap(doc.data()..['id'] = doc.id))
          .toList();

      filteredClasses.value = teacherClasses;

      // Load content for each class
      for (final classItem in teacherClasses) {
        await _loadClassContent(classItem.id);
      }

      // Calculate analytics
      _calculateClassAnalytics();
    } catch (e) {
      print('Error loading teacher classes: $e');
    }
  }

  // ========== ASSIGNMENT MANAGEMENT ==========

  Future<void> createAssignment({
    required String classId,
    required String title,
    required String description,
    required int points,
    required DateTime dueDate,
    List<String>? attachments,
  }) async {
    final contentData = {
      'instructions': description,
      'submissionType': 'file_upload',
      'allowedFormats': ['pdf', 'doc', 'docx', 'jpg', 'png'],
      'maxFileSize': 10,
      'allowLateSubmission': false,
      'gradingRubric': {},
    };

    await createContent(
      classId: classId,
      title: title,
      description: description,
      type: ContentType.assignment,
      contentData: contentData,
      attachments: attachments,
      points: points,
      dueDate: dueDate,
    );
  }

  // ========== TEST/EXAM MANAGEMENT ==========

  Future<void> createTest({
    required String classId,
    required String title,
    required String description,
    required int duration,
    required int passingScore,
    required List<Question> questions,
    bool isExam = false,
    DateTime? dueDate,
  }) async {
    final contentData = {
      'duration': duration,
      'passingScore': passingScore,
      'questions': questions.map((q) => q.toMap()).toList(),
      'shuffleQuestions': true,
      'shuffleOptions': true,
      'showResults': true,
      'allowRetake': false,
      'timeLimit': true,
    };

    await createContent(
      classId: classId,
      title: title,
      description: description,
      type: isExam ? ContentType.exam : ContentType.test,
      contentData: contentData,
      points: questions.fold(0, (sum, q) => sum! + q.points),
      dueDate: dueDate,
    );
  }
}

// ========== ANALYTICS PAGES ==========

class _ClassAnalyticsPage extends StatefulWidget {
  final TeacherClass classItem;

  const _ClassAnalyticsPage({required this.classItem});

  @override
  State<_ClassAnalyticsPage> createState() => __ClassAnalyticsPageState();
}

class __ClassAnalyticsPageState extends State<_ClassAnalyticsPage> {
  final BoardController controller = Get.find();
  final RxMap<String, dynamic> analytics = RxMap({});
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      isLoading.value = true;

      // Get class data
      final classDoc = await FirebaseFirestore.instance
          .collection('teacher_classes')
          .doc(widget.classItem.id)
          .get();

      if (!classDoc.exists) return;

      final classData = classDoc.data()!;

      // Get student submissions
      final submissions = await FirebaseFirestore.instance
          .collection('submissions')
          .where('classId', isEqualTo: widget.classItem.id)
          .get();

      // Get grades
      final grades = await FirebaseFirestore.instance
          .collection('grades')
          .where(
            'contentId',
            whereIn: List<String>.from(classData['contentIds'] ?? []),
          )
          .get();

      // Calculate statistics
      final totalStudents = (classData['studentIds'] as List).length;
      final totalContent = (classData['contentIds'] as List).length;

      final studentPerformance = <String, Map<String, dynamic>>{};
      for (final grade in grades.docs) {
        final data = grade.data();
        final studentId = data['studentId'];
        final score = (data['score'] as num).toDouble();
        final maxScore = (data['maxScore'] as num).toDouble();

        if (!studentPerformance.containsKey(studentId)) {
          studentPerformance[studentId] = {
            'totalScore': 0.0,
            'maxScore': 0.0,
            'count': 0,
            'grades': [],
          };
        }

        final perf = studentPerformance[studentId]!;
        perf['totalScore'] = (perf['totalScore'] as double) + score;
        perf['maxScore'] = (perf['maxScore'] as double) + maxScore;
        perf['count'] = (perf['count'] as int) + 1;
        (perf['grades'] as List).add({
          'score': score,
          'maxScore': maxScore,
          'percentage': (score / maxScore) * 100,
        });
      }

      // Calculate averages
      for (final studentId in studentPerformance.keys) {
        final perf = studentPerformance[studentId]!;
        final avgScore = perf['count'] > 0
            ? (perf['totalScore'] as double) / (perf['count'] as int)
            : 0;
        final avgMaxScore = perf['count'] > 0
            ? (perf['maxScore'] as double) / (perf['count'] as int)
            : 0;
        perf['average'] = avgMaxScore > 0 ? (avgScore / avgMaxScore) * 100 : 0;
      }

      // Get student names
      final studentNames = <String, String>{};
      for (final studentId in widget.classItem.studentIds) {
        final student = controller.schoolStudents.firstWhereOrNull(
          (s) => s.userId == studentId,
        );
        if (student != null) {
          studentNames[studentId] = student.userName;
        }
      }

      analytics.value = {
        'classId': widget.classItem.id,
        'className': widget.classItem.title,
        'totalStudents': totalStudents,
        'totalContent': totalContent,
        'totalSubmissions': submissions.docs.length,
        'studentPerformance': studentPerformance,
        'studentNames': studentNames,
        'averageScore': _calculateClassAverage(studentPerformance),
        'topPerformers': _getTopPerformers(studentPerformance, studentNames),
        'needsAttention': _getStudentsNeedingAttention(
          studentPerformance,
          studentNames,
        ),
        'gradeDistribution': _calculateGradeDistribution(studentPerformance),
      };
    } catch (e) {
      print('Error loading class analytics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  double _calculateClassAverage(Map<String, Map<String, dynamic>> performance) {
    if (performance.isEmpty) return 0.0;

    double total = 0.0;
    int count = 0;

    for (final perf in performance.values) {
      final average = perf['average'] as double? ?? 0.0;
      if (!average.isNaN) {
        total += average;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }

  List<Map<String, dynamic>> _getTopPerformers(
    Map<String, Map<String, dynamic>> performance,
    Map<String, String> studentNames,
  ) {
    final List<Map<String, dynamic>> performers = [];

    for (final entry in performance.entries) {
      final average = entry.value['average'] as double? ?? 0.0;
      final name = studentNames[entry.key] ?? 'Unknown';
      performers.add({
        'studentId': entry.key,
        'name': name,
        'average': average,
      });
    }

    performers.sort(
      (a, b) => (b['average'] as double).compareTo(a['average'] as double),
    );

    return performers.take(5).toList();
  }

  List<Map<String, dynamic>> _getStudentsNeedingAttention(
    Map<String, Map<String, dynamic>> performance,
    Map<String, String> studentNames,
  ) {
    final List<Map<String, dynamic>> needsAttention = [];

    for (final entry in performance.entries) {
      final average = entry.value['average'] as double? ?? 0.0;
      if (average < 50.0) {
        final name = studentNames[entry.key] ?? 'Unknown';
        needsAttention.add({
          'studentId': entry.key,
          'name': name,
          'average': average,
          'grades': entry.value['grades'],
        });
      }
    }

    return needsAttention;
  }

  Map<String, int> _calculateGradeDistribution(
    Map<String, Map<String, dynamic>> performance,
  ) {
    final distribution = {
      'A (90-100)': 0,
      'B (80-89)': 0,
      'C (70-79)': 0,
      'D (60-69)': 0,
      'F (<60)': 0,
    };

    for (final perf in performance.values) {
      final average = perf['average'] as double? ?? 0.0;

      if (average >= 90) {
        distribution['A (90-100)'] = distribution['A (90-100)']! + 1;
      } else if (average >= 80) {
        distribution['B (80-89)'] = distribution['B (80-89)']! + 1;
      } else if (average >= 70) {
        distribution['C (70-79)'] = distribution['C (70-79)']! + 1;
      } else if (average >= 60) {
        distribution['D (60-69)'] = distribution['D (60-69)']! + 1;
      } else {
        distribution['F (<60)'] = distribution['F (<60)']! + 1;
      }
    }

    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.classItem.title} Analytics')),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Overview
              _buildClassOverview(),
              const SizedBox(height: 20),

              // Grade Distribution
              _buildGradeDistribution(),
              const SizedBox(height: 20),

              // Top Performers
              _buildTopPerformers(),
              const SizedBox(height: 20),

              // Students Needing Attention
              _buildNeedsAttention(),
              const SizedBox(height: 20),

              // Detailed Statistics
              _buildDetailedStats(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildClassOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Class Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  value: analytics['totalStudents']?.toString() ?? '0',
                  label: 'Students',
                  icon: Icons.people_rounded,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  value: analytics['totalContent']?.toString() ?? '0',
                  label: 'Content',
                  icon: Icons.library_books_rounded,
                  color: Colors.green,
                ),
                _buildStatCard(
                  value:
                      '${analytics['averageScore']?.toStringAsFixed(1) ?? '0'}%',
                  label: 'Avg Score',
                  icon: Icons.score_rounded,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  value: analytics['totalSubmissions']?.toString() ?? '0',
                  label: 'Submissions',
                  icon: Icons.assignment_turned_in_rounded,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeDistribution() {
    final distribution = Map<String, int>.from(
      analytics['gradeDistribution'] ?? {},
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(entry.key)),
                    Expanded(
                      flex: 5,
                      child: LinearProgressIndicator(
                        value: entry.value / (analytics['totalStudents'] ?? 1),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          _getGradeColor(entry.key),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 1, child: Text('${entry.value}')),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformers() {
    final performers = List<Map<String, dynamic>>.from(
      analytics['topPerformers'] ?? [],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (performers.isEmpty)
              const Text('No data available')
            else
              ...performers.asMap().entries.map((entry) {
                final index = entry.key;
                final performer = entry.value;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  title: Text(performer['name'] as String),
                  trailing: Text(
                    '${(performer['average'] as double).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedsAttention() {
    final needsAttention = List<Map<String, dynamic>>.from(
      analytics['needsAttention'] ?? [],
    );

    if (needsAttention.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Students Needing Attention',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${needsAttention.length}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...needsAttention.map((student) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(student['name'] as String),
                subtitle: Text(
                  'Avg: ${(student['average'] as double).toStringAsFixed(1)}%',
                ),
                trailing: IconButton(
                  onPressed: () {
                    // View student details
                  },
                  icon: const Icon(Icons.visibility_rounded),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    final performance = Map<String, Map<String, dynamic>>.from(
      analytics['studentPerformance'] ?? {},
    );
    final studentNames = Map<String, String>.from(
      analytics['studentNames'] ?? {},
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Student')),
                  DataColumn(label: Text('Avg Score')),
                  DataColumn(label: Text('Assignments')),
                  DataColumn(label: Text('Status')),
                ],
                rows: performance.entries.map((entry) {
                  final studentId = entry.key;
                  final perf = entry.value;
                  final name = studentNames[studentId] ?? 'Unknown';
                  final average = perf['average'] as double? ?? 0.0;
                  final count = perf['count'] as int? ?? 0;

                  return DataRow(
                    cells: [
                      DataCell(Text(name)),
                      DataCell(Text('${average.toStringAsFixed(1)}%')),
                      DataCell(Text('$count')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: average >= 70
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            average >= 70 ? 'On Track' : 'Needs Help',
                            style: TextStyle(
                              color: average >= 70 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Color _getGradeColor(String gradeRange) {
    if (gradeRange.contains('A')) return Colors.green;
    if (gradeRange.contains('B')) return Colors.blue;
    if (gradeRange.contains('C')) return Colors.orange;
    if (gradeRange.contains('D')) return Colors.amber;
    return Colors.red;
  }
}

class _ContentAnalyticsPage extends StatelessWidget {
  final ClassContent content;

  const _ContentAnalyticsPage({required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${content.title} Analytics')),
      body: const Center(child: Text('Content Analytics Page')),
    );
  }
}

// ========== BINDINGS ==========

class BoardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BoardController());
  }
}

// ========== MAIN BOARD PAGE ==========

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BoardController controller = Get.put(BoardController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    controller.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // School selector if teacher has multiple schools
          Obx(() => _buildSchoolSelector()),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(() {
        final school = controller.selectedSchool.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Board',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            if (school != null)
              Text(
                school.schoolName,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        );
      }),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.1),
      actions: [
        IconButton(
          onPressed: () => _showQuickActions(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.green, size: 20),
          ),
        ),
        IconButton(
          onPressed: () => controller.refreshData(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolSelector() {
    final schools = controller.teacherSchools;
    if (schools.length <= 1) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.school_rounded, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TeacherSchool>(
                value: controller.selectedSchool.value,
                isExpanded: true,
                items: schools.map((school) {
                  return DropdownMenuItem<TeacherSchool>(
                    value: school,
                    child: Text(
                      school.schoolName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (school) {
                  controller.selectedSchool.value = school;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.green,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.green,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Classes', icon: Icon(Icons.class_rounded, size: 20)),
          Tab(
            text: 'Content',
            icon: Icon(Icons.library_books_rounded, size: 20),
          ),
          Tab(
            text: 'Assignments',
            icon: Icon(Icons.assignment_rounded, size: 20),
          ),
          Tab(text: 'Assessments', icon: Icon(Icons.quiz_rounded, size: 20)),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildClassesTab(),
        _buildContentTab(),
        _buildAssignmentsTab(),
        _buildAssessmentsTab(),
      ],
    );
  }

  Widget _buildClassesTab() {
    return RefreshIndicator(
      onRefresh: () async => await controller.refreshData,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(child: _buildClassesHeader()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: _buildClassFilters()),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final classes = controller.filteredClasses;
                if (index >= classes.length) return null;
                final classItem = classes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ClassCard(classItem: classItem),
                );
              }, childCount: controller.filteredClasses.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Classes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            Obx(() {
              final analytics = controller.classAnalytics;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${analytics['totalClasses'] ?? 0} classes',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your school and personal classes',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        _buildQuickStats(),
      ],
    );
  }

  Widget _buildQuickStats() {
    final analytics = controller.classAnalytics;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickStatCard(
          value: analytics['schoolClasses']?.toString() ?? '0',
          label: 'School',
          icon: Icons.school_rounded,
          color: Colors.blue,
        ),
        _QuickStatCard(
          value: analytics['personalClasses']?.toString() ?? '0',
          label: 'Personal',
          icon: Icons.person_rounded,
          color: Colors.green,
        ),
        _QuickStatCard(
          value: analytics['studyGroups']?.toString() ?? '0',
          label: 'Groups',
          icon: Icons.group_rounded,
          color: Colors.orange,
        ),
        _QuickStatCard(
          value: analytics['totalStudents']?.toString() ?? '0',
          label: 'Students',
          icon: Icons.people_rounded,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildClassFilters() {
    return Column(
      children: [
        // Search Bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search classes...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Class Type Filters
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ClassType.values.map((type) {
            return Obx(() {
              final selected = controller.selectedClassType.value == type;
              return FilterChip(
                label: Text(type.displayName),
                selected: selected,
                onSelected: (_) {
                  controller.selectedClassType.value = selected ? null : type;
                },
                backgroundColor: type.color.withOpacity(0.1),
                selectedColor: type.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : type.color,
                  fontWeight: FontWeight.w500,
                ),
                avatar: Icon(
                  type.icon,
                  size: 16,
                  color: selected ? Colors.white : type.color,
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContentTab() {
    return Obx(() {
      final classes = controller.teacherClasses;
      final selectedClass = controller.selectedClass.value;

      return Column(
        children: [
          // Class Selector
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TeacherClass>(
                  value: selectedClass,
                  isExpanded: true,
                  hint: const Text('Select a class'),
                  items: classes.map((classItem) {
                    return DropdownMenuItem<TeacherClass>(
                      value: classItem,
                      child: Text(classItem.title),
                    );
                  }).toList(),
                  onChanged: (classItem) {
                    controller.selectedClass.value = classItem;
                  },
                ),
              ),
            ),
          ),

          // Content Type Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ContentType.values.map((type) {
                  return Obx(() {
                    final selected =
                        controller.selectedContentType.value == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type.displayName),
                        selected: selected,
                        onSelected: (_) {
                          controller.selectedContentType.value = selected
                              ? null
                              : type;
                        },
                        backgroundColor: type.color.withOpacity(0.1),
                        selectedColor: type.color,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : type.color,
                        ),
                        avatar: Icon(
                          type.icon,
                          size: 16,
                          color: selected ? Colors.white : type.color,
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
          ),

          // Content List
          if (selectedClass != null) ...[
            const SizedBox(height: 20),
            Expanded(child: _buildContentList(selectedClass.id)),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.library_books_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a class',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a class to view its content',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildContentList(String classId) {
    final contents = controller.contentByClass[classId] ?? [];
    final filteredContents = contents.where((content) {
      final typeFilter =
          controller.selectedContentType.value == null ||
          content.type == controller.selectedContentType.value;
      return typeFilter;
    }).toList();

    if (filteredContents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No content yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add notes, materials, or assignments',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateContentDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Content'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredContents.length,
      itemBuilder: (context, index) {
        final content = filteredContents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ContentCard(content: content),
        );
      },
    );
  }

  Widget _buildAssignmentsTab() {
    return Obx(() {
      final classes = controller.teacherClasses;
      final selectedClass = controller.selectedClass.value;
      final currentTime = DateTime.now();

      return Column(
        children: [
          // Class Selector
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TeacherClass>(
                  value: selectedClass,
                  isExpanded: true,
                  hint: const Text('Select a class'),
                  items: classes.map((classItem) {
                    return DropdownMenuItem<TeacherClass>(
                      value: classItem,
                      child: Text(classItem.title),
                    );
                  }).toList(),
                  onChanged: (classItem) {
                    controller.selectedClass.value = classItem;
                  },
                ),
              ),
            ),
          ),

          // Assignment Status Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: controller.selectedContentType.value == null,
                    onSelected: (_) {
                      controller.selectedContentType.value = null;
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Active'),
                    selected:
                        controller.selectedContentType.value ==
                        ContentType.assignment,
                    onSelected: (_) {
                      controller.selectedContentType.value =
                          ContentType.assignment;
                    },
                    backgroundColor: Colors.green.withOpacity(0.1),
                    selectedColor: Colors.green,
                    labelStyle: const TextStyle(color: Colors.green),
                    avatar: const Icon(Icons.access_time_rounded, size: 16),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Past Due'),
                    selected: false,
                    onSelected: (_) {},
                    backgroundColor: Colors.red.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.red),
                    avatar: const Icon(Icons.warning_rounded, size: 16),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Graded'),
                    selected: false,
                    onSelected: (_) {},
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green),
                    avatar: const Icon(Icons.grade_rounded, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // Assignment List
          if (selectedClass != null) ...[
            const SizedBox(height: 20),
            Expanded(child: _buildAssignmentList(selectedClass.id)),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a class',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a class to view assignments',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildAssignmentList(String classId) {
    final contents = controller.contentByClass[classId] ?? [];
    final assignments = contents
        .where((content) => content.type == ContentType.assignment)
        .toList();

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No assignments yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create assignments for your students',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateAssignmentDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Assignment'),
            ),
          ],
        ),
      );
    }

    // Separate assignments into active, upcoming, and past due
    final currentTime = DateTime.now();
    final activeAssignments = assignments
        .where(
          (a) =>
              a.isPublished &&
              (a.dueDate == null || a.dueDate!.isAfter(currentTime)),
        )
        .toList();

    final pastDueAssignments = assignments
        .where(
          (a) =>
              a.isPublished &&
              a.dueDate != null &&
              a.dueDate!.isBefore(currentTime),
        )
        .toList();

    final draftAssignments = assignments.where((a) => !a.isPublished).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (activeAssignments.isNotEmpty) ...[
          _buildAssignmentSection(
            title: 'Active Assignments',
            assignments: activeAssignments,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
        ],

        if (pastDueAssignments.isNotEmpty) ...[
          _buildAssignmentSection(
            title: 'Past Due',
            assignments: pastDueAssignments,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
        ],

        if (draftAssignments.isNotEmpty) ...[
          _buildAssignmentSection(
            title: 'Drafts',
            assignments: draftAssignments,
            color: Colors.grey,
          ),
        ],
      ],
    );
  }

  Widget _buildAssignmentSection({
    required String title,
    required List<ClassContent> assignments,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${assignments.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...assignments.map((assignment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AssignmentCard(assignment: assignment),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAssessmentsTab() {
    return Obx(() {
      final classes = controller.teacherClasses;
      final selectedClass = controller.selectedClass.value;

      return Column(
        children: [
          // Class Selector
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TeacherClass>(
                  value: selectedClass,
                  isExpanded: true,
                  hint: const Text('Select a class'),
                  items: classes.map((classItem) {
                    return DropdownMenuItem<TeacherClass>(
                      value: classItem,
                      child: Text(classItem.title),
                    );
                  }).toList(),
                  onChanged: (classItem) {
                    controller.selectedClass.value = classItem;
                  },
                ),
              ),
            ),
          ),

          // Assessment Type Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: controller.selectedContentType.value == null,
                    onSelected: (_) {
                      controller.selectedContentType.value = null;
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Tests'),
                    selected:
                        controller.selectedContentType.value ==
                        ContentType.test,
                    onSelected: (_) {
                      controller.selectedContentType.value = ContentType.test;
                    },
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    selectedColor: Colors.purple,
                    labelStyle: const TextStyle(color: Colors.purple),
                    avatar: const Icon(Icons.quiz_rounded, size: 16),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Exams'),
                    selected:
                        controller.selectedContentType.value ==
                        ContentType.exam,
                    onSelected: (_) {
                      controller.selectedContentType.value = ContentType.exam;
                    },
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    selectedColor: Colors.deepPurple,
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                    avatar: const Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Active'),
                    selected: false,
                    onSelected: (_) {},
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green),
                    avatar: const Icon(Icons.access_time_rounded, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // Assessment List
          if (selectedClass != null) ...[
            const SizedBox(height: 20),
            Expanded(child: _buildAssessmentList(selectedClass.id)),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.quiz_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a class',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a class to view assessments',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildAssessmentList(String classId) {
    final contents = controller.contentByClass[classId] ?? [];
    final assessments = contents
        .where(
          (content) =>
              content.type == ContentType.test ||
              content.type == ContentType.exam,
        )
        .toList();

    if (assessments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No assessments yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create tests and exams for your students',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateAssessmentDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Assessment'),
            ),
          ],
        ),
      );
    }

    final currentTime = DateTime.now();

    // Filter based on selected content type
    List<ClassContent> filteredAssessments = assessments;
    if (controller.selectedContentType.value == ContentType.test) {
      filteredAssessments = assessments
          .where((a) => a.type == ContentType.test)
          .toList();
    } else if (controller.selectedContentType.value == ContentType.exam) {
      filteredAssessments = assessments
          .where((a) => a.type == ContentType.exam)
          .toList();
    }

    // Separate into upcoming, active, and completed
    final upcomingAssessments = filteredAssessments
        .where((a) => a.dueDate != null && a.dueDate!.isAfter(currentTime))
        .toList();

    final activeAssessments = filteredAssessments
        .where(
          (a) =>
              a.isPublished &&
              (a.dueDate == null || !a.dueDate!.isBefore(currentTime)),
        )
        .toList();

    final completedAssessments = filteredAssessments
        .where((a) => a.dueDate != null && a.dueDate!.isBefore(currentTime))
        .toList();

    final draftAssessments = filteredAssessments
        .where((a) => !a.isPublished)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (activeAssessments.isNotEmpty) ...[
          _buildAssessmentSection(
            title: 'Active Assessments',
            assessments: activeAssessments,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
        ],

        if (upcomingAssessments.isNotEmpty) ...[
          _buildAssessmentSection(
            title: 'Upcoming',
            assessments: upcomingAssessments,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
        ],

        if (completedAssessments.isNotEmpty) ...[
          _buildAssessmentSection(
            title: 'Completed',
            assessments: completedAssessments,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
        ],

        if (draftAssessments.isNotEmpty) ...[
          _buildAssessmentSection(
            title: 'Drafts',
            assessments: draftAssessments,
            color: Colors.grey,
          ),
        ],
      ],
    );
  }

  Widget _buildAssessmentSection({
    required String title,
    required List<ClassContent> assessments,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${assessments.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...assessments.map((assessment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AssessmentCard(assessment: assessment),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      final selectedTab = controller.selectedTab.value;

      IconData icon;
      VoidCallback onPressed;

      switch (selectedTab) {
        case 0: // Classes
          icon = Icons.add_rounded;
          onPressed = () => _showCreateClassDialog();
          break;
        case 1: // Content
          icon = Icons.add_rounded;
          onPressed = () => _showCreateContentDialog();
          break;
        case 2: // Assignments
          icon = Icons.home_mini_sharp;
          onPressed = () => _showCreateAssignmentDialog();
          break;
        case 3: // Assessments
          icon = Icons.quiz_outlined;
          onPressed = () => _showCreateAssessmentDialog();
          break;
        default:
          icon = Icons.add_rounded;
          onPressed = () {};
      }

      return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 4,
        child: Icon(icon),
      );
    });
  }

  void _showQuickActions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickActionCard(
                    icon: Icons.class_rounded,
                    label: 'New Class',
                    color: Colors.green,
                    onTap: () {
                      Get.back();
                      _showCreateClassDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.note_add_rounded,
                    label: 'New Note',
                    color: Colors.green,
                    onTap: () {
                      Get.back();
                      _showCreateNoteDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.home_mini_sharp,
                    label: 'Assignment',
                    color: Colors.orange,
                    onTap: () {
                      Get.back();
                      _showCreateAssignmentDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.quiz_outlined,
                    label: 'Test',
                    color: Colors.purple,
                    onTap: () {
                      Get.back();
                      _showCreateTestDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.video_library_rounded,
                    label: 'Video',
                    color: Colors.red,
                    onTap: () {
                      Get.back();
                      _showUploadVideoDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.file_upload_rounded,
                    label: 'Material',
                    color: Colors.teal,
                    onTap: () {
                      Get.back();
                      _showUploadMaterialDialog();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showCreateClassDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _CreateClassForm(),
        ),
      ),
    );
  }

  void _showCreateContentDialog() {
    // Similar implementation for content creation
  }

  void _showCreateNoteDialog() {
    // Implementation for note creation
  }

  void _showCreateAssignmentDialog() {
    // Implementation for assignment creation
  }

  void _showCreateTestDialog() {
    // Implementation for test creation
  }

  void _showUploadVideoDialog() {
    // Implementation for video upload
  }

  void _showUploadMaterialDialog() {
    // Implementation for material upload
  }

  void _showCreateAssessmentDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Assessment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _AssessmentTypeCard(
                type: ContentType.test,
                title: 'Test',
                subtitle:
                    'Create a test with multiple choice, true/false, and short answer questions',
                onTap: () {
                  Get.back();
                  _showCreateTestForm();
                },
              ),
              const SizedBox(height: 12),
              _AssessmentTypeCard(
                type: ContentType.exam,
                title: 'Exam',
                subtitle:
                    'Create a comprehensive exam with multiple sections and advanced settings',
                onTap: () {
                  Get.back();
                  _showCreateExamForm();
                },
              ),
              const SizedBox(height: 20),
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

  void _showCreateTestForm() {
    Get.to(() => CreateTestPage());
  }

  void _showCreateExamForm() {
    Get.to(() => CreateExamPage());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ========== WIDGET COMPONENTS ==========

class _QuickStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _QuickStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final TeacherClass classItem;

  const _ClassCard({required this.classItem});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();

    return GestureDetector(
      onTap: () {
        controller.selectedClass.value = classItem;
        controller.selectedTab.value = 1; // Switch to content tab
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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
                  color: classItem.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  classItem.type.icon,
                  color: classItem.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classItem.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classItem.subject,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${classItem.currentStudents}/${classItem.maxStudents} students',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: classItem.type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            classItem.type.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: classItem.type.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'analytics',
                    child: Text('View Analytics'),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('Share Class'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Edit Class')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Archive Class'),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'analytics':
                      controller.viewClassAnalytics(classItem);
                      break;
                    case 'share':
                      controller.shareClassCode(classItem);
                      break;
                    case 'edit':
                      // Show edit dialog
                      break;
                    case 'delete':
                      controller.deleteClass(classItem.id);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final ClassContent content;

  const _ContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();

    return GestureDetector(
      onTap: () => _viewContentDetails(content),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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
                  color: content.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  content.type.icon,
                  color: content.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${content.viewCount} views',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (content.points != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.score_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${content.points} points',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                        if (content.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: content.isPastDue
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd').format(content.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: content.isPastDue
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'analytics',
                    child: Text('View Analytics'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'publish',
                    child: Text(content.isPublished ? 'Unpublish' : 'Publish'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'analytics':
                      controller.viewContentAnalytics(content);
                      break;
                    case 'edit':
                      // Show edit dialog
                      break;
                    case 'publish':
                      // Toggle publish status
                      break;
                    case 'delete':
                      // Delete content
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewContentDetails(ClassContent content) {
    switch (content.type) {
      case ContentType.note:
        Get.to(() => NoteViewPage(content: content));
        break;
      case ContentType.material:
        Get.to(() => MaterialViewPage(content: content));
        break;
      case ContentType.video:
        Get.to(() => VideoViewPage(content: content));
        break;
      case ContentType.assignment:
        Get.to(() => AssignmentViewPage(content: content));
        break;
      case ContentType.test:
      case ContentType.exam:
        Get.to(() => AssessmentViewPage(content: content));
        break;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (Get.width - 64) / 3,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentTypeCard extends StatelessWidget {
  final ContentType type;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AssessmentTypeCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: type.color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: type.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== CREATE CLASS FORM ==========

class _CreateClassForm extends StatefulWidget {
  const _CreateClassForm();

  @override
  State<_CreateClassForm> createState() => __CreateClassFormState();
}

class __CreateClassFormState extends State<_CreateClassForm> {
  final BoardController controller = Get.find<BoardController>();
  final _formKey = GlobalKey<FormState>();

  final Rx<ClassType> selectedClassType = Rx(ClassType.personal);
  final Rx<String?> selectedSchoolId = Rx(null);
  final Rx<NigerianClass?> selectedGradeLevel = Rx(null);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Class',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Class Type Selection
            _buildClassTypeSelection(),
            const SizedBox(height: 20),

            // School Selection (if school class)
            Obx(() {
              if (selectedClassType.value == ClassType.school) {
                return _buildSchoolSelection();
              }
              return const SizedBox();
            }),
            const SizedBox(height: 20),

            // Class Details
            TextFormField(
              controller: controller.classNameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter class name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: controller.classDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.classSubjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subject';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Obx(() => _buildGradeLevelSelection())),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: controller.classMaxStudentsController,
              decoration: const InputDecoration(
                labelText: 'Max Students',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter maximum students';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : _createClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Class'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class Type', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: ClassType.values.map((type) {
            return Expanded(
              child: Obx(() {
                final selected = selectedClassType.value == type;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(type.displayName),
                    selected: selected,
                    onSelected: (_) => selectedClassType.value = type,
                    backgroundColor: type.color.withOpacity(0.1),
                    selectedColor: type.color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : type.color,
                      fontWeight: FontWeight.w500,
                    ),
                    avatar: selected
                        ? Icon(type.icon, size: 16, color: Colors.white)
                        : Icon(type.icon, size: 16, color: type.color),
                  ),
                );
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSchoolSelection() {
    final schools = controller.teacherSchools;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select School',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSchoolId.value,
                isExpanded: true,
                hint: const Text('Choose a school'),
                items: schools.map((school) {
                  return DropdownMenuItem<String>(
                    value: school.schoolId,
                    child: Text(school.schoolName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedSchoolId.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeLevelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grade Level',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<NigerianClass>(
                value: selectedGradeLevel.value,
                isExpanded: true,
                hint: const Text('Optional'),
                items: NigerianClass.values.map((grade) {
                  return DropdownMenuItem<NigerianClass>(
                    value: grade,
                    child: Text(grade.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedGradeLevel.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createClass() async {
    if (_formKey.currentState!.validate()) {
      await controller.createClass(
        title: controller.classNameController.text,
        description: controller.classDescriptionController.text,
        subject: controller.classSubjectController.text,
        type: selectedClassType.value,
        gradeLevel: selectedGradeLevel.value,
        schoolId: selectedClassType.value == ClassType.school
            ? selectedSchoolId.value
            : null,
        maxStudents: int.parse(controller.classMaxStudentsController.text),
      );

      if (Get.isDialogOpen!) Get.back();
    }
  }
}

// ========== CREATE TEST PAGE ==========

class CreateTestPage extends StatefulWidget {
  const CreateTestPage({super.key});

  @override
  State<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  final BoardController controller = Get.find<BoardController>();
  final _formKey = GlobalKey<FormState>();

  final Rx<DateTime?> selectedDueDate = Rx(null);
  final RxInt passingScore = RxInt(50);
  final RxBool shuffleQuestions = RxBool(true);
  final RxBool shuffleOptions = RxBool(true);
  final RxBool showResults = RxBool(true);
  final RxBool allowRetake = RxBool(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test'),
        actions: [
          IconButton(
            onPressed: _createTest,
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
              // Class Selection
              _buildClassSelector(),
              const SizedBox(height: 20),

              // Test Details
              TextFormField(
                controller: controller.contentTitleController,
                decoration: const InputDecoration(
                  labelText: 'Test Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter test title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controller.contentDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.contentDurationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Please enter valid duration';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDueDate,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Obx(
                                () => Text(
                                  selectedDueDate.value == null
                                      ? 'Due Date (Optional)'
                                      : DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(selectedDueDate.value!),
                                  style: TextStyle(
                                    color: selectedDueDate.value == null
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Test Settings
              _buildTestSettings(),
              const SizedBox(height: 30),

              // Questions Section
              _buildQuestionsSection(),
              const SizedBox(height: 30),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _createTest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Test'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassSelector() {
    final classes = controller.teacherClasses;
    final selectedClass = controller.selectedClass.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Class',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TeacherClass>(
                value: selectedClass,
                isExpanded: true,
                hint: const Text('Choose a class'),
                items: classes.map((classItem) {
                  return DropdownMenuItem<TeacherClass>(
                    value: classItem,
                    child: Text(classItem.title),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedClass.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildSettingSwitch(
          title: 'Shuffle Questions',
          subtitle: 'Questions will appear in random order',
          value: shuffleQuestions.value,
          onChanged: (value) => shuffleQuestions.value = value!,
        ),
        _buildSettingSwitch(
          title: 'Shuffle Options',
          subtitle: 'Multiple choice options will be shuffled',
          value: shuffleOptions.value,
          onChanged: (value) => shuffleOptions.value = value!,
        ),
        _buildSettingSwitch(
          title: 'Show Results',
          subtitle: 'Students can see their score after submission',
          value: showResults.value,
          onChanged: (value) => showResults.value = value!,
        ),
        _buildSettingSwitch(
          title: 'Allow Retake',
          subtitle: 'Students can retake the test',
          value: allowRetake.value,
          onChanged: (value) => allowRetake.value = value!,
        ),
      ],
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Question'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Obx(() {
          final questions = controller.currentQuestions;

          if (questions.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No questions added yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add questions to create your test',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _QuestionCard(
                question: question,
                index: index,
                onEdit: () => _editQuestion(index),
                onDelete: () => _deleteQuestion(index),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      selectedDueDate.value = selected;
    }
  }

  void _addQuestion() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _AddQuestionForm(),
        ),
      ),
    );
  }

  void _editQuestion(int index) {
    final question = controller.currentQuestions[index];
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _EditQuestionForm(question: question, index: index),
        ),
      ),
    );
  }

  void _deleteQuestion(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.currentQuestions.removeAt(index);
              Get.back();
              Get.snackbar(
                'Deleted',
                'Question removed',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _createTest() async {
    if (_formKey.currentState!.validate()) {
      final selectedClass = controller.selectedClass.value;
      if (selectedClass == null) {
        Get.snackbar('Error', 'Please select a class');
        return;
      }

      if (controller.currentQuestions.isEmpty) {
        Get.snackbar('Error', 'Please add at least one question');
        return;
      }

      final totalPoints = controller.currentQuestions.fold(
        0,
        (sum, q) => sum + q.points,
      );

      await controller.createTest(
        classId: selectedClass.id,
        title: controller.contentTitleController.text,
        description: controller.contentDescriptionController.text,
        duration: int.parse(controller.contentDurationController.text),
        passingScore: (totalPoints * (passingScore.value / 100)).toInt(),
        questions: controller.currentQuestions.toList(),
        isExam: false,
      );

      // Clear form
      controller.contentTitleController.clear();
      controller.contentDescriptionController.clear();
      controller.contentDurationController.text = '60';
      controller.currentQuestions.clear();

      Get.back();
    }
  }
}

// ========== CREATE EXAM PAGE ==========

class CreateExamPage extends StatelessWidget {
  const CreateExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Similar to CreateTestPage but with additional exam-specific features
    return Scaffold(
      appBar: AppBar(title: const Text('Create Exam')),
      body: const Center(child: Text('Exam Creation Page')),
    );
  }
}

// ========== QUESTION CARDS & FORMS ==========

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      color: Colors.grey,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(
                      question.type,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getQuestionTypeLabel(question.type),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getQuestionTypeColor(question.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${question.points} points',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (question.options.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${question.options.length} options',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.blue;
      case 'true_false':
        return Colors.green;
      case 'short_answer':
        return Colors.orange;
      case 'essay':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'true_false':
        return 'True/False';
      case 'short_answer':
        return 'Short Answer';
      case 'essay':
        return 'Essay';
      default:
        return 'Question';
    }
  }
}

class _AddQuestionForm extends StatefulWidget {
  const _AddQuestionForm();

  @override
  State<_AddQuestionForm> createState() => __AddQuestionFormState();
}

class __AddQuestionFormState extends State<_AddQuestionForm> {
  final BoardController controller = Get.find<BoardController>();
  final RxString questionType = RxString('multiple_choice');

  @override
  void initState() {
    super.initState();
    // Initialize with 4 option controllers for multiple choice
    for (int i = 0; i < 4; i++) {
      controller.optionControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Question',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Question Type
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Question Type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _QuestionTypeChip(
                    type: 'multiple_choice',
                    label: 'Multiple Choice',
                    selected: questionType.value == 'multiple_choice',
                    onSelected: (_) => questionType.value = 'multiple_choice',
                  ),
                  _QuestionTypeChip(
                    type: 'true_false',
                    label: 'True/False',
                    selected: questionType.value == 'true_false',
                    onSelected: (_) => questionType.value = 'true_false',
                  ),
                  _QuestionTypeChip(
                    type: 'short_answer',
                    label: 'Short Answer',
                    selected: questionType.value == 'short_answer',
                    onSelected: (_) => questionType.value = 'short_answer',
                  ),
                  _QuestionTypeChip(
                    type: 'essay',
                    label: 'Essay',
                    selected: questionType.value == 'essay',
                    onSelected: (_) => questionType.value = 'essay',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Text
          TextField(
            controller: controller.questionTextController,
            decoration: const InputDecoration(
              labelText: 'Question Text',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Options (for multiple choice)
          Obx(() {
            if (questionType.value == 'multiple_choice') {
              return _buildMultipleChoiceOptions();
            } else if (questionType.value == 'true_false') {
              return _buildTrueFalseOptions();
            } else {
              return _buildTextAnswerField();
            }
          }),
          const SizedBox(height: 20),

          // Points
          TextField(
            controller: controller.questionPointsController,
            decoration: const InputDecoration(
              labelText: 'Points',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Question'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== FIXED _buildMultipleChoiceOptions METHOD ==========

  Widget _buildMultipleChoiceOptions() {
    final controller = Get.find<BoardController>(); // Get the BoardController

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Options (Select the correct one)'),
        const SizedBox(height: 12),

        ...controller.optionControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final optionController = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Obx(
                  () => Radio(
                    value: index,
                    groupValue: controller.selectedCorrectOption.value,
                    onChanged: (value) {
                      controller.selectedCorrectOption.value = value!;
                    },
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:
                        optionController, // Use optionController, not controller
                    decoration: InputDecoration(
                      hintText: 'Option ${String.fromCharCode(65 + index)}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                if (controller.optionControllers.length > 2)
                  IconButton(
                    onPressed: () => controller.removeOption(index),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: Colors.red,
                  ),
              ],
            ),
          );
        }).toList(),

        TextButton.icon(
          onPressed: () => controller.addOption(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Option'),
        ),
      ],
    );
  }

  Widget _buildTrueFalseOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select correct answer'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => RadioListTile(
                  title: const Text('True'),
                  value: 0,
                  groupValue: controller.selectedCorrectOption.value,
                  onChanged: (value) {
                    controller.selectedCorrectOption.value = value!;
                  },
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => RadioListTile(
                  title: const Text('False'),
                  value: 1,
                  groupValue: controller.selectedCorrectOption.value,
                  onChanged: (value) {
                    controller.selectedCorrectOption.value = value!;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextAnswerField() {
    return TextField(
      controller: controller.contentDescriptionController,
      decoration: const InputDecoration(
        labelText: 'Model Answer (for reference)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  void _saveQuestion() {
    if (controller.questionTextController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter question text');
      return;
    }

    if (questionType.value == 'multiple_choice' &&
        controller.optionControllers.any((c) => c.text.isEmpty)) {
      Get.snackbar('Error', 'Please fill all options');
      return;
    }

    controller.addQuestion();
    Get.back();
  }
}

class _EditQuestionForm extends StatefulWidget {
  final Question question;
  final int index;

  const _EditQuestionForm({required this.question, required this.index});

  @override
  State<_EditQuestionForm> createState() => __EditQuestionFormState();
}

class __EditQuestionFormState extends State<_EditQuestionForm> {
  final BoardController controller = Get.find<BoardController>();

  @override
  void initState() {
    super.initState();
    // Initialize form with existing question data
    controller.questionTextController.text = widget.question.text;
    controller.questionPointsController.text = widget.question.points
        .toString();
    controller.selectedQuestionType.value = widget.question.type;

    if (widget.question.type == 'multiple_choice') {
      for (final option in widget.question.options) {
        controller.optionControllers.add(TextEditingController(text: option));
      }
      if (widget.question.correctOptions.isNotEmpty) {
        controller.selectedCorrectOption.value =
            widget.question.correctOptions.first;
      }
    } else if (widget.question.type == 'true_false') {
      controller.selectedCorrectOption.value =
          widget.question.correctAnswer == 'true' ? 0 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AddQuestionForm();
  }

  void _updateQuestion() {
    // Similar to _saveQuestion but updates existing question
    final updatedQuestion = Question(
      id: widget.question.id,
      text: controller.questionTextController.text,
      type: controller.selectedQuestionType.value,
      options: controller.optionControllers
          .map((c) => c.text)
          .where((t) => t.isNotEmpty)
          .toList(),
      correctOptions: controller.selectedQuestionType.value == 'multiple_choice'
          ? [controller.selectedCorrectOption.value]
          : [],
      correctAnswer: controller.selectedQuestionType.value == 'true_false'
          ? (controller.selectedCorrectOption.value == 0 ? 'true' : 'false')
          : null,
      points: int.tryParse(controller.questionPointsController.text) ?? 1,
    );

    controller.currentQuestions[widget.index] = updatedQuestion;
    Get.back();
    Get.snackbar('Updated', 'Question updated successfully');
  }
}

class _QuestionTypeChip extends StatelessWidget {
  final String type;
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _QuestionTypeChip({
    required this.type,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getQuestionTypeColor(type);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      labelStyle: TextStyle(
        color: selected ? Colors.white : color,
        fontWeight: FontWeight.w500,
      ),
      avatar: selected
          ? Icon(_getQuestionTypeIcon(type), size: 16, color: Colors.white)
          : Icon(_getQuestionTypeIcon(type), size: 16, color: color),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.blue;
      case 'true_false':
        return Colors.green;
      case 'short_answer':
        return Colors.orange;
      case 'essay':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.checklist_rounded;
      case 'true_false':
        return Icons.swap_horiz_rounded;
      case 'short_answer':
        return Icons.short_text_rounded;
      case 'essay':
        return Icons.subject_rounded;
      default:
        return Icons.question_mark_rounded;
    }
  }
}

// ========== CONTENT VIEW PAGES ==========

class NoteViewPage extends StatelessWidget {
  final ClassContent content;

  const NoteViewPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              content.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (content.contentData.containsKey('markdown'))
              MarkdownBody(data: content.contentData['markdown'] ?? '')
            else
              Text(
                content.contentData['text'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class MaterialViewPage extends StatelessWidget {
  final ClassContent content;

  const MaterialViewPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            content.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content.description,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Download buttons for attachments
          if (content.attachments.isNotEmpty) ...[
            const Text(
              'Attachments:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...content.attachments.map((url) {
              return ListTile(
                leading: const Icon(Icons.attach_file_rounded),
                title: Text(_getFileNameFromUrl(url)),
                trailing: IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () => _downloadFile(url),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path.split('/').last;
    } catch (e) {
      return 'File';
    }
  }

  void _downloadFile(String url) async {
    // Implementation for file download
    // You can use url_launcher or downloader package
    Get.snackbar('Download', 'Starting download...');
  }
}

class VideoViewPage extends StatelessWidget {
  final ClassContent content;

  const VideoViewPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Video Player - ${content.title}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssignmentViewPage extends StatelessWidget {
  final ClassContent content;

  const AssignmentViewPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            content.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content.description,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Assignment details
          _buildDetailItem(
            icon: Icons.score_rounded,
            label: 'Points',
            value: '${content.points ?? 0}',
          ),
          if (content.dueDate != null)
            _buildDetailItem(
              icon: Icons.calendar_today_rounded,
              label: 'Due Date',
              value: DateFormat(
                'MMM dd, yyyy - HH:mm',
              ).format(content.dueDate!),
            ),
          _buildDetailItem(
            icon: Icons.visibility_rounded,
            label: 'Submissions',
            value: '${content.submissionCount}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class AssessmentViewPage extends StatelessWidget {
  final ClassContent content;

  const AssessmentViewPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            content.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content.description,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Assessment details
          _buildDetailItem(
            icon: Icons.timer_rounded,
            label: 'Duration',
            value: '${content.contentData['duration']} minutes',
          ),
          _buildDetailItem(
            icon: Icons.score_rounded,
            label: 'Total Points',
            value: '${content.points ?? 0}',
          ),
          _buildDetailItem(
            icon: Icons.quiz_rounded,
            label: 'Questions',
            value:
                '${(content.contentData['questions'] as List?)?.length ?? 0}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ========== ANALYTICS PAGES ==========

class ClassAnalyticsPage extends StatelessWidget {
  final TeacherClass classItem;

  const ClassAnalyticsPage({super.key, required this.classItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${classItem.title} Analytics')),
      body: const Center(child: Text('Class Analytics Page')),
    );
  }
}

class ContentAnalyticsPage extends StatelessWidget {
  final ClassContent content;

  const ContentAnalyticsPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${content.title} Analytics')),
      body: const Center(child: Text('Content Analytics Page')),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final ClassContent assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();
    final isPastDue = assignment.isPastDue;
    final hasSubmissions = assignment.submissionCount > 0;

    return GestureDetector(
      onTap: () => Get.to(() => AssignmentViewPage(content: assignment)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPastDue ? Colors.red.shade200 : Colors.grey.shade200,
          ),
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
                  color: isPastDue
                      ? Colors.red.withOpacity(0.1)
                      : assignment.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPastDue ? Icons.warning_rounded : assignment.type.icon,
                  color: isPastDue ? Colors.red : assignment.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${assignment.submissionCount} submissions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.score_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${assignment.points ?? 0} points',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (assignment.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: isPastDue ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd').format(assignment.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isPastDue ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isPastDue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Past Due',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else if (!assignment.isPublished)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Draft',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (hasSubmissions)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${assignment.submissionCount} to grade',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
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
}

class _AssessmentCard extends StatelessWidget {
  final ClassContent assessment;

  const _AssessmentCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();
    final isPastDue = assessment.isPastDue;
    final isExam = assessment.type == ContentType.exam;
    final duration = assessment.contentData['duration'] ?? 0;
    final questions =
        (assessment.contentData['questions'] as List?)?.length ?? 0;
    final passingScore = assessment.contentData['passingScore'] ?? 0;

    return GestureDetector(
      onTap: () => Get.to(() => AssessmentViewPage(content: assessment)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPastDue ? Colors.red.shade200 : Colors.grey.shade200,
          ),
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
                  color: isPastDue
                      ? Colors.red.withOpacity(0.1)
                      : assessment.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPastDue ? Icons.warning_rounded : assessment.type.icon,
                  color: isPastDue ? Colors.red : assessment.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          assessment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: assessment.type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isExam ? 'Exam' : 'Test',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: assessment.type.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assessment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.quiz_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$questions questions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.timer_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$duration min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.score_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${assessment.points ?? 0} points',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (assessment.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: isPastDue ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd').format(assessment.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isPastDue ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isPastDue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Past Due',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else if (!assessment.isPublished)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Draft',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (assessment.submissionCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${assessment.submissionCount} taken',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
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
}
