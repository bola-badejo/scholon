import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Screens/authentication/controllers/auth_controller.dart';
import 'package:isapp/Screens/policy/policy.dart';
import 'package:isapp/Screens/policy/terms.dart';
import 'package:flutter/gestures.dart';

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

  Widget _buildPlatformHeader() {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
          image: AssetImage(_platformImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            _platformColor.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _platformColor.withOpacity(0.8),
              _platformColor.withOpacity(0.2),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button and platform tag
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _platformName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Platform icon and name
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getPlatformIcon(),
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _platformName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    String welcomeMessage;
    String subtitle;

    switch (_selectedPlatform) {
      case 'kidling':
        welcomeMessage = "Welcome to Kidling!";
        subtitle = "Fun learning adventures for your little ones";
        break;
      case 'istudyapp':
        welcomeMessage = "Welcome to iStudyApp!";
        subtitle = "Sign in to continue your learning journey";
        break;
      case 'teachly':
        welcomeMessage = "Welcome to Teachly!";
        subtitle = "Join our community of educators";
        break;
      case 'automated_school':
        welcomeMessage = "Welcome to Automated School!";
        subtitle = "School management system login";
        break;
      case 'parents_portal':
        welcomeMessage = "Welcome to Parents Portal!";
        subtitle = "Track your child's progress and activities";
        break;
      default:
        welcomeMessage = "Welcome!";
        subtitle = "Sign in to continue";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          welcomeMessage,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  // UPDATED: Clean switching between auth modes
  Widget _buildPlatformSpecificFields() {
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _controller.authMode.value == AuthMode.signIn
            ? _buildSignInFields()
            : _buildSignUpFields(),
      );
    });
  }

  // SIGN IN FIELDS - Clean and minimal
  Widget _buildSignInFields() {
    return Column(
      key: const ValueKey('signInFields'),
      children: [
        // Email/Phone Field
        TextFormField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Email or Phone',
            hintText: 'Enter your email or phone number',
            prefixIcon: Icon(Icons.person, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            errorText: _controller.emailError.value.isNotEmpty
                ? _controller.emailError.value
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email or phone is required';
            }
            return null;
          },
          onChanged: (value) {
            // Clear error when user types
            if (_controller.emailError.value.isNotEmpty) {
              _controller.emailError.value = '';
            }
          },
        ),

        const SizedBox(height: 16),

        // Password Field
        Obx(
          () => TextFormField(
            controller: _controller.passwordController,
            obscureText: _controller.obscurePassword.value,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock, color: _platformColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscurePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: _platformColor,
                ),
                onPressed: _controller.togglePasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _platformColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
            validator: (value) => _controller.validatePassword(value),
          ),
        ),
        const SizedBox(height: 8),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.toNamed('/forgot-password'),
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: _platformColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // SIGN UP FIELDS - Platform specific
  Widget _buildSignUpFields() {
    return Column(
      key: const ValueKey('signUpFields'),
      children: [
        // Platform-specific fields
        _buildPlatformSpecificSignUpFields(),
        const SizedBox(height: 16),

        // Password fields
        Obx(
          () => TextFormField(
            controller: _controller.passwordController,
            obscureText: _controller.obscurePassword.value,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Create Password',
              prefixIcon: Icon(Icons.lock, color: _platformColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscurePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: _platformColor,
                ),
                onPressed: _controller.togglePasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _platformColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
            validator: (value) => _controller.validatePassword(value),
          ),
        ),
        const SizedBox(height: 16),

        Obx(
          () => TextFormField(
            controller: _controller.confirmPasswordController,
            obscureText: _controller.obscureConfirmPassword.value,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock, color: _platformColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscureConfirmPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: _platformColor,
                ),
                onPressed: _controller.toggleConfirmPasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _platformColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
            validator: (value) => _controller.validateConfirmPassword(value),
          ),
        ),
      ],
    );
  }

  // Platform-specific sign up fields
  Widget _buildPlatformSpecificSignUpFields() {
    switch (_selectedPlatform) {
      case 'kidling':
        return _buildKidlingSignUpFields();
      case 'istudyapp':
        return _buildStudentSignUpFields();
      case 'teachly':
        return _buildTeacherSignUpFields();
      case 'automated_school':
        return _buildSchoolSignUpFields();
      case 'parents_portal':
        return _buildParentSignUpFields();
      default:
        return _buildStudentSignUpFields();
    }
  }

  // KIDLING SIGN UP FIELDS
  Widget _buildKidlingSignUpFields() {
    return Column(
      children: [
        // Parent/Guardian Name
        TextFormField(
          controller: _controller.nameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Parent/Guardian Full Name *',
            hintText: 'Enter your full name',
            prefixIcon: Icon(Icons.person, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateName(value),
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Parent Email *',
            hintText: 'Enter your email address',
            prefixIcon: Icon(Icons.email, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateEmail(value),
        ),
        const SizedBox(height: 16),

        // Phone
        TextFormField(
          controller: _controller.phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: '09012345678',
            prefixIcon: Icon(Icons.phone, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validatePhoneNumber(value),
        ),
        const SizedBox(height: 16),

        // Child's Name
        TextFormField(
          controller: _controller.childNameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Child\'s Full Name *',
            hintText: 'Enter your child\'s full name',
            prefixIcon: Icon(Icons.child_care, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateChildName(value),
        ),
        const SizedBox(height: 16),

        // Child's Age and Gender Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller.childAgeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Child\'s Age *',
                  hintText: 'e.g., 4',
                  prefixIcon: Icon(Icons.cake, color: _platformColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _platformColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                validator: (value) => _controller.validateChildAge(value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildGenderDropdown()),
          ],
        ),
        const SizedBox(height: 16),

        // Learning Interests (Multiple Selection)
        _buildLearningInterestsDropdown(),
        const SizedBox(height: 16),

        // Preferred Learning Time
        _buildPreferredTimeDropdown(),
        const SizedBox(height: 16),

        // How did you hear about us?
        TextFormField(
          controller: _controller.referralSourceController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'How did you hear about Kidling?',
            hintText: 'e.g., Friend, Social Media, Search',
            prefixIcon: Icon(Icons.info_outline, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningInterestsDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<String>(
        value: _controller.selectedLearningInterest.value.isNotEmpty
            ? _controller.selectedLearningInterest.value
            : null,
        decoration: InputDecoration(
          labelText: 'Child\'s Learning Interests *',
          prefixIcon: Icon(Icons.star, color: _platformColor),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        items: [
          'Early Literacy & Reading',
          'Numbers & Counting',
          'Shapes & Colors',
          'Animals & Nature',
          'Music & Movement',
          'Arts & Creativity',
          'Problem Solving',
          'Social Skills',
        ].map((interest) {
          return DropdownMenuItem(
            value: interest,
            child: Text(interest),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _controller.selectedLearningInterest.value = value;
            _controller.learningInterestController.text = value;
          }
        },
        validator: (value) =>
            value == null ? 'Please select learning interest' : null,
        hint: const Text('Select primary interest'),
      ),
    );
  }

  Widget _buildPreferredTimeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<String>(
        value: _controller.preferredLearningTime.value.isNotEmpty
            ? _controller.preferredLearningTime.value
            : null,
        decoration: InputDecoration(
          labelText: 'Preferred Learning Time',
          prefixIcon: Icon(Icons.schedule, color: _platformColor),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        items: [
          'Morning (8am - 12pm)',
          'Afternoon (12pm - 4pm)',
          'Evening (4pm - 8pm)',
          'Weekends only',
          'Flexible',
        ].map((time) {
          return DropdownMenuItem(
            value: time,
            child: Text(time),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _controller.preferredLearningTime.value = value;
          }
        },
        hint: const Text('Select preferred time (optional)'),
      ),
    );
  }

  Widget _buildStudentSignUpFields() {
    return Column(
      children: [
        // Student Name
        TextFormField(
          controller: _controller.nameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Student Full Name *',
            hintText: 'Enter student full name',
            prefixIcon: Icon(Icons.person, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateName(value),
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Student/Parent Email *',
            hintText: 'Enter email address',
            prefixIcon: Icon(Icons.email, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateEmail(value),
        ),
        const SizedBox(height: 16),

        // Phone
        TextFormField(
          controller: _controller.phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: '09012345678',
            prefixIcon: Icon(Icons.phone, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validatePhoneNumber(value),
        ),
        const SizedBox(height: 16),

        // Parent Name
        TextFormField(
          controller: _controller.parentNameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Parent/Guardian Name *',
            hintText: 'Enter parent full name',
            prefixIcon: Icon(Icons.family_restroom, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateParentName(value),
        ),
        const SizedBox(height: 16),

        // School Name
        TextFormField(
          controller: _controller.schoolNameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'School Name *',
            hintText: 'Enter school name',
            prefixIcon: Icon(Icons.school, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateSchoolName(value),
        ),
        const SizedBox(height: 16),

        // Additional student fields
        Row(
          children: [
            Expanded(child: _buildGenderDropdown()),
            const SizedBox(width: 16),
            Expanded(child: _buildDateOfBirthField(context)),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildCategoryDropdown()),
            const SizedBox(width: 16),
            Expanded(child: _buildGradeDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildTeacherSignUpFields() {
    return Column(
      children: [
        // Teacher Name
        TextFormField(
          controller: _controller.nameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Teacher Full Name *',
            hintText: 'Enter teacher full name',
            prefixIcon: Icon(Icons.person, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateName(value),
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Teacher Email *',
            hintText: 'Enter email address',
            prefixIcon: Icon(Icons.email, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateEmail(value),
        ),
        const SizedBox(height: 16),

        // Phone
        TextFormField(
          controller: _controller.phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: '09012345678',
            prefixIcon: Icon(Icons.phone, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validatePhoneNumber(value),
        ),
        const SizedBox(height: 16),

        // Qualification
        TextFormField(
          controller: _controller.qualificationController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Highest Qualification *',
            hintText: 'e.g., B.Ed, M.Ed, PhD',
            prefixIcon: Icon(Icons.school, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateQualification(value),
        ),
        const SizedBox(height: 16),

        // Subject
        TextFormField(
          controller: _controller.subjectController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Subject Specialization *',
            hintText: 'e.g., Mathematics, English, Science',
            prefixIcon: Icon(Icons.subject, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateSubject(value),
        ),
        const SizedBox(height: 16),

        // Additional teacher fields
        Row(
          children: [
            Expanded(child: _buildGenderDropdown()),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _controller.experienceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Years Experience',
                  prefixIcon: Icon(Icons.work, color: _platformColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _platformColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                validator: (value) => _controller.validateExperience(value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSchoolSignUpFields() {
    return Column(
      children: [
        // **ADD THIS FIELD BACK - This is the main name field**
        TextFormField(
          controller: _controller.nameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Admin Full Name *',
            hintText: 'Enter admin full name',
            prefixIcon: Icon(Icons.person, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateName(value),
        ),
        const SizedBox(height: 16),

        // School Name
        TextFormField(
          controller: _controller.schoolNameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'School Name *',
            hintText: 'Enter school name',
            prefixIcon: Icon(Icons.business, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateSchoolName(value),
        ),
        const SizedBox(height: 16),

        // School Code
        TextFormField(
          controller: _controller.schoolCodeController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'School Code *',
            hintText: 'Enter school code',
            prefixIcon: Icon(Icons.code, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateSchoolCode(value),
        ),
        const SizedBox(height: 16),

        // Admin Name (Primary Contact) - keep this too
        TextFormField(
          controller: _controller.adminNameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Primary Contact Name',
            hintText: 'Enter primary contact name',
            prefixIcon: Icon(Icons.contact_mail, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateAdminName(
            value,
            isRequired: false,
          ), // Make optional
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'School Email *',
            hintText: 'Enter school email',
            prefixIcon: Icon(Icons.email, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateEmail(value),
        ),
        const SizedBox(height: 16),

        // Phone
        TextFormField(
          controller: _controller.phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'School Phone *',
            hintText: '09012345678',
            prefixIcon: Icon(Icons.phone, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validatePhoneNumber(value),
        ),
        const SizedBox(height: 16),

        // Address
        TextFormField(
          controller: _controller.adminAddressController,
          maxLines: 2,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'School Address *',
            hintText: 'Enter school address',
            prefixIcon: Icon(Icons.location_on, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateAddress(value),
        ),
      ],
    );
  }

  Widget _buildParentSignUpFields() {
    return Column(
      children: [
        // Parent Name
        TextFormField(
          controller: _controller.nameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Parent Full Name *',
            hintText: 'Enter parent full name',
            prefixIcon: Icon(Icons.person, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateName(value),
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Parent Email *',
            hintText: 'Enter email address',
            prefixIcon: Icon(Icons.email, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateEmail(value),
        ),
        const SizedBox(height: 16),

        // Phone
        TextFormField(
          controller: _controller.phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: '09012345678',
            prefixIcon: Icon(Icons.phone, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validatePhoneNumber(value),
        ),
        const SizedBox(height: 16),

        // Student Name
        TextFormField(
          controller: _controller.studentNameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Student Name *',
            hintText: 'Enter child\'s full name',
            prefixIcon: Icon(Icons.child_care, color: _platformColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _platformColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          validator: (value) => _controller.validateStudentName(value),
        ),
        const SizedBox(height: 16),

        // Additional parent fields
        Row(
          children: [
            Expanded(child: _buildGenderDropdown()),
            const SizedBox(width: 16),
            Expanded(child: _buildRelationshipDropdown()),
          ],
        ),
        const SizedBox(height: 16),

        // Student ID and Class
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller.studentIdController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Student ID *',
                  hintText: 'Child\'s student ID',
                  prefixIcon: Icon(Icons.school, color: _platformColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _platformColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                validator: (value) => _controller.validateStudentId(value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _controller.childClassController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Student Class',
                  hintText: 'e.g., Grade 5',
                  prefixIcon: Icon(Icons.class_, color: _platformColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _platformColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods for form fields
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _controller.selectedGender.value,
      decoration: InputDecoration(
        labelText: 'Gender *',
        prefixIcon: Icon(Icons.person, color: _platformColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _platformColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: ['Male', 'Female']
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
          .toList(),
      onChanged: (value) => _controller.selectedGender.value = value!,
      validator: (value) => value == null ? 'Please select gender' : null,
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return TextFormField(
      controller: _controller.dobController,
      readOnly: true,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Date of Birth *',
        hintText: 'Select date',
        prefixIcon: Icon(Icons.calendar_today, color: _platformColor),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_month, color: _platformColor),
          onPressed: () => _controller.selectDateOfBirth(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _platformColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
      validator: (value) => _controller.validateDOB(value),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _controller.selectedCategory.value,
      decoration: InputDecoration(
        labelText: 'Education Level *',
        prefixIcon: Icon(Icons.school, color: _platformColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _platformColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: [
        'Basic Education',
        'Senior Secondary Education',
      ].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
      onChanged: _controller.onCategoryChanged,
      validator: (value) =>
          value == null ? 'Please select education level' : null,
    );
  }

  Widget _buildGradeDropdown() {
    return DropdownButtonFormField<String>(
      value: _controller.selectedGrade.value,
      decoration: InputDecoration(
        labelText: 'Class Grade *',
        prefixIcon: Icon(Icons.grade, color: _platformColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _platformColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _controller.getAvailableGrades().map((grade) {
        return DropdownMenuItem(
          value: grade,
          child: Text(_controller.getGradeDisplayName(grade)),
        );
      }).toList(),
      onChanged: _controller.onGradeChanged,
      validator: (value) => value == null ? 'Please select class grade' : null,
    );
  }

  Widget _buildRelationshipDropdown() {
    return DropdownButtonFormField<String>(
      value: _controller.relationshipController.text.isNotEmpty
          ? _controller.relationshipController.text
          : 'Parent',
      decoration: InputDecoration(
        labelText: 'Relationship *',
        prefixIcon: Icon(Icons.family_restroom, color: _platformColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _platformColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: ['Parent', 'Guardian', 'Sibling', 'Other']
          .map(
            (relation) =>
                DropdownMenuItem(value: relation, child: Text(relation)),
          )
          .toList(),
      onChanged: (value) {
        _controller.relationshipController.text = value ?? 'Parent';
      },
      validator: (value) => value == null ? 'Please select relationship' : null,
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      height: 65,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [_platformColor, _platformColor.withOpacity(0.8)],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () => _controller.submitForm(),
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              _platformColor,
              _platformColor.withOpacity(0.8),
              _platformColor.withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _platformColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Obx(() {
          return Center(
            child: Text(
              _controller.authMode.value == AuthMode.signIn
                  ? "Continue to $_platformName"
                  : "Join $_platformName",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAuthModeSwitch() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _controller.authMode.value == AuthMode.signIn
                ? "Don't have an account?"
                : "Already have an account?",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              _controller.switchAuthMode();
              // Force rebuild to update form validation
              setState(() {});
            },
            child: Text(
              _controller.authMode.value == AuthMode.signIn
                  ? "Sign Up"
                  : "Sign In",
              style: TextStyle(
                color: _platformColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFooter() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            children: [
              const TextSpan(text: 'By continuing, you agree to our '),

              TextSpan(
                text: 'Terms',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsOfServicePage(),
                      ),
                    );
                  },
              ),

              const TextSpan(text: ' and '),

              TextSpan(
                text: 'Privacy Policy',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Text(
          "Secured by ${_platformName}",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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