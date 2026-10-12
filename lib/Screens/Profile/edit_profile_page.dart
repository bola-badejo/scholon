import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final dynamic user;
  
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.address ?? '');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              _buildProfilePicture(),
              const SizedBox(height: 30),
              
              // Basic Information
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 30),
              
              // Platform-specific fields
              _buildPlatformSpecificFields(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfilePicture() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!, width: 3),
          ),
          child: widget.user.profileImageUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.profileImageUrl!),
                  radius: 60,
                )
              : Icon(
                  _getUserIcon(widget.user),
                  size: 50,
                  color: Colors.grey[600],
                ),
        ),
        const SizedBox(height: 15),
        TextButton.icon(
          onPressed: _changeProfilePicture,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Change Profile Picture'),
        ),
      ],
    );
  }
  
  Widget _buildPlatformSpecificFields() {
    if (widget.user is StudentUser) {
      return _buildStudentFields(widget.user as StudentUser);
    } else if (widget.user is TeacherUser) {
      return _buildTeacherFields(widget.user as TeacherUser);
    } else if (widget.user is SchoolAdminUser) {
      return _buildSchoolAdminFields(widget.user as SchoolAdminUser);
    } else if (widget.user is ParentUser) {
      return _buildParentFields(widget.user as ParentUser);
    }
    return const SizedBox();
  }
  
  Widget _buildStudentFields(StudentUser user) {
    final parentNameController = TextEditingController(text: user.parentName);
    final schoolNameController = TextEditingController(text: user.schoolName);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        
        TextFormField(
          controller: parentNameController,
          decoration: const InputDecoration(
            labelText: 'Parent/Guardian Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.family_restroom),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: schoolNameController,
          decoration: const InputDecoration(
            labelText: 'School Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.school),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTeacherFields(TeacherUser user) {
    final qualificationController = TextEditingController(text: user.qualification);
    final subjectController = TextEditingController(text: user.subjectSpecialization);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Teacher Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        
        TextFormField(
          controller: qualificationController,
          decoration: const InputDecoration(
            labelText: 'Qualification',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.school),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: subjectController,
          decoration: const InputDecoration(
            labelText: 'Subject Specialization',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.subject),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSchoolAdminFields(SchoolAdminUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        
        Text(
          'School: ${user.schoolName}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        Text(
          'Admin Position: ${user.adminPosition}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
  
  Widget _buildParentFields(ParentUser user) {
    final studentNameController = TextEditingController(text: user.studentName);
    final relationshipController = TextEditingController(text: user.relationship);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parent Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        
        TextFormField(
          controller: relationshipController,
          decoration: const InputDecoration(
            labelText: 'Relationship to Student',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.family_restroom),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: studentNameController,
          decoration: const InputDecoration(
            labelText: 'Student Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.child_care),
          ),
        ),
      ],
    );
  }
  
  IconData _getUserIcon(dynamic user) {
    if (user is StudentUser) return Icons.school;
    if (user is TeacherUser) return Icons.people;
    if (user is SchoolAdminUser) return Icons.business;
    if (user is ParentUser) return Icons.family_restroom;
    return Icons.person;
  }
  
  void _changeProfilePicture() {
    Get.snackbar(
      'Coming Soon',
      'Profile picture upload feature will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update user profile logic here
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}