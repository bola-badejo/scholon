// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:isapp/TeachlyLearning/model/course_data.dart';
// import 'package:isapp/TeachlyLearning/model/teacher_course.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LocalDataSource {
//   static final LocalDataSource _instance = LocalDataSource._internal();
//   factory LocalDataSource() => _instance;
//   LocalDataSource._internal();

//   static const String _coursesJsonPath = 'assets/json/courses.json';
//   static const String _teacherCoursesKey = 'teacher_courses';
//   static const String _teacherSubjectsKey = 'teacher_subjects';
//   static const String _teacherIdKey = 'teacher_id';

//   // Load courses from JSON file
//   Future<List<Course>> loadCourses() async {
//     try {
//       final jsonString = await rootBundle.loadString(_coursesJsonPath);
//       final jsonData = jsonDecode(jsonString) as List;
      
//       return jsonData.map((courseJson) {
//         return Course.fromJson(courseJson as Map<String, dynamic>);
//       }).toList();
//     } catch (e) {
//       print('Error loading courses: $e');
//       return [];
//     }
//   }

//   // Get teacher ID (simulating authentication)
//   Future<String?> getTeacherId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_teacherIdKey);
//   }

//   Future<void> setTeacherId(String teacherId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_teacherIdKey, teacherId);
//   }

//   // Get teacher's teaching subjects
//   Future<List<String>> getTeacherSubjects() async {
//     final prefs = await SharedPreferences.getInstance();
//     final subjects = prefs.getStringList(_teacherSubjectsKey);
//     return subjects ?? ['General']; // Default subject
//   }

//   Future<void> setTeacherSubjects(List<String> subjects) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList(_teacherSubjectsKey, subjects);
//   }

//   // Teacher's registered courses
//   Future<List<TeacherCourse>> getTeacherCourses() async {
//     final prefs = await SharedPreferences.getInstance();
//     final teacherId = await getTeacherId();
    
//     if (teacherId == null) return [];
    
//     final coursesJson = prefs.getStringList(_teacherCoursesKey);
//     if (coursesJson == null || coursesJson.isEmpty) return [];
    
//     // Load all courses to get full course data
//     final allCourses = await loadCourses();
    
//     final teacherCourses = <TeacherCourse>[];
    
//     for (final courseJson in coursesJson) {
//       try {
//         final json = jsonDecode(courseJson) as Map<String, dynamic>;
//         final courseCode = json['courseCode'] as String;
        
//         // Find the full course data
//         final courseData = allCourses.firstWhere(
//           (course) => course.code == courseCode,
//           orElse: () => throw Exception('Course $courseCode not found'),
//         );
        
//         teacherCourses.add(TeacherCourse.fromJson(json, courseData));
//       } catch (e) {
//         print('Error parsing teacher course: $e');
//       }
//     }
    
//     return teacherCourses;
//   }

//   Future<void> saveTeacherCourse(TeacherCourse teacherCourse) async {
//     final prefs = await SharedPreferences.getInstance();
//     final teacherId = await getTeacherId();
    
//     if (teacherId == null) {
//       throw Exception('Teacher not logged in');
//     }
    
//     // Get existing courses
//     final existingCourses = await getTeacherCourses();
    
//     // Remove old version if exists
//     final filteredCourses = existingCourses
//         .where((course) => course.courseCode != teacherCourse.courseCode)
//         .toList();
    
//     // Add updated course
//     filteredCourses.add(teacherCourse);
    
//     // Save back to shared preferences
//     final coursesJson = filteredCourses
//         .map((course) => jsonEncode(course.toJson()))
//         .toList();
    
//     await prefs.setStringList(_teacherCoursesKey, coursesJson);
//   }

//   Future<void> registerForCourse(Course course) async {
//     final teacherId = await getTeacherId();
    
//     if (teacherId == null) {
//       throw Exception('Teacher not logged in');
//     }
    
//     // Check if already registered
//     final existingCourses = await getTeacherCourses();
//     final alreadyRegistered = existingCourses
//         .any((teacherCourse) => teacherCourse.courseCode == course.code);
    
//     if (alreadyRegistered) {
//       throw Exception('Already registered for this course');
//     }
    
//     // Create new teacher course
//     final teacherCourse = TeacherCourse(
//       courseCode: course.code,
//       courseData: course,
//       teacherId: teacherId,
//       status: CourseProgressStatus.notStarted,
//       overallProgress: 0.0,
//       enrolledAt: DateTime.now(),
//       chapterProgress: List.generate(
//         12, // Assuming 12 chapters per course
//         (index) => ChapterProgress(
//           chapterNumber: index + 1,
//           title: 'Chapter ${index + 1}',
//           progress: 0.0,
//           isCompleted: false,
//         ),
//       ),
//       assessments: [],
//     );
    
//     await saveTeacherCourse(teacherCourse);
//   }

//   Future<void> unregisterFromCourse(String courseCode) async {
//     final prefs = await SharedPreferences.getInstance();
//     final teacherId = await getTeacherId();
    
//     if (teacherId == null) return;
    
//     final existingCourses = await getTeacherCourses();
//     final filteredCourses = existingCourses
//         .where((course) => course.courseCode != courseCode)
//         .toList();
    
//     final coursesJson = filteredCourses
//         .map((course) => jsonEncode(course.toJson()))
//         .toList();
    
//     await prefs.setStringList(_teacherCoursesKey, coursesJson);
//   }

//   // Get categories from courses
//   Future<List<String>> getCategories() async {
//     final courses = await loadCourses();
//     final categories = courses.map((course) => course.category).toSet().toList();
//     categories.sort();
//     return categories;
//   }

//   // Search courses
//   Future<List<Course>> searchCourses(String query) async {
//     final courses = await loadCourses();
//     if (query.isEmpty) return courses;
    
//     final lowercaseQuery = query.toLowerCase();
    
//     return courses.where((course) {
//       return course.title.toLowerCase().contains(lowercaseQuery) ||
//              course.description.toLowerCase().contains(lowercaseQuery) ||
//              course.category.toLowerCase().contains(lowercaseQuery) ||
//              course.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
//              course.instructor.name.toLowerCase().contains(lowercaseQuery);
//     }).toList();
//   }

//   // Get recommended courses based on teacher's subjects
//   Future<List<Course>> getRecommendedCourses() async {
//     final courses = await loadCourses();
//     final teacherSubjects = await getTeacherSubjects();
    
//     if (teacherSubjects.isEmpty || teacherSubjects.contains('General')) {
//       // Return featured/popular courses if no specific subjects
//       return courses
//           .where((course) => course.isFeatured || course.isPopular)
//           .toList();
//     }
    
//     // Filter courses that match teacher's subjects
//     return courses.where((course) {
//       return teacherSubjects.any((subject) =>
//           course.category.toLowerCase().contains(subject.toLowerCase()) ||
//           course.tags.any((tag) => tag.toLowerCase().contains(subject.toLowerCase())) ||
//           course.title.toLowerCase().contains(subject.toLowerCase()));
//     }).toList();
//   }

//   // Get courses by category
//   Future<List<Course>> getCoursesByCategory(String category) async {
//     final courses = await loadCourses();
//     return courses.where((course) => course.category == category).toList();
//   }

//   // Clear all data (for testing/logout)
//   Future<void> clearAllData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_teacherCoursesKey);
//     await prefs.remove(_teacherSubjectsKey);
//     await prefs.remove(_teacherIdKey);
//   }
// }