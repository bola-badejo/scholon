import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/parents/screens/children_list_screen.dart';
import 'package:isapp/features/parents/screens/parent_dashboard_screen.dart';
import 'package:isapp/features/profile/screens/profile_page.dart';

export 'package:isapp/features/parents/screens/children_list_screen.dart';
export 'package:isapp/features/parents/screens/parent_dashboard_screen.dart';

part 'parent_home_sections/01_loading_screen.dart';
part 'parent_home_sections/02_child_info_item.dart';
part 'parent_home_sections/03_notification_item.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final AuthService _authService = Get.find<AuthService>();
  ParentUser? _currentUser;
  bool _isLoading = true;
  
  int _currentNavIndex = 0;
  bool _fabExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.getCurrentUser();
      
      if (!mounted) return;
      
      if (user != null && user is ParentUser) {
        setState(() {
          _currentUser = user;
        });
      } else {
        Get.snackbar(
          'Error',
          'Invalid user type. Please login as a parent.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await _authService.signOut();
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      print('Error loading parent data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Navigation Methods - EXACT SAME PATTERN AS TEACHER
  void _navigateToHome() {
    setState(() {
      _currentNavIndex = 0;
      _fabExpanded = false;
    });
  }

  void _navigateToChildren() {
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

  void _navigateToParentDashboard() {
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
  
  Widget _getCurrentPage() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return ChildrenListScreen();
      case 2:
        return ParentDashboardScreen();
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
                'No parent data found',
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
