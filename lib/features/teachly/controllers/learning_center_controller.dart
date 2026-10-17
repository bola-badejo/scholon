import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/teachly/data/repo/course_repo.dart';
import 'package:isapp/features/teachly/data/repo/teacher_repo.dart';
import 'package:isapp/features/teachly/models/course_data.dart';
import 'package:isapp/features/teachly/models/teacher_course.dart';

class LearningCenterController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CourseRepository _courseRepo = Get.find<CourseRepository>();
  final TeacherRepository _teacherRepo = Get.find<TeacherRepository>();
  
  // UI State
  final RxInt _selectedTab = 0.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = ''.obs;
  final RxBool _isSearching = false.obs;
  final RxList<Course> _searchResults = <Course>[].obs;
  
  // Initialize tabController immediately
  late final TabController tabController = TabController(
    length: 4,
    vsync: this,
    initialIndex: _selectedTab.value,
  );
  
  // Getters
  int get selectedTab => _selectedTab.value;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  bool get isSearching => _isSearching.value;
  List<Course> get searchResults => _searchResults;
  
  // Repository data getters
  List<Course> get allCourses => _courseRepo.allCourses;
  List<Course> get filteredCourses => _courseRepo.filteredCourses;
  List<String> get categories => _courseRepo.categories;
  bool get isLoading => _courseRepo.isLoading;
  String get error => _courseRepo.error;
  
  // Teacher data
  List<TeacherCourse> get teacherCourses => _teacherRepo.teacherCourses;
  bool get hasTeacherCourses => _teacherRepo.teacherCourses.isNotEmpty;
  
  // Computed values - Now showing ALL courses
  List<Course> get recommendedCourses => _courseRepo.getRecommendedCourses();
  List<Course> get popularCourses => _courseRepo.getPopularCourses();
  List<Course> get newCourses => _courseRepo.getNewCourses();
  List<Course> get freeCourses => _courseRepo.getFreeCourses();
  List<Course> get featuredCourses => _courseRepo.getFeaturedCourses();
  List<Course> get beginnerCourses => _courseRepo.getAllBeginnerCourses();
  List<Course> get intermediateCourses => _courseRepo.getAllIntermediateCourses();
  List<Course> get advancedCourses => _courseRepo.getAllAdvancedCourses();
  List<Course> get paidCourses => _courseRepo.getAllPaidCourses();
  
  @override
  void onInit() {
    super.onInit();
    
    // Add listener to tabController
    tabController.addListener(_handleTabChange);
    
    // Ensure courses are loaded
    if (_courseRepo.allCourses.isEmpty) {
      _courseRepo.loadCourses();
    }
  }
  
  void _handleTabChange() {
    if (tabController.indexIsChanging) {
      _selectedTab.value = tabController.index;
    }
  }
  
  @override
  void onClose() {
    tabController.removeListener(_handleTabChange);
    tabController.dispose();
    super.onClose();
  }
  
  // Tab navigation
  void selectTab(int index) {
    if (tabController.index != index) {
      tabController.animateTo(index);
      _selectedTab.value = index;
    }
  }
  
  // Category selection
  void selectCategory(String category) {
    _selectedCategory.value = category;
    _courseRepo.filterByCategory(category);
  }
  
  // Search
  void startSearch() {
    _isSearching.value = true;
  }
  
  void endSearch() {
    _isSearching.value = false;
    _searchQuery.value = '';
    _searchResults.clear();
    _courseRepo.clearSearch();
  }
  
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }
  
  Future<void> performSearch() async {
    if (_searchQuery.value.isEmpty) return;
    
    await _courseRepo.searchCourses(_searchQuery.value);
    _searchResults.assignAll(_courseRepo.filteredCourses);
  }
  
  // Course registration
  Future<void> registerForCourse(Course course) async {
    await _teacherRepo.registerForCourse(course);
  }
  
  Future<void> unregisterFromCourse(String courseId) async {
    await _teacherRepo.unregisterFromCourse(courseId);
  }
  
  // Check registration status
  bool isRegisteredForCourse(String courseId) {
    return _teacherRepo.isRegisteredForCourse(courseId);
  }
  
  // Get teacher course
  TeacherCourse? getTeacherCourse(String courseId) {
    return _teacherRepo.getTeacherCourse(courseId);
  }
  
  // Progress update
  Future<void> updateCourseProgress(TeacherCourse teacherCourse) async {
    await _teacherRepo.updateCourseProgress(teacherCourse);
  }
  
  // Refresh data
  Future<void> refresh() async {
    await _courseRepo.refresh();
    await _teacherRepo.loadTeacherCourses();
  }
  
  // Get course by ID
  Course? getCourseById(String id) {
    return _courseRepo.getCourseById(id);
  }
  
  // Get course by code
  Course? getCourseByCode(String code) {
    return _courseRepo.getCourseByCode(code);
  }
  
  // Get courses by category
  List<Course> getCoursesByCategory(String category) {
    return _courseRepo.getCoursesByCategory(category);
  }
  
  // Teacher progress stats
  double get overallProgress => _teacherRepo.getOverallProgress();
  int get completedCourses => _teacherRepo.getCompletedCourses();
  int get inProgressCourses => _teacherRepo.getInProgressCourses();
  int get totalRegisteredCourses => _teacherRepo.teacherCourses.length;
  
  // Clear error
  void clearError() {
    // Course repo error is managed internally
  }
}