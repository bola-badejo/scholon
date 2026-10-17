import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/controllers/faculty_controller.dart';
import 'package:isapp/features/school/models/school_user_profile.dart';

class EditProfileForm extends StatefulWidget {
  final SchoolUserProfile profile;

  const EditProfileForm({super.key, required this.profile});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final FacultyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: () {
              // Save changes
            },
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Form fields based on user type
              if (widget.profile.isTeacher) _buildTeacherForm(),
              if (widget.profile.isStudent) _buildStudentForm(),
              if (widget.profile.isParent) _buildParentForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherForm() {
    return Column(
      children: [
        // Teacher-specific fields
      ],
    );
  }

  Widget _buildStudentForm() {
    return Column(
      children: [
        // Student-specific fields
      ],
    );
  }

  Widget _buildParentForm() {
    return Column(
      children: [
        // Parent-specific fields
      ],
    );
  }
}
