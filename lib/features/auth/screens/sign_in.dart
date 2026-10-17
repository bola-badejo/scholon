import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/auth/controllers/auth_controller.dart';
import 'package:isapp/features/policy/screens/policy.dart';
import 'package:isapp/features/policy/screens/terms.dart';
import 'package:flutter/gestures.dart';

part 'sign_in_sections/01_platform_header.dart';
part 'sign_in_sections/02_learning_interests_dropdown.dart';
part 'sign_in_sections/03_school_sign_up_fields.dart';
part 'sign_in_sections/04_category_dropdown.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  late String _selectedPlatform;
  late String _platformName;
  late Color _platformColor;
  late String _platformImage;
  late AuthenticationController _controller;

  @override
  void initState() {
    super.initState();

    // Get platform data from arguments
    final args = Get.arguments ?? {};
    _selectedPlatform = args['platform'] ?? 'istudyapp';
    _platformName = args['platformName'] ?? 'iStudyApp';
    _platformColor = args['platformColor'] != null
        ? Color(args['platformColor'])
        : Colors.blue;
    _platformImage = args['platformImage'] ?? 'assets/platforms/istudyapp.png';

    // Initialize controller
    _initializeController();
  }

  void _initializeController() {
    // Check if controller already exists for this platform
    if (Get.isRegistered<AuthenticationController>(tag: _selectedPlatform)) {
      _controller = Get.find<AuthenticationController>(tag: _selectedPlatform);
      // Reset form for fresh authentication
      _controller.resetAll();
      _controller.selectedPlatform = _selectedPlatform;
    } else {
      // Create new controller with tag
      _controller = Get.put(
        AuthenticationController(),
        tag: _selectedPlatform,
        permanent: false,
      );
      _controller.selectedPlatform = _selectedPlatform;
    }
  }

  @override
  void dispose() {
    // Clean up controller if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Platform Header with Image
            _buildPlatformHeader(),

            // Authentication form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 33),
              child: Form(
                key: _controller.formKey,
                child: Column(
                  children: [
                    // Show platform-specific welcome message
                    _buildWelcomeMessage(),
                    const SizedBox(height: 25),

                    // Dynamic form fields based on platform with clean switching
                    _buildPlatformSpecificFields(),

                    const SizedBox(height: 30),

                    // Submit Button
                    Obx(
                      () => _controller.isSubmitting.value
                          ? _buildLoadingButton()
                          : _buildSubmitButton(),
                    ),

                    const SizedBox(height: 25),

                    // Switch Auth Mode
                    _buildAuthModeSwitch(),

                    const SizedBox(height: 20),

                    // Terms and Security
                    _buildFooter(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon() {
    switch (_selectedPlatform) {
      case 'kidling':
        return Icons.child_care;
      case 'istudyapp':
        return Icons.school;
      case 'teachly':
        return Icons.people;
      case 'automated_school':
        return Icons.business;
      case 'parents_portal':
        return Icons.family_restroom;
      default:
        return Icons.school;
    }
  }
}