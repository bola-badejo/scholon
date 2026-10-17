import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/controllers/faculty_controller.dart';
import 'package:isapp/features/school/models/nigerian_position.dart';
import 'package:isapp/features/school/models/school_department.dart';

class AddTeacherForm extends StatefulWidget {
  final BaseUser user;

  const AddTeacherForm({super.key, required this.user});

  @override
  State<AddTeacherForm> createState() => _AddTeacherFormState();
}

class _AddTeacherFormState extends State<AddTeacherForm> {
  final FacultyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController employeeIdController = TextEditingController();
  final Rx<SchoolDepartment?> selectedDepartment = Rx(null);
  final Rx<NigerianPosition?> selectedPosition = Rx(
    NigerianPosition.subjectTeacher,
  );
  final RxList<String> selectedSubjects = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.user.name} as Teacher'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              _buildUserInfoCard(),
              const SizedBox(height: 32),
              // Teacher Details
              _buildFormSection(
                title: 'Teacher Details',
                children: [
                  TextFormField(
                    controller: employeeIdController,
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Department Selection
                  _buildDepartmentSelection(),
                  const SizedBox(height: 16),
                  // Position Selection
                  _buildPositionSelection(),
                  const SizedBox(height: 16),
                  // Subjects
                  _buildSubjectsSelection(),
                ],
              ),
              const SizedBox(height: 40),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Teacher'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildDepartmentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Department', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SchoolDepartment.values.map((dept) {
            return Obx(() {
              final selected = selectedDepartment.value == dept;
              return ChoiceChip(
                label: Text(dept.name),
                selected: selected,
                onSelected: (_) => selectedDepartment.value = dept,
                backgroundColor: dept.color.withOpacity(0.1),
                selectedColor: dept.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : dept.color,
                ),
                avatar: Icon(dept.icon, size: 16),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPositionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Position', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NigerianPosition.values.map((position) {
            return Obx(() {
              final selected = selectedPosition.value == position;
              return ChoiceChip(
                label: Text(position.title),
                selected: selected,
                onSelected: (_) => selectedPosition.value = position,
                backgroundColor: Colors.blue.withOpacity(0.1),
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.blue,
                ),
                avatar: Icon(position.icon, size: 16),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectsSelection() {
    final subjects = [
      'Mathematics',
      'English',
      'Physics',
      'Chemistry',
      'Biology',
      'Economics',
      'Geography',
      'History',
      'Government',
      'Literature',
      'French',
      'Arabic',
      'Fine Arts',
      'Music',
      'Home Economics',
      'Agricultural Science',
      'Technical Drawing',
      'Computer Studies',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subjects', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects.map((subject) {
              final selected = selectedSubjects.contains(subject);
              return FilterChip(
                label: Text(subject),
                selected: selected,
                onSelected: (value) {
                  if (value) {
                    selectedSubjects.add(subject);
                  } else {
                    selectedSubjects.remove(subject);
                  }
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.green,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedDepartment.value != null) {
      final result = await controller.addUserToSchool(
        userId: widget.user.uid,
        userType: UserType.teacher,
        department: selectedDepartment.value,
        position: selectedPosition.value,
        employeeId: employeeIdController.text,
        assignedSubjects: selectedSubjects.toList(),
      );

      if (result.success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Teacher added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result.error ?? 'Failed to add teacher',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
