import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isapp/Models/user.dart';
import 'package:isapp/Screens/affairs/affairs_page.dart';
import 'package:isapp/Screens/affairs/affairs_page_public.dart';
import 'package:isapp/Screens/affairs/controller/affairs_controller.dart';
import 'package:isapp/Screens/affairs/controller/affairs_public_controller.dart';
import 'package:isapp/Screens/authentication/controllers/authentication_controller.dart';
import 'package:isapp/Screens/home/connect.dart';

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

  Widget _buildParentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Connected Parents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (_parents.isEmpty || _parents.first['isPlaceholder'] == true)
              TextButton.icon(
                onPressed: _navigateToConnect,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_parents.isEmpty)
          _buildEmptyState(
            icon: Icons.family_restroom,
            title: 'No parents connected',
            description: 'Connect with parents to see them here',
            actionText: 'Find Parents',
            onAction: _navigateToConnect,
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _parents.length,
              itemBuilder: (context, index) {
                return _buildParentCard(_parents[index], index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildParentCard(Map<String, dynamic> parent, int index) {
    final isPlaceholder = parent['isPlaceholder'] == true;
    final isError = parent['isError'] == true;
    final color = parent['color'] as Color? ?? Colors.purple;

    return GestureDetector(
      onTap: isPlaceholder ? _navigateToConnect : null,
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: index != _parents.length - 1 ? 12 : 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.shade50
              : isPlaceholder
              ? Colors.grey.shade50
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isError
                ? Colors.red.shade200
                : isPlaceholder
                ? Colors.grey.shade300
                : Colors.grey.shade200,
          ),
          boxShadow: isPlaceholder || isError
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              parent['icon'] as IconData? ?? Icons.family_restroom,
              size: 40,
              color: isError ? Colors.red : color,
            ),
            const SizedBox(height: 8),
            Text(
              parent['name'] as String? ?? 'Parent',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isError
                    ? Colors.red
                    : isPlaceholder
                    ? Colors.grey
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isPlaceholder && parent['relationship'] != null) ...[
              const SizedBox(height: 4),
              Text(
                parent['relationship'] as String,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (isPlaceholder && parent['actionText'] != null) ...[
              const SizedBox(height: 8),
              Text(
                parent['actionText'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.school, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading classroom information...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    // SAFE NULL HANDLING
    final userName = _currentUser?.name ?? 'Student';
    final studentName = userName.isNotEmpty
        ? userName.split(' ').first
        : 'Student';

    // SAFE NULL HANDLING for classGrade
    final classGrade = _currentUser?.classGrade;
    final className = classGrade != null
        ? 'Grade $classGrade'
        : 'Grade Not specified';

    // SAFE NULL HANDLING for schoolName
    final schoolName = _currentUser?.schoolName ?? 'No school connected';

    // Calculate actual connections (excluding placeholders) with null safety
    final actualSchools = _registeredSchools
        .where((s) => s['isPlaceholder'] != true)
        .length;

    final actualTeachers = _teachers
        .where((t) => t['isPlaceholder'] != true)
        .length;

    final actualParents = _parents
        .where((p) => p['isPlaceholder'] != true)
        .length;

    final actualClasses = _classes
        .where((c) => c['isPlaceholder'] != true)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Icon(Icons.school, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Your Classroom, $studentName!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$className • $schoolName',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(
                      icon: Icons.school,
                      label: '$actualSchools Schools',
                      color: Colors.blue,
                      onTap: actualSchools > 0
                          ? () {
                              // Show schools
                            }
                          : null,
                    ),
                    _buildStatChip(
                      icon: Icons.people,
                      label: '$actualTeachers Teachers',
                      color: Colors.green,
                      onTap: actualTeachers > 0
                          ? () {
                              // Show teachers
                            }
                          : null,
                    ),
                    _buildStatChip(
                      icon: Icons.family_restroom,
                      label: '$actualParents Parents',
                      color: Colors.purple,
                      onTap: actualParents > 0
                          ? () {
                              // Show parents
                            }
                          : null,
                    ),
                    _buildStatChip(
                      icon: Icons.group,
                      label: '$actualClasses Classes',
                      color: Colors.orange,
                      onTap: actualClasses > 0
                          ? () {
                              // Show classes
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Connected Schools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (_registeredSchools.isEmpty)
              TextButton.icon(
                onPressed: _navigateToConnect,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_registeredSchools.isEmpty)
          _buildEmptyState(
            icon: Icons.school,
            title: 'No schools connected',
            description: 'Connect with schools to see them here',
            actionText: 'Find Schools',
            onAction: _navigateToConnect,
          )
        else
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var school in _registeredSchools)
                  Padding(
                    padding: EdgeInsets.only(
                      right: school != _registeredSchools.last ? 12 : 0,
                    ),
                    child: _buildSchoolCard(school),
                  ),
              ],
            ),
          ),
      ],
    );
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

  Widget _buildSchoolCard(Map<String, dynamic> school) {
    // SAFE NULL HANDLING
    final schoolName = school['name']?.toString() ?? 'Unknown School';
    final isPlaceholder =
        schoolName.contains('No Schools') || school['isPlaceholder'] == true;

    final schoolLogo = school['logo']?.toString() ?? '🏫';
    final schoolType = school['type']?.toString() ?? 'School';
    final schoolAddress =
        school['address']?.toString() ?? 'Address not available';

    // SAFE Color handling
    final color = school['color'] is Color
        ? school['color'] as Color
        : Colors.blue;

    return GestureDetector(
      onTap: () {
        if (isPlaceholder) {
          _navigateToConnect();
        } else {
          _navigateToAffairs(school);
        }
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPlaceholder ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaceholder ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          boxShadow: isPlaceholder
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: schoolLogo.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              schoolLogo,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.school, size: 30);
                              },
                            ),
                          )
                        : Text(
                            schoolLogo,
                            style: const TextStyle(fontSize: 24),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schoolName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPlaceholder ? Colors.grey : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schoolType,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPlaceholder ? Colors.grey : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              schoolAddress,
              style: TextStyle(
                fontSize: 14,
                color: isPlaceholder ? Colors.grey : Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            if (!isPlaceholder)
              Row(
                children: [
                  Expanded(
                    child: _buildSchoolStat(
                      icon: Icons.people,
                      value: (school['students'] ?? 0).toString(),
                      label: 'Students',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSchoolStat(
                      icon: Icons.person,
                      value: (school['teachers'] ?? 0).toString(),
                      label: 'Teachers',
                      color: Colors.green,
                    ),
                  ),
                ],
              )
            else
              Center(
                child: TextButton(
                  onPressed: _navigateToConnect,
                  child: const Text('Connect with schools'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTeachersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Connected Teachers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (_teachers.isEmpty)
              TextButton.icon(
                onPressed: _navigateToConnect,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_teachers.isEmpty)
          _buildEmptyState(
            icon: Icons.person,
            title: 'No teachers connected',
            description: 'Connect with teachers to see them here',
            actionText: 'Find Teachers',
            onAction: _navigateToConnect,
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var teacher in _teachers) _buildTeacherCard(teacher),
            ],
          ),
      ],
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
  // SAFE NULL HANDLING
  final teacherName = teacher['name']?.toString() ?? 'Unknown Teacher';
  final isPlaceholder = teacherName.contains('No Teachers') || 
                       teacher['isPlaceholder'] == true;
  
  final teacherSubject = teacher['subject']?.toString() ?? 'General';
  final teacherAvatar = teacher['avatar']?.toString() ?? '👨‍🏫';
  final teacherClasses = teacher['classes'] as List? ?? [];
  
  // SAFE Color handling
  final color = teacher['color'] is Color 
      ? teacher['color'] as Color 
      : Colors.green;

  return Container(
    width: (MediaQuery.of(context).size.width - 44) / 2,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isPlaceholder ? Colors.grey.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isPlaceholder ? Colors.grey.shade300 : Colors.grey.shade200,
      ),
      boxShadow: isPlaceholder
          ? null
          : [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: teacher['profileImageUrl'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    teacher['profileImageUrl'].toString(),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text(teacherAvatar, style: const TextStyle(fontSize: 32)));
                    },
                  ),
                )
              : Center(
                  child: Text(
                    teacherAvatar,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          teacherName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPlaceholder ? Colors.grey : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          teacherSubject,
          style: TextStyle(
            fontSize: 14,
            color: isPlaceholder ? Colors.grey : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (teacherClasses.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var className in teacherClasses.take(3))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    className.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (teacherClasses.length > 3)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${teacherClasses.length - 3}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 12),
        if (!isPlaceholder)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.email, color: Colors.grey[600]),
                onPressed: () {
                  final email = teacher['email']?.toString();
                  if (email != null && email.isNotEmpty && email != 'No email') {
                    // Launch email
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.phone, color: Colors.grey[600]),
                onPressed: () {
                  final phone = teacher['phone']?.toString();
                  if (phone != null && phone.isNotEmpty && phone != 'No phone') {
                    // Launch phone
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.message, color: Colors.grey[600]),
                onPressed: () {
                  // Navigate to chat
                },
              ),
            ],
          )
        else
          TextButton(
            onPressed: _navigateToConnect,
            child: const Text('Connect with teachers'),
          ),
      ],
    ),
  );
}

  Widget _buildClassesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Classes from Connections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (_classes.isEmpty)
              TextButton.icon(
                onPressed: _navigateToConnect,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Based on your classmates\' connections',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        if (_classes.isEmpty)
          _buildEmptyState(
            icon: Icons.group,
            title: 'No classes found',
            description: 'Connect with classmates to discover classes',
            actionText: 'Find Classmates',
            onAction: _navigateToConnect,
          )
        else
          Column(
            children: [
              for (var classItem in _classes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildClassCard(classItem),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classItem) {
  // SAFE NULL HANDLING
  final className = classItem['name']?.toString() ?? 'Unknown Class';
  final isPlaceholder = className.contains('No Classes') || 
                       classItem['isPlaceholder'] == true;
  
  final classSection = classItem['section']?.toString() ?? 'General';
  final classTeacher = classItem['teacher']?.toString() ?? 'Not assigned';
  final classRoom = classItem['room']?.toString() ?? 'Room 000';
  
  final classmates = classItem['classmates'] as List<dynamic>? ?? [];
  final classmatesCount = classmates.length;
  
  // SAFE Color and Icon handling
  final color = classItem['color'] is Color 
      ? classItem['color'] as Color 
      : Colors.grey;
  
  final iconData = classItem['icon'] is IconData
      ? classItem['icon'] as IconData
      : Icons.school;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isPlaceholder ? Colors.grey.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isPlaceholder ? Colors.grey.shade300 : Colors.grey.shade200,
      ),
      boxShadow: isPlaceholder
          ? null
          : [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                className,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPlaceholder ? Colors.grey : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$classSection • $classTeacher',
                style: TextStyle(
                  fontSize: 14,
                  color: isPlaceholder ? Colors.grey : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '$classmatesCount classmates',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.room, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    classRoom,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              if (classmatesCount > 0 && !isPlaceholder) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: classmatesCount > 3 ? 3 : classmatesCount,
                    itemBuilder: (context, index) {
                      final classmate = classmates[index];
                      final mateName = classmate['name']?.toString() ?? '?';
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            mateName.isNotEmpty ? mateName.substring(0, 1).toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isPlaceholder)
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // Navigate to class details
              _showClassDetails(classItem);
            },
          ),
      ],
    ),
  );
}

  void _showClassDetails(Map<String, dynamic> classItem) {
  final classmates = classItem['classmates'] as List<dynamic>? ?? [];
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final className = classItem['name']?.toString() ?? 'Unknown Class';
      final classSection = classItem['section']?.toString() ?? 'General';
      final color = classItem['color'] is Color 
          ? classItem['color'] as Color 
          : Colors.grey;
      final iconData = classItem['icon'] is IconData
          ? classItem['icon'] as IconData
          : Icons.school;

      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    iconData,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        classSection,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Classmates (${classmates.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: classmates.isEmpty
                  ? const Center(
                      child: Text('No classmates found'),
                    )
                  : ListView.builder(
                      itemCount: classmates.length,
                      itemBuilder: (context, index) {
                        final classmate = classmates[index];
                        final mateName = classmate['name']?.toString() ?? 'Unknown';
                        final schoolName = classmate['schoolName']?.toString() ?? '';
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              mateName.isNotEmpty ? mateName.substring(0, 1).toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(mateName),
                          subtitle: schoolName.isNotEmpty 
                              ? Text(schoolName)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.message),
                            onPressed: () {
                              // Navigate to chat
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final totalConnections =
        _registeredSchools.length +
        _teachers.length +
        _classes.fold(0, (sum, c) => sum + ((c['classmates'] as List).length));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connection Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalConnections connections from Connect tab',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalConnections / 20,
                  backgroundColor: Colors.blue.shade100,
                  color: Colors.blue,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
