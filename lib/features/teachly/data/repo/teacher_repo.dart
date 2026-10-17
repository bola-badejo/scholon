import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/teachly/models/course_data.dart';
import 'package:isapp/features/teachly/models/teacher_course.dart';
import 'package:isapp/features/teachly/services/storage_services.dart';

class TeacherRepository extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  
  final RxList<TeacherCourse> _teacherCourses = <TeacherCourse>[].obs;
  final RxString _teacherId = ''.obs;
  final RxList<String> _teacherSubjects = <String>[].obs;
  
  List<TeacherCourse> get teacherCourses => _teacherCourses;
  String get teacherId => _teacherId.value;
  List<String> get teacherSubjects => _teacherSubjects;
  
  @override
  void onInit() {
    super.onInit();
    _loadTeacherData();
  }
  
  Future<void> _loadTeacherData() async {
    // Load teacher ID (simulated)
    _teacherId.value = await _storage.getTeacherId() ?? 'teacher_001';
    
    // Load teacher subjects (simulated)
    final subjects = await _storage.getTeacherSubjects();
    _teacherSubjects.assignAll(subjects);
    
    // Load teacher's registered courses
    await loadTeacherCourses();
  }
  
  Future<void> loadTeacherCourses() async {
    try {
      final courses = await _storage.getTeacherCourses();
      _teacherCourses.assignAll(courses);
    } catch (e) {
      print('Error loading teacher courses: $e');
    }
  }

  List<TeacherCourse> getTeacherCourses() {
    return _teacherCourses;
  }
  
  Future<void> registerForCourse(Course course) async {
    try {
      // Check if already registered
      final alreadyRegistered = _teacherCourses
          .any((tc) => tc.courseId == course.id);
      
      if (alreadyRegistered) {
        throw Exception('Already registered for this course');
      }
      
      // Create new teacher course
      final teacherCourse = TeacherCourse(
        courseId: course.id,
        course: course,
        teacherId: _teacherId.value,
        status: CourseProgressStatus.notStarted,
        overallProgress: 0.0,
        enrolledAt: DateTime.now(),
        chapterProgress: List.generate(
          course.chaptersCount,
          (index) => ChapterProgress(
            chapterNumber: index + 1,
            title: 'Chapter ${index + 1}',
            progress: 0.0,
            isCompleted: false,
          ),
        ),
        assessments: [],
      );
      
      // Save to storage
      await _storage.saveTeacherCourse(teacherCourse);
      
      // Update local list
      _teacherCourses.add(teacherCourse);
      
      // Update teacher subjects based on new course category
      if (!_teacherSubjects.contains(course.category)) {
        _teacherSubjects.add(course.category);
        await _storage.saveTeacherSubjects(_teacherSubjects);
      }
      
      Get.snackbar(
        'Success',
        'Successfully registered for ${course.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to register: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }
  
  Future<void> unregisterFromCourse(String courseId) async {
    try {
      await _storage.removeTeacherCourse(courseId);
      _teacherCourses.removeWhere((tc) => tc.courseId == courseId);
      
      Get.snackbar(
        'Success',
        'Successfully unregistered from course',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to unregister: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }
  
  Future<void> updateCourseProgress(TeacherCourse teacherCourse) async {
    try {
      await _storage.saveTeacherCourse(teacherCourse);
      
      // Update in local list
      final index = _teacherCourses.indexWhere((tc) => tc.courseId == teacherCourse.courseId);
      if (index >= 0) {
        _teacherCourses[index] = teacherCourse;
      }
      
      update();
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }
  
  bool isRegisteredForCourse(String courseId) {
    return _teacherCourses.any((tc) => tc.courseId == courseId);
  }
  
  TeacherCourse? getTeacherCourse(String courseId) {
    return _teacherCourses.firstWhereOrNull((tc) => tc.courseId == courseId);
  }
  
  double getOverallProgress() {
    if (_teacherCourses.isEmpty) return 0.0;
    
    final totalProgress = _teacherCourses
        .map((tc) => tc.overallProgress)
        .reduce((a, b) => a + b);
    
    return totalProgress / _teacherCourses.length;
  }
  
  int getCompletedCourses() {
    return _teacherCourses
        .where((tc) => tc.status == CourseProgressStatus.completed)
        .length;
  }
  
  int getInProgressCourses() {
    return _teacherCourses
        .where((tc) => tc.status == CourseProgressStatus.inProgress)
        .length;
  }
  
  void setTeacherSubjects(List<String> subjects) {
    _teacherSubjects.assignAll(subjects);
    _storage.saveTeacherSubjects(subjects);
  }
}