// import 'package:flutter/foundation.dart';
// import 'package:isapp/TeachlyLearning/model/course_data.dart';
// import 'package:isapp/TeachlyLearning/model/teacher_course.dart';
// import 'local_data_source.dart';

// class CourseRepository with ChangeNotifier {
//   final LocalDataSource _localDataSource = LocalDataSource();
  
//   // State
//   List<Course> _allCourses = [];
//   List<Course> _filteredCourses = [];
//   List<TeacherCourse> _teacherCourses = [];
//   List<String> _categories = [];
//   String? _selectedCategory;
//   String _searchQuery = '';
//   bool _isLoading = false;
//   String? _error;
  
//   // Getters
//   List<Course> get allCourses => _allCourses;
//   List<Course> get filteredCourses => _filteredCourses;
//   List<TeacherCourse> get teacherCourses => _teacherCourses;
//   List<String> get categories => _categories;
//   String? get selectedCategory => _selectedCategory;
//   String get searchQuery => _searchQuery;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
  
//   // Recommended courses (based on teacher's subjects)
//   List<Course> get recommendedCourses {
//     final teacherSubjects = _getTeacherSubjectsForRecommendation();
    
//     if (teacherSubjects.isEmpty) {
//       return _allCourses
//           .where((course) => course.isFeatured || course.isPopular)
//           .toList();
//     }
    
//     return _allCourses.where((course) {
//       return teacherSubjects.any((subject) =>
//           _courseMatchesSubject(course, subject));
//     }).toList();
//   }
  
//   // Popular courses (by enrollment)
//   List<Course> get popularCourses {
//     return _allCourses
//         .where((course) => course.isPopular)
//         .toList();
//   }
  
//   // New courses
//   List<Course> get newCourses {
//     return _allCourses
//         .where((course) => course.isNew)
//         .toList();
//   }
  
//   // Free courses
//   List<Course> get freeCourses {
//     return _allCourses
//         .where((course) => course.isFree)
//         .toList();
//   }
  
//   // Initialize repository
//   Future<void> initialize() async {
//     await _loadAllData();
//   }
  
//   // Load all data
//   Future<void> _loadAllData() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();
      
//       // Load all courses
//       _allCourses = await _localDataSource.loadCourses();
      
//       // Load teacher's registered courses
//       _teacherCourses = await _localDataSource.getTeacherCourses();
      
//       // Load categories
//       _categories = await _localDataSource.getCategories();
      
//       // Initial filtered courses (all courses)
//       _filteredCourses = List.from(_allCourses);
      
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _error = 'Failed to load data: $e';
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // Register for a course
//   Future<void> registerForCourse(Course course) async {
//     try {
//       _isLoading = true;
//       notifyListeners();
      
//       await _localDataSource.registerForCourse(course);
      
//       // Reload teacher courses
//       _teacherCourses = await _localDataSource.getTeacherCourses();
      
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _error = 'Failed to register for course: $e';
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // Unregister from a course
//   Future<void> unregisterFromCourse(String courseCode) async {
//     try {
//       _isLoading = true;
//       notifyListeners();
      
//       await _localDataSource.unregisterFromCourse(courseCode);
      
//       // Reload teacher courses
//       _teacherCourses = await _localDataSource.getTeacherCourses();
      
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _error = 'Failed to unregister from course: $e';
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // Update teacher course progress
//   Future<void> updateTeacherCourseProgress(TeacherCourse teacherCourse) async {
//     try {
//       await _localDataSource.saveTeacherCourse(teacherCourse);
      
//       // Update in local list
//       final index = _teacherCourses.indexWhere((tc) => tc.courseCode == teacherCourse.courseCode);
//       if (index >= 0) {
//         _teacherCourses[index] = teacherCourse;
//       }
      
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to update progress: $e';
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // Filter courses by category
//   void filterByCategory(String? category) {
//     _selectedCategory = category;
    
//     if (category == null) {
//       _filteredCourses = List.from(_allCourses);
//     } else {
//       _filteredCourses = _allCourses
//           .where((course) => course.category == category)
//           .toList();
//     }
    
//     notifyListeners();
//   }
  
//   // Search courses
//   Future<void> searchCourses(String query) async {
//     _searchQuery = query;
    
//     if (query.isEmpty) {
//       // Reset to current category filter
//       filterByCategory(_selectedCategory);
//     } else {
//       try {
//         _isLoading = true;
//         notifyListeners();
        
//         _filteredCourses = await _localDataSource.searchCourses(query);
        
//         _isLoading = false;
//         notifyListeners();
//       } catch (e) {
//         _isLoading = false;
//         _error = 'Search failed: $e';
//         notifyListeners();
//       }
//     }
//   }
  
//   // Clear search
//   void clearSearch() {
//     _searchQuery = '';
//     filterByCategory(_selectedCategory);
//   }
  
//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
  
//   // Refresh all data
//   Future<void> refresh() async {
//     await _loadAllData();
//   }
  
//   // Helper methods for recommendations
//   List<String> _getTeacherSubjectsForRecommendation() {
//     // In a real app, this would come from user profile
//     // For now, we'll use categories from registered courses
//     final registeredCategories = _teacherCourses
//         .map((tc) => tc.courseData.category)
//         .toSet()
//         .toList();
    
//     if (registeredCategories.isEmpty) {
//       return ['General'];
//     }
    
//     return registeredCategories;
//   }
  
//   bool _courseMatchesSubject(Course course, String subject) {
//     return course.category.toLowerCase().contains(subject.toLowerCase()) ||
//            course.tags.any((tag) => tag.toLowerCase().contains(subject.toLowerCase())) ||
//            course.title.toLowerCase().contains(subject.toLowerCase()) ||
//            course.instructor.specialization.any((spec) => 
//                spec.toLowerCase().contains(subject.toLowerCase()));
//   }
  
//   // Check if teacher is registered for a course
//   bool isRegisteredForCourse(String courseCode) {
//     return _teacherCourses.any((tc) => tc.courseCode == courseCode);
//   }
  
//   // Get teacher course by code
//   TeacherCourse? getTeacherCourse(String courseCode) {
//     return _teacherCourses.firstWhere(
//       (tc) => tc.courseCode == courseCode,
//       orElse: () => throw Exception('Course not registered'),
//     );
//   }
// }