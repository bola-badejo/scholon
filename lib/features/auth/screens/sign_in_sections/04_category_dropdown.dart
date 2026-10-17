part of '../sign_in.dart';

// _AuthenticationScreenState: _buildCategoryDropdown, _buildGradeDropdown, _buildRelationshipDropdown, _buildLoadingButton, _buildSubmitButton, _buildAuthModeSwitch, _buildFooter
extension AuthenticationScreenStateSection04 on _AuthenticationScreenState {
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
}
