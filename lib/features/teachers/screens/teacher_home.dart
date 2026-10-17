import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/profile/screens/profile_page.dart';
import 'package:isapp/features/teachers/services/teacher_home_service.dart';
import 'package:isapp/features/teachers/widgets/full_screen_tools_card.dart';
import 'package:isapp/features/teachly/screens/learning_center_screen.dart';
import 'package:isapp/features/teachly/screens/teacher_page.dart';

export 'package:isapp/features/teachers/widgets/full_screen_tools_card.dart';

part 'teacher_home_sections/01_loading_screen.dart';
part 'teacher_home_sections/02_recommended_course_card.dart';
part 'teacher_home_sections/03_quick_stats_section.dart';
part 'teacher_home_sections/04_student_item.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final AuthService _authService = Get.find<AuthService>();
  late List<Map<String, String>> _tools;
  TeacherUser? _currentUser;
  bool _isLoading = true;
  
  // Navigation variables
  int _currentNavIndex = 0;
  bool _fabExpanded = false;

  // Page controllers for different sections
  final List<Widget> _pages = [
    _HomeContent(), // This will be the home content
    _CoursesContent(),
    _TeacherNetworkContent(),
    _ProfileContent(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeData();
  }

  void _initializeData() {
    _tools = HomeDataService.getTools();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.getCurrentUser();
      
      if (!mounted) return;
      
      if (user != null && user is TeacherUser) {
        setState(() {
          _currentUser = user;
        });
      } else {
        Get.snackbar(
          'Error',
          'Invalid user type. Please login as a teacher.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await _authService.signOut();
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      print('Error loading teacher data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToTools() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenToolsCard(toolItems: _tools),
      ),
    );
  }

  // Navigation Methods - now just change the index
  void _navigateToHome() {
    setState(() {
      _currentNavIndex = 0;
      _fabExpanded = false;
    });
  }

  void _navigateToCourses() {
    setState(() {
      _currentNavIndex = 1;
      _fabExpanded = false;
    });
  }

  void _navigateToConnect() {
    setState(() {
      _fabExpanded = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.toNamed('/connect');
      setState(() {
        _fabExpanded = false;
      });
    });
  }

  void _navigateToTeacherNetwork() {
    setState(() {
      _currentNavIndex = 2;
      _fabExpanded = false;
    });
  }

  void _navigateToProfile() {
    setState(() {
      _currentNavIndex = 3;
      _fabExpanded = false;
    });
  }

  // Method to get the current page based on index
  Widget _getCurrentPage() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return LearningCenterScreen();
      case 2:
        return BoardPage();
      case 3:
        return UniversalProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No teacher data found',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/auth'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentNavIndex == 0 ? _buildCustomAppBar() : null,
      body: _getCurrentPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

// Placeholder widget classes for the different pages
class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _CoursesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _TeacherNetworkContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _ProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
