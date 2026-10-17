import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/controllers/faculty_controller.dart';

class AddParentForm extends StatefulWidget {
  final BaseUser user;

  const AddParentForm({super.key, required this.user});

  @override
  State<AddParentForm> createState() => _AddParentFormState();
}

class _AddParentFormState extends State<AddParentForm> {
  final FacultyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController parentIdController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();
  final RxList<String> selectedChildren = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.user.name} as Parent'),
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
              // Parent Details
              _buildFormSection(
                title: 'Parent Details',
                children: [
                  TextFormField(
                    controller: parentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Parent ID (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: relationshipController,
                    decoration: const InputDecoration(
                      labelText: 'Relationship to Child',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Father, Mother, Guardian',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Children Selection
                  _buildChildrenSelection(),
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
                  child: const Text('Add Parent'),
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
        color: Colors.deepOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
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

  Widget _buildChildrenSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link Children',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final students = controller.schoolStudents;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: students.map((student) {
              final selected = selectedChildren.contains(student.id);
              return FilterChip(
                label: Text(student.userName),
                selected: selected,
                onSelected: (value) {
                  if (value) {
                    selectedChildren.add(student.id);
                  } else {
                    selectedChildren.remove(student.id);
                  }
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.deepOrange,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final childrenNames = controller.schoolStudents
          .where((student) => selectedChildren.contains(student.id))
          .map((student) => student.userName)
          .toList();

      final result = await controller.addUserToSchool(
        userId: widget.user.uid,
        userType: UserType.parent,
        parentGuardianId: parentIdController.text.isEmpty
            ? null
            : parentIdController.text,
        additionalInfo: {
          'relationship': relationshipController.text,
          'childrenNames': childrenNames,
        },
      );

      if (result.success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Parent added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result.error ?? 'Failed to add parent',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
