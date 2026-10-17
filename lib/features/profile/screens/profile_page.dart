import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/profile/screens/edit_profile_page.dart';
import 'package:isapp/features/affairs/screens/affairs_page.dart';
import 'package:isapp/features/affairs/controllers/affairs_controller.dart';
import 'package:isapp/features/auth/screens/change_password.dart';
import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/policy/screens/about_app.dart';

part 'profile_page_sections/01_student_sections.dart';
part 'profile_page_sections/02_kidling_activities_section.dart';

class UniversalProfileScreen extends StatelessWidget {
  UniversalProfileScreen({super.key});

  final AuthService authService = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthService>(
      builder: (authController) {
        final user = authController.currentUser.value;
        if (user == null) return _buildEmptyState();

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Get.to(() => EditProfileScreen(user: user)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 28),

                // ───────────────────────── DYNAMIC SECTIONS BASED ON USER TYPE ─────────────────────────
                if (user is StudentUser) ..._buildStudentSections(user),
                if (user is TeacherUser) ..._buildTeacherSections(user),
                if (user is SchoolAdminUser) ..._buildSchoolAdminSections(user),
                if (user is ParentUser) ..._buildParentSections(user),

                _sectionTitle('Account Information'),
                _softCard(_buildAccountSection(user)),
                const SizedBox(height: 28),

                _sectionTitle('Platform & Subscription'),
                _softCard(_buildPlatformSection(user)),
                const SizedBox(height: 28),

                _sectionTitle('Settings'),
                _softCard(_buildSettingsSection()),
                const SizedBox(height: 24),

                _buildAboutButton(),
                const SizedBox(height: 12),
                _buildSignOutButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── STUDENT SECTIONS ─────────────────────────

  Widget _courseTile(String courseName, double progress) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.blue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.blue.shade200,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── TEACHER SECTIONS ─────────────────────────

  Widget _resourceTile(String resourceName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              resourceName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── SCHOOL ADMIN SECTIONS ─────────────────────────

  // ───────────────────────── PARENT SECTIONS ─────────────────────────

  // ───────────────────────── KIDLING PARENT SECTIONS ─────────────────────────

  Widget _kidlingStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _childTile(String childId) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.child_care_rounded, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Child Name', // You'll need to fetch actual child name
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Student ID: $childId',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── HELPER WIDGETS ─────────────────────────

  Widget _schoolInfoTile(String schoolName, String type, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.shade100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.purple, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schoolName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyStateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(actionText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _elevatedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlinedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewAllButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── NAVIGATION ─────────────────────────

  void _navigateToAffairs(Map<String, dynamic> schoolData) async {
    try {
      // Check if AffairsController is already initialized
      final AffairsController affairsController;
      
      if (Get.isRegistered<AffairsController>()) {
        affairsController = Get.find<AffairsController>();
      } else {
        affairsController = Get.put(AffairsController());
      }

      // Set the school data in the controller before navigation
      final schoolId = schoolData['schoolCode']?.toString() ?? 
                       schoolData['schoolId']?.toString() ?? 
                       schoolData['id']?.toString() ?? '';
      final schoolName = schoolData['schoolName']?.toString() ?? 
                         schoolData['name']?.toString() ?? '';
      
      if (schoolId.isNotEmpty) {
        affairsController.schoolId.value = schoolId;
        affairsController.schoolName.value = schoolName;
        
        // Wait for controller to initialize
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Navigate to AffairsMainScreen
      await Get.to(() => AffairsMainScreen());
      
    } catch (e) {
      print('Error navigating to affairs: $e');
      Get.snackbar(
        'Error',
        'Could not open affairs: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ───────────────────────── ACCOUNT SECTION ─────────────────────────

  String _getKidlingPlanName(Subscription subscription) {
    if (subscription is KidlingSubscription) {
      switch (subscription.kidlingPlan) {
        case KidlingPlan.free:
          return 'Free';
        case KidlingPlan.premium:
          return 'Premium';
        case KidlingPlan.family:
          return 'Family';
      }
    }
    return 'Kidling';
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _divider() =>
      Divider(height: 24, thickness: 0.6, color: Colors.grey.shade200);

  Color _getUserColor(dynamic user) {
    if (user is StudentUser) return Colors.blue;
    if (user is TeacherUser) return Colors.green;
    if (user is SchoolAdminUser) return Colors.purple;
    if (user is ParentUser) {
      if (user.platform == Platform.kidling) return Colors.pink;
      return Colors.orange;
    }
    return Colors.grey;
  }

  IconData _getUserIcon(dynamic user) {
    if (user is StudentUser) return Icons.school;
    if (user is TeacherUser) return Icons.people;
    if (user is SchoolAdminUser) return Icons.business;
    if (user is ParentUser) {
      if (user.platform == Platform.kidling) return Icons.child_care;
      return Icons.family_restroom;
    }
    return Icons.person;
  }

  String _getUserTypeString(dynamic user) {
    if (user is StudentUser) return 'Student';
    if (user is TeacherUser) return 'Teacher';
    if (user is SchoolAdminUser) return 'School Administrator';
    if (user is ParentUser) {
      if (user.platform == Platform.kidling) return 'Kidling Parent';
      return 'Parent';
    }
    return 'User';
  }

  String _getPlatformName(Platform platform) {
    switch (platform) {
      case Platform.istudyapp:
        return 'iStudyApp';
      case Platform.teachly:
        return 'Teachly';
      case Platform.automatedSchool:
        return 'Automated School';
      case Platform.parentsPortal:
        return 'Parents Portal';
      case Platform.kidling:
        return 'Kidling';
    }
  }

  IconData _getPlatformIcon(Platform platform) {
    switch (platform) {
      case Platform.istudyapp:
        return Icons.school;
      case Platform.teachly:
        return Icons.people;
      case Platform.automatedSchool:
        return Icons.business;
      case Platform.parentsPortal:
        return Icons.family_restroom;
      case Platform.kidling:
        return Icons.child_care;
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _softCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}