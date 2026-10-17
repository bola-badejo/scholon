part of '../sign_in.dart';

// _AuthenticationScreenState: _buildSchoolSignUpFields, _buildParentSignUpFields, _buildGenderDropdown, _buildDateOfBirthField
extension AuthenticationScreenStateSection03 on _AuthenticationScreenState {
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
}
