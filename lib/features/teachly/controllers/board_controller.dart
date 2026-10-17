import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/screens/faculty.dart';
import 'package:isapp/features/teachly/models/class_content.dart';
import 'package:isapp/features/teachly/models/class_type.dart';
import 'package:isapp/features/teachly/models/content_type.dart';
import 'package:isapp/features/teachly/models/question.dart';
import 'package:isapp/features/teachly/models/school_data.dart';
import 'package:isapp/features/teachly/models/teacher_class.dart';
import 'package:isapp/features/teachly/models/teacher_school.dart';

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
        joinCode: TeacherClass.generateJoinCode(),
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
