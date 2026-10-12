import 'dart:convert';
import 'package:get/get.dart';
import 'package:isapp/TeachlyLearning/data/repo/teacher_repo.dart';
import 'package:isapp/TeachlyLearning/model/course_data.dart';
import 'package:isapp/TeachlyLearning/services/storage_services.dart';
import 'package:isapp/Utils/library/teachly_courses.dart';

class CourseRepository extends GetxController {
  final StorageService _storage = StorageService();
  
  final RxList<Course> _allCourses = <Course>[].obs;
  final RxList<Course> _filteredCourses = <Course>[].obs;
  final RxList<String> _categories = <String>[].obs;
  final RxString _selectedCategory = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  
  List<Course> get allCourses => _allCourses;
  List<Course> get filteredCourses => _filteredCourses;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory.value;
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  
  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }
  
  Future<void> loadCourses() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      print('Loading courses from TeachlyCourses...');
      
      // Parse courses from your TeachlyCourses class
      final jsonString = TeachlyCourses.curriculum;
      
      final jsonData = jsonDecode(jsonString) as List;
      print('Parsed ${jsonData.length} courses');
      
      final courses = <Course>[];
      for (var i = 0; i < jsonData.length; i++) {
        try {
          final courseJson = jsonData[i] as Map<String, dynamic>;
          final course = Course.fromJson(courseJson);
          courses.add(course);
        } catch (e) {
          print('Error parsing course $i: $e');
        }
      }
      
      _allCourses.assignAll(courses);
      
      // Extract unique categories
      final categorySet = <String>{};
      for (final course in _allCourses) {
        categorySet.add(course.category);
      }
      _categories.assignAll(categorySet.toList()..sort());
      
      // Show ALL courses, not just published ones
      _filteredCourses.assignAll(_allCourses);
      
      print('Successfully loaded ${_allCourses.length} courses');
      print('Categories: $_categories');
      
      _isLoading.value = false;
    } catch (e, stackTrace) {
      _isLoading.value = false;
      _error.value = 'Failed to load courses: ${e.toString()}';
      print('ERROR loading courses: $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  // Get recommended courses based on teacher's subjects
  List<Course> getRecommendedCourses() {
    try {
      // Get teacher's registered course categories
      final teacherRepo = Get.find<TeacherRepository>();
      final teacherCourses = teacherRepo.teacherCourses;
      
      if (teacherCourses.isEmpty) {
        // Return all courses if no registered courses
        return _allCourses.take(6).toList();
      }
      
      // Get categories from teacher's registered courses
      final teacherCategories = teacherCourses
          .map((tc) => tc.course.category)
          .toSet()
          .toList();
      
      // Return courses matching teacher's categories
      return _allCourses
          .where((course) => teacherCategories.contains(course.category))
          .take(6)
          .toList();
    } catch (e) {
      return _allCourses.take(6).toList();
    }
  }
  
  // Filter courses by category
  void filterByCategory(String category) {
    _selectedCategory.value = category;
    
    if (category.isEmpty) {
      _filteredCourses.assignAll(_allCourses);
    } else {
      _filteredCourses.assignAll(
        _allCourses.where((course) => course.category == category).toList()
      );
    }
  }
  
  // Search courses
  Future<void> searchCourses(String query) async {
    _searchQuery.value = query;
    
    if (query.isEmpty) {
      filterByCategory(_selectedCategory.value);
      return;
    }
    
    try {
      _isLoading.value = true;
      
      final lowercaseQuery = query.toLowerCase();
      final results = _allCourses.where((course) {
        return course.title.toLowerCase().contains(lowercaseQuery) ||
               course.description.toLowerCase().contains(lowercaseQuery) ||
               course.category.toLowerCase().contains(lowercaseQuery) ||
               course.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
               course.instructor.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
      
      _filteredCourses.assignAll(results);
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      _error.value = 'Search failed: $e';
    }
  }
  
  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
    filterByCategory(_selectedCategory.value);
  }
  
  // Get courses by difficulty
  List<Course> getCoursesByDifficulty(CourseDifficulty difficulty) {
    return _allCourses
        .where((course) => course.difficulty == difficulty)
        .toList();
  }
  
  // Get free courses
  List<Course> getFreeCourses() {
    return _allCourses
        .where((course) => course.isFree)
        .toList();
  }
  
  // Get popular courses (by enrollment)
  List<Course> getPopularCourses() {
    return _allCourses
        .where((course) => course.enrollmentCount >= 100)
        .toList()
        .sublist(0, min(6, _allCourses.length))
        .toList();
  }
  
  // Get new courses
  List<Course> getNewCourses() {
    return _allCourses
        .where((course) => course.isNew)
        .toList();
  }
  
  // Get featured courses (by rating and enrollment)
  List<Course> getFeaturedCourses() {
    return _allCourses
        .where((course) => course.rating >= 4.0 && course.enrollmentCount >= 50)
        .toList()
        .sublist(0, min(6, _allCourses.length))
        .toList();
  }
  
  // Get all beginner courses
  List<Course> getAllBeginnerCourses() {
    return _allCourses
        .where((course) => course.difficulty == CourseDifficulty.beginner)
        .toList();
  }
  
  // Get all intermediate courses
  List<Course> getAllIntermediateCourses() {
    return _allCourses
        .where((course) => course.difficulty == CourseDifficulty.intermediate)
        .toList();
  }
  
  // Get all advanced courses
  List<Course> getAllAdvancedCourses() {
    return _allCourses
        .where((course) => course.difficulty == CourseDifficulty.advanced)
        .toList();
  }
  
  // Get all paid courses
  List<Course> getAllPaidCourses() {
    return _allCourses
        .where((course) => !course.isFree)
        .toList();
  }
  
  // Get courses by category
  List<Course> getCoursesByCategory(String category) {
    return _allCourses
        .where((course) => course.category == category)
        .toList();
  }
  
  // Find course by ID
  Course? getCourseById(String id) {
    return _allCourses.firstWhereOrNull((course) => course.id == id);
  }
  
  // Find course by code
  Course? getCourseByCode(String code) {
    return _allCourses.firstWhereOrNull((course) => course.code == code);
  }
  
  // Refresh data
  Future<void> refresh() async {
    await loadCourses();
  }
  
  int min(int a, int b) => a < b ? a : b;
}