part of '../sign_in.dart';

// _AuthenticationScreenState: _buildLearningInterestsDropdown, _buildPreferredTimeDropdown, _buildStudentSignUpFields, _buildTeacherSignUpFields
extension AuthenticationScreenStateSection02 on _AuthenticationScreenState {
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
}
