import 'dart:convert';
import 'package:get/get.dart';
import 'package:isapp/TeachlyLearning/model/teacher_course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  SharedPreferences? _prefs; // Change from late to nullable
  
  static const String _teacherIdKey = 'teacher_id';
  static const String _teacherSubjectsKey = 'teacher_subjects';
  static const String _teacherCoursesKey = 'teacher_courses';
  
  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Ensure _prefs is initialized before use
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call onInit() first.');
    }
    return _prefs!;
  }
  
  // Teacher ID
  Future<String?> getTeacherId() async {
    return prefs.getString(_teacherIdKey);
  }
  
  Future<void> setTeacherId(String teacherId) async {
    await prefs.setString(_teacherIdKey, teacherId);
  }
  
  // Teacher Subjects
  Future<List<String>> getTeacherSubjects() async {
    return prefs.getStringList(_teacherSubjectsKey) ?? ['General'];
  }
  
  Future<void> saveTeacherSubjects(List<String> subjects) async {
    await prefs.setStringList(_teacherSubjectsKey, subjects);
  }
  
  // Teacher Courses
  Future<List<TeacherCourse>> getTeacherCourses() async {
    final coursesJson = prefs.getStringList(_teacherCoursesKey);
    if (coursesJson == null || coursesJson.isEmpty) return [];
    
    final courses = <TeacherCourse>[];
    for (final courseJson in coursesJson) {
      try {
        final json = _parseJson(courseJson);
        courses.add(TeacherCourse.fromJson(json));
      } catch (e) {
        print('Error parsing teacher course: $e');
      }
    }
    
    return courses;
  }
  
  Future<void> saveTeacherCourse(TeacherCourse teacherCourse) async {
    final existingCourses = await getTeacherCourses();
    
    // Remove old version if exists
    final filteredCourses = existingCourses
        .where((course) => course.courseId != teacherCourse.courseId)
        .toList();
    
    // Add updated course
    filteredCourses.add(teacherCourse);
    
    // Save back to storage
    final coursesJson = filteredCourses
        .map((course) => _encodeJson(course.toJson()))
        .toList();
    
    await prefs.setStringList(_teacherCoursesKey, coursesJson);
  }
  
  Future<void> removeTeacherCourse(String courseId) async {
    final existingCourses = await getTeacherCourses();
    final filteredCourses = existingCourses
        .where((course) => course.courseId != courseId)
        .toList();
    
    final coursesJson = filteredCourses
        .map((course) => _encodeJson(course.toJson()))
        .toList();
    
    await prefs.setStringList(_teacherCoursesKey, coursesJson);
  }
  
  // Clear all data (for logout/testing)
  Future<void> clearAllData() async {
    await prefs.remove(_teacherIdKey);
    await prefs.remove(_teacherSubjectsKey);
    await prefs.remove(_teacherCoursesKey);
  }
  
  // Helper methods for JSON handling
  Map<String, dynamic> _parseJson(String jsonString) {
    return Map<String, dynamic>.from(_decodeJson(jsonString));
  }
  
  dynamic _decodeJson(String jsonString) {
    // Handle JSON parsing with error checking
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      // If standard JSON parsing fails, try to clean the string
      final cleaned = jsonString
          .replaceAll(r'\', '')
          .replaceAll('"{', '{')
          .replaceAll('}"', '}');
      return jsonDecode(cleaned);
    }
  }
  
  String _encodeJson(Map<String, dynamic> json) {
    return jsonEncode(json);
  }
}