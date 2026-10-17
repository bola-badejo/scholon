import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/affairs/screens/affairs_page.dart';
import 'package:isapp/features/affairs/controllers/affairs_tab_controller.dart';
import 'package:isapp/features/affairs/controllers/school_affairs_controller.dart';
import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/profile/screens/profile_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:isapp/features/school/screens/faculty.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';

part 'school_home_sections/01_loading_screen.dart';
part 'school_home_sections/02_quick_stats_section.dart';
part 'school_home_sections/03_bottom_navigation_bar.dart';

class SchoolHomeScreen extends StatefulWidget {
  const SchoolHomeScreen({super.key});

  @override
  State<SchoolHomeScreen> createState() => _SchoolHomeScreenState();
}

class _SchoolHomeScreenState extends State<SchoolHomeScreen> {
  final SchoolAffairsController _schoolAffairsController = Get.put(SchoolAffairsController());
  final AuthService _authService = Get.find<AuthService>();
  SchoolAdminUser? _currentUser;
  bool _isLoading = true;
  int _currentNavIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.getCurrentUser();
      
      if (!mounted) return;
      
      if (user != null && user is SchoolAdminUser) {
        setState(() {
          _currentUser = user;
        });
      } else {
        Get.snackbar(
          'Error',
          'Invalid user type. Please login as school admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await _authService.signOut();
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      print('Error loading school data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                'No school data found',
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
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Dashboard Page (Index 0)
          _buildDashboardPage(),
          
          // Faculty Page (Index 1)
          FacultyPage(),
          
          // Connect Page (Index 2)
          ConnectScreen(),
          
          // Affairs Page (Index 3)
          AffairsTabWrapper(),
          
          // Profile Page (Index 4)
          UniversalProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ====================
  // NAVIGATION METHODS
  // ====================

  void _navigateToFaculty() {
    Get.to(()=>FacultyPage());
  }

  void _navigateToConnect() {
    // Connect navigation
  }

  void _navigateToAffairs() {
    // Affairs navigation
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}