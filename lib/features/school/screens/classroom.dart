import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/affairs/screens/affairs_page.dart';
import 'package:isapp/features/affairs/screens/affairs_page_public.dart';
import 'package:isapp/features/affairs/controllers/affairs_controller.dart';
import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';

part 'classroom_sections/01_parents_section.dart';
part 'classroom_sections/02_school_stat.dart';
part 'classroom_sections/03_class_details.dart';

class ClassroomPage extends StatefulWidget {
  const ClassroomPage({Key? key}) : super(key: key);

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  final AuthService _authService = Get.find<AuthService>();
  final ConnectController _connectController = Get.find<ConnectController>();

  StudentUser? _currentUser;
  bool _isLoading = true;

  // Real data from connections
  List<Map<String, dynamic>> _registeredSchools = [];
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _parents = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
  try {
    setState(() => _isLoading = true);
    
    // Load current user
    try {
      final user = await _authService.getCurrentUser();
      if (user != null && user is StudentUser) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }

    // Load all data in parallel with better error handling
    final results = await Future.wait([
      _loadConnectedSchools().catchError((e) {
        print('Error loading schools: $e');
        return [_createErrorPlaceholder(
          title: 'Failed to load schools',
          description: 'Check your connection',
          type: 'school',
        )];
      }),
      _loadConnectedTeachers().catchError((e) {
        print('Error loading teachers: $e');
        return [_createErrorPlaceholder(
          title: 'Failed to load teachers',
          description: 'Check your connection',
          type: 'teacher',
        )];
      }),
      _loadConnectedClasses().catchError((e) {
        print('Error loading classes: $e');
        return [_createErrorPlaceholder(
          title: 'Failed to load classes',
          description: 'Check your connection',
          type: 'class',
        )];
      }),
      _loadConnectedParents().catchError((e) {
        print('Error loading parents: $e');
        return [_createErrorPlaceholder(
          title: 'Failed to load parents',
          description: 'Check your connection',
          type: 'parent',
        )];
      }),
    ], eagerError: false);

    // Process results
    setState(() {
      _registeredSchools = results[0] as List<Map<String, dynamic>>;
      _teachers = results[1] as List<Map<String, dynamic>>;
      _classes = results[2] as List<Map<String, dynamic>>;
      _parents = results[3] as List<Map<String, dynamic>>;
    });

  } catch (e, stackTrace) {
    print('Error loading classroom data: $e');
    print('Stack trace: $stackTrace');
    
    // Partial loading - show what we have with error states
    _loadPartialMockData();
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<List<Map<String, dynamic>>> _loadConnectedSchools() async {
    try {
      final schools = await _connectController.getConnectedSchools();
      if (schools.isEmpty) {
        return [
          _createEmptyPlaceholder(
            title: 'No Schools Connected',
            description: 'Connect with schools in the Connect tab',
            type: 'school',
            actionText: 'Find Schools',
          ),
        ];
      }
      return schools;
    } catch (e) {
      print('Error loading schools: $e');
      return [
        _createErrorPlaceholder(
          title: 'Failed to load schools',
          description: 'Check your connection and try again',
          type: 'school',
        ),
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _loadConnectedTeachers() async {
    try {
      final teachers = await _connectController.getConnectedTeachers();
      if (teachers.isEmpty) {
        return [
          _createEmptyPlaceholder(
            title: 'No Teachers Connected',
            description: 'Connect with teachers to see them here',
            type: 'teacher',
            actionText: 'Find Teachers',
          ),
        ];
      }
      return teachers;
    } catch (e) {
      print('Error loading teachers: $e');
      return [
        _createErrorPlaceholder(
          title: 'Failed to load teachers',
          description: 'Check your connection and try again',
          type: 'teacher',
        ),
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _loadConnectedClasses() async {
    try {
      final classes = await _connectController.getConnectedClassmates();
      if (classes.isEmpty) {
        return [
          _createEmptyPlaceholder(
            title: 'No Classes Found',
            description: 'Connect with classmates to discover classes',
            type: 'class',
            actionText: 'Find Classmates',
          ),
        ];
      }
      return classes;
    } catch (e) {
      print('Error loading classes: $e');
      return [
        _createErrorPlaceholder(
          title: 'Failed to load classes',
          description: 'Check your connection and try again',
          type: 'class',
        ),
      ];
    }
  }

  // NEW METHOD: Load connected parents
  Future<List<Map<String, dynamic>>> _loadConnectedParents() async {
    try {
      final parents = await _connectController.getConnectedParents();
      if (parents.isEmpty) {
        return [
          _createEmptyPlaceholder(
            title: 'No Parents Connected',
            description: 'Connect with parents in the Connect tab',
            type: 'parent',
            actionText: 'Find Parents',
          ),
        ];
      }
      return parents;
    } catch (e) {
      print('Error loading parents: $e');
      return [
        _createErrorPlaceholder(
          title: 'Failed to load parents',
          description: 'Check your connection and try again',
          type: 'parent',
        ),
      ];
    }
  }

  Map<String, dynamic> _createEmptyPlaceholder({
    required String title,
    required String description,
    required String type,
    required String actionText,
  }) {
    final iconData =
        {
          'school': Icons.school,
          'teacher': Icons.person,
          'class': Icons.group,
          'parent': Icons.family_restroom,
        }[type] ??
        Icons.error;

    final color =
        {
          'school': Colors.blue,
          'teacher': Colors.green,
          'class': Colors.orange,
          'parent': Colors.purple,
        }[type] ??
        Colors.grey;

    return {
      'id': 'placeholder_$type',
      'name': title,
      'description': description,
      'type': type,
      'icon': iconData,
      'color': color,
      'isPlaceholder': true,
      'actionText': actionText,
    };
  }

  Map<String, dynamic> _createErrorPlaceholder({
    required String title,
    required String description,
    required String type,
  }) {
    return {
      'id': 'error_$type',
      'name': title,
      'description': description,
      'type': type,
      'icon': Icons.error_outline,
      'color': Colors.red,
      'isError': true,
      'isPlaceholder': true,
    };
  }

  void _loadPartialMockData() {
    // Only load mock data for sections that failed
    if (_registeredSchools.isEmpty) {
      _registeredSchools = [
        _createEmptyPlaceholder(
          title: 'No Schools Connected',
          description: 'Connect with schools in the Connect tab',
          type: 'school',
          actionText: 'Find Schools',
        ),
      ];
    }

    if (_teachers.isEmpty) {
      _teachers = [
        _createEmptyPlaceholder(
          title: 'No Teachers Connected',
          description: 'Connect with teachers to see them here',
          type: 'teacher',
          actionText: 'Find Teachers',
        ),
      ];
    }

    if (_classes.isEmpty) {
      _classes = [
        _createEmptyPlaceholder(
          title: 'No Classes Found',
          description: 'Connect with classmates to discover classes',
          type: 'class',
          actionText: 'Find Classmates',
        ),
      ];
    }

    if (_parents.isEmpty) {
      _parents = [
        _createEmptyPlaceholder(
          title: 'No Parents Connected',
          description: 'Connect with parents in the Connect tab',
          type: 'parent',
          actionText: 'Find Parents',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Classroom',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(
            icon: const Icon(Icons.connect_without_contact),
            onPressed: _navigateToConnect,
            tooltip: 'Connect with people',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(),

                  const SizedBox(height: 24),

                  // Connected Schools
                  _buildSchoolsSection(),

                  const SizedBox(height: 24),

                  // Connected Teachers
                  _buildTeachersSection(),

                  const SizedBox(height: 24),

                  // Connected Parents - NEW SECTION
                  _buildParentsSection(),

                  const SizedBox(height: 24),

                  // Classes from Classmates
                  _buildClassesSection(),

                  const SizedBox(height: 32),

                  // Connection Status
                  _buildConnectionStatus(),
                ],
              ),
            ),
    );
  }

  void _refreshData() async {
    setState(() => _isLoading = true);
    await _loadAllData();
  }

  void _navigateToConnect() {
    // Navigate to your Connect screen
    Get.toNamed('/connect');
  }

  void _navigateToAffairs(Map<String, dynamic> schoolData) async {
    try {
      // Validate required school data
      if (schoolData.isEmpty) {
        throw 'No school data provided';
      }

      // Check if user is logged in
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        Get.snackbar(
          'Authentication Required',
          'Please log in to access affairs',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Simulate a small delay for better UX (optional)
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to AffairsMainScreen
      await Get.to(() => AffairsMainScreen());

      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } catch (e, stackTrace) {
      // Log the error for debugging
      print('Error navigating to affairs: $e');
      print('Stack trace: $stackTrace');

      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show appropriate error message based on error type
      String errorMessage = 'Failed to navigate to affairs';

      if (e is String) {
        errorMessage = e;
      } else if (e is FirebaseException) {
        errorMessage = _handleFirebaseError(e);
      } else if (e is TimeoutException) {
        errorMessage =
            'Request timed out. Please check your internet connection';
      } else if (e is PlatformException) {
        errorMessage =
            'Platform error: ${e.message ?? "Unknown platform error"}';
      } else if (e is SocketException) {
        errorMessage = 'No internet connection. Please check your network';
      } else if (e is FormatException) {
        errorMessage = 'Data format error. Please try again';
      }

      // Show error dialog or snackbar
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        shouldIconPulse: true,
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            // Optionally retry
            _retryNavigation(schoolData);
          },
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      );

      // Optional: Send error to analytics/crash reporting
      _reportError(e, stackTrace, schoolData);
    }
  }

  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to access affairs';
      case 'unavailable':
        return 'Service is temporarily unavailable. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'invalid-argument':
        return 'Invalid data format. Please contact support';
      case 'not-found':
        return 'School data not found';
      case 'already-exists':
        return 'Affairs data already exists';
      case 'failed-precondition':
        return 'Please complete your profile setup first';
      default:
        return 'An error occurred: ${e.message ?? "Unknown error"}';
    }
  }

  void _retryNavigation(Map<String, dynamic> schoolData) async {
    // Show retry confirmation dialog
    Get.defaultDialog(
      title: 'Retry Navigation',
      middleText: 'Would you like to try navigating to affairs again?',
      textConfirm: 'Retry',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        _navigateToAffairs(schoolData); // Retry
      },
      onCancel: () {
        Get.back(); // Just close dialog
      },
    );
  }

  void _reportError(
    dynamic error,
    StackTrace stackTrace,
    Map<String, dynamic> schoolData,
  ) {
    // Implement error reporting to your preferred service
    // Example: Firebase Crashlytics, Sentry, etc.
    try {
      // Example for Firebase Crashlytics:
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);

      // Log to console for now
      print('=== ERROR REPORT ===');
      print('Error: $error');
      print('Stack Trace: $stackTrace');
      print('School Data: $schoolData');
      print('Timestamp: ${DateTime.now()}');
      print('=== END REPORT ===');
    } catch (reportingError) {
      print('Failed to report error: $reportingError');
    }
  }

  // Alternative simplified version if you prefer less error handling
  void _navigateToAffairsSimple(Map<String, dynamic> schoolData) async {
    try {
      // Quick validation
      if (schoolData.isEmpty) {
        Get.snackbar(
          'Error',
          'No school data available',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Navigate directly
      await Get.to(() => AffairsMainScreen());
    } catch (e) {
      Get.snackbar(
        'Navigation Error',
        'Could not open affairs: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Pre-navigation validation function
  Future<bool> _validateAffairsAccess(Map<String, dynamic> schoolData) async {
    try {
      // Check Firebase connection
      await FirebaseFirestore.instance.collection('dummy').limit(1).get();

      // Check if user has school access
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      // Verify school exists
      final schoolId = schoolData['id'] ?? schoolData['schoolId'];
      if (schoolId == null) return false;

      // Optional: Check if affairs are enabled for this school
      final schoolDoc = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolId)
          .get();

      final hasAffairsAccess = schoolDoc.data()?['hasAffairsAccess'] ?? true;

      return hasAffairsAccess;
    } catch (e) {
      print('Validation error: $e');
      return false;
    }
  }

  // Enhanced navigation with pre-validation
  void _navigateToAffairsWithValidation(Map<String, dynamic> schoolData) async {
    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Validate access
      final hasAccess = await _validateAffairsAccess(schoolData);

      if (!hasAccess) {
        Get.back(); // Close loading
        Get.snackbar(
          'Access Denied',
          'You do not have access to affairs for this school',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Navigate
      await Get.to(() => AffairsMainScreen());

      // Close loading
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } catch (e) {
      // Close loading
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error
      Get.snackbar(
        'Error',
        'Failed to access affairs: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}
