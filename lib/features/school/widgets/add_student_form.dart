import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/controllers/faculty_controller.dart';
import 'package:isapp/features/school/models/nigerian_class.dart';

class AddStudentForm extends StatefulWidget {
  final BaseUser user;

  const AddStudentForm({super.key, required this.user});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final FacultyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController studentIdController = TextEditingController();
  final Rx<NigerianClass?> selectedClass = Rx(null);
  final RxString selectedGender = RxString('male');
  final TextEditingController dateOfBirthController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.user.name} as Student'),
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
              _buildUserInfoCard(),
              const SizedBox(height: 32),
              // Student Details
              _buildFormSection(
                title: 'Student Details',
                children: [
                  TextFormField(
                    controller: studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Class Selection
                  _buildClassSelection(),
                  const SizedBox(height: 16),
                  // Gender Selection
                  _buildGenderSelection(),
                  const SizedBox(height: 16),
                  // Date of Birth
                  TextFormField(
                    controller: dateOfBirthController,
                    readOnly: true,
                    onTap: () => _selectDateOfBirth(),
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () => _selectDateOfBirth(),
                        icon: const Icon(Icons.calendar_today_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
                  child: const Text('Add Student'),
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
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
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

  Widget _buildClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        // Primary Classes
        const Text('Primary', style: TextStyle(fontSize: 14)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NigerianClass.primaryClasses.map((grade) {
            return Obx(() {
              final selected = selectedClass.value == grade;
              return ChoiceChip(
                label: Text(grade.displayName),
                selected: selected,
                onSelected: (_) => selectedClass.value = grade,
                backgroundColor: grade.color.withOpacity(0.1),
                selectedColor: grade.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : grade.color,
                ),
              );
            });
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Junior Secondary
        const Text('Junior Secondary', style: TextStyle(fontSize: 14)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NigerianClass.juniorSecondaryClasses.map((grade) {
            return Obx(() {
              final selected = selectedClass.value == grade;
              return ChoiceChip(
                label: Text(grade.displayName),
                selected: selected,
                onSelected: (_) => selectedClass.value = grade,
                backgroundColor: grade.color.withOpacity(0.1),
                selectedColor: grade.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : grade.color,
                ),
              );
            });
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Senior Secondary
        const Text('Senior Secondary', style: TextStyle(fontSize: 14)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NigerianClass.seniorSecondaryClasses.map((grade) {
            return Obx(() {
              final selected = selectedClass.value == grade;
              return ChoiceChip(
                label: Text(grade.displayName),
                selected: selected,
                onSelected: (_) => selectedClass.value = grade,
                backgroundColor: grade.color.withOpacity(0.1),
                selectedColor: grade.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : grade.color,
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => RadioListTile(
                  title: const Text('Male'),
                  value: 'male',
                  groupValue: selectedGender.value,
                  onChanged: (value) => selectedGender.value = value!,
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => RadioListTile(
                  title: const Text('Female'),
                  value: 'female',
                  groupValue: selectedGender.value,
                  onChanged: (value) => selectedGender.value = value!,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dateOfBirthController.text =
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedClass.value != null) {
      final result = await controller.addUserToSchool(
        userId: widget.user.uid,
        userType: UserType.student,
        studentClass: selectedClass.value,
        studentId: studentIdController.text,
      );

      if (result.success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Student added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result.error ?? 'Failed to add student',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
