part of '../sign_in.dart';

// _AuthenticationScreenState: _buildPlatformHeader, _buildWelcomeMessage, _buildPlatformSpecificFields, _buildSignInFields, _buildSignUpFields, _buildPlatformSpecificSignUpFields, _buildKidlingSignUpFields
extension AuthenticationScreenStateSection01 on _AuthenticationScreenState {
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
}
