import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import 'package:isapp/data/library/new_courses.dart';
import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/home/models/game_detail_2.dart';
import 'package:isapp/features/home/models/recommended_course.dart';
import 'package:isapp/features/home/models/upcoming_quiz.dart';
import 'package:isapp/features/home/screens/animated_play_button.dart';
import 'package:isapp/features/home/screens/tutorials.dart';
import 'package:isapp/features/home/screens/youtube_player.dart';
import 'package:isapp/features/home/services/home_data_service.dart';
import 'package:isapp/features/home/widgets/full_screen_games_card.dart';
import 'package:isapp/features/home/widgets/full_screen_tools_card.dart';
import 'package:isapp/features/home/widgets/fullscreen/course_card.dart' hide FullScreenGamesCard, FullScreenToolsCard;
import 'package:isapp/features/learning/models/course_models.dart';
import 'package:isapp/features/profile/screens/profile_page.dart';
import 'package:isapp/features/school/screens/classroom.dart';
import 'package:isapp/features/study_guide/study_guide.dart';

export 'package:isapp/features/home/models/course_progress.dart';
export 'package:isapp/features/home/models/game_detail_2.dart';
export 'package:isapp/features/home/models/recommended_course.dart';
export 'package:isapp/features/home/models/upcoming_quiz.dart';
export 'package:isapp/features/home/services/home_data_service.dart';
export 'package:isapp/features/home/widgets/full_screen_games_card.dart';
export 'package:isapp/features/home/widgets/full_screen_tools_card.dart';

part 'home_page_sections/01_loading_screen.dart';
part 'home_page_sections/02_subscription_section.dart';
part 'home_page_sections/03_todays_study_section.dart';
part 'home_page_sections/04_course_card.dart';
part 'home_page_sections/05_bottom_navigation_bar.dart';

// ============================
// MAIN HOME SCREEN
// ============================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = Get.find<AuthService>();
  StudentUser? _currentUser;
  bool _isLoading = true;

  // Data from services
  late List<CourseCategories> _courses;
  late List<CourseCategories> _quizzes;
  late List<CourseCategories> _exams;
  late List<GameDetail> _games;
  late List<Map<String, String>> _tools;
  late List<UpcomingQuiz> _upcomingQuizzes;
  late List<RecommendedCourse> _recommendedCourses;

  List<Tutorial> tutorials = [];

  // Dynamic data
  Map<String, dynamic> _learningStats = {};
  List<Map<String, dynamic>> _todaysStudyItems = [];

  int _currentNavIndex = 0;
  bool _fabExpanded = false;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadUserData();
    loadTutorials();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _courses = HomeDataService.parseCourseCategoriesJson();
    _quizzes = HomeDataService.parseQuizCategoriesJson();
    _exams = HomeDataService.parseExamCategoriesJson();
    _games = HomeDataService.getGames();
    _tools = HomeDataService.getTools();
    _upcomingQuizzes = HomeDataService.getUpcomingQuizzes();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();

      if (!mounted) return;

      if (user != null && user is StudentUser) {
        setState(() {
          _currentUser = user;
        });

        // Load dynamic data
        await _loadDynamicData(user.uid);
      } else {
        Get.snackbar(
          'Error',
          'Invalid user type. Please login as a student.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await _authService.signOut();
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDynamicData(String studentId) async {
    try {
      // Load learning stats
      _learningStats = await HomeDataService.getStudentLearningStats(studentId);

      // Load today's study items
      _todaysStudyItems = await HomeDataService.getTodaysStudyItems(studentId);

      // Load upcoming quizzes
      _upcomingQuizzes = await HomeDataService.getUpcomingQuizzesFromPlan(
        studentId,
      );

      // Load recommended courses
      _recommendedCourses = await HomeDataService.getRecommendedCoursesFromPlan(
        studentId,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading dynamic data: $e');
    }
  }

  Future<void> loadTutorials() async {
    final data = await rootBundle.loadString('assets/tutorials.json');
    final List decoded = json.decode(data);
    setState(() {
      tutorials = decoded.map((e) => Tutorial.fromJson(e)).toList();
    });
  }

  // ====================
  // ORIGINAL NAVIGATIONS
  // ====================

  // Courses Navigation (from original BodyParts)
  void _navigateToCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenCourseCard(categories: _courses),
      ),
    );
  }

  // Quizzes Navigation (from original BodyParts)
  void _navigateToQuizzes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenQuizCard(categories: _quizzes),
      ),
    );
  }

  // Exams Navigation (from original BodyParts)
  void _navigateToExams() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenExamsCard(categories: _exams),
      ),
    );
  }

  // Tools Navigation (from original BodyParts)
  void _navigateToTools() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenToolsCard(toolItems: _tools),
      ),
    );
  }

  // Games Navigation (from original BodyParts)
  void _navigateToGames() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGamesCard(gameItems: _games),
      ),
    );
  }

  void _navigateToCourseDetails(RecommendedCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenCourseCard(categories: _courses),
      ),
    );

    Get.snackbar(
      'Browse Courses',
      'Explore "${course.title}" and more in the Courses section',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentNavIndex == 0 ? _buildCustomAppBar() : null,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Home Page (Index 0)
          _buildHomePageContent(),

          // Activities Page (Index 1)
          StudyPlannerScreen(),

          // Connect is handled by FAB (Index 2)

          // Explore Page (Index 3)
          ClassroomPage(),

          // Profile Page (Index 4)
          UniversalProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _navigateToUpgrade() {
    Get.toNamed('/subscription-plans');
  }
}
