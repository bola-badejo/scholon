import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/controllers/faculty_controller.dart';
import 'package:isapp/features/school/models/nigerian_class.dart';
import 'package:isapp/features/school/models/school_department.dart';
import 'package:isapp/features/school/models/school_user_profile.dart';
import 'package:isapp/features/school/screens/class_details_page.dart';
import 'package:isapp/features/school/widgets/add_parent_form.dart';
import 'package:isapp/features/school/widgets/add_student_form.dart';
import 'package:isapp/features/school/widgets/add_teacher_form.dart';
import 'package:isapp/features/school/widgets/edit_profile_form.dart';

export 'package:isapp/features/school/controllers/faculty_controller.dart';
export 'package:isapp/features/school/controllers/school_management_binding.dart';
export 'package:isapp/features/school/models/nigerian_class.dart';
export 'package:isapp/features/school/models/nigerian_position.dart';
export 'package:isapp/features/school/models/school_department.dart';
export 'package:isapp/features/school/models/school_user_profile.dart';
export 'package:isapp/features/school/models/school_user_result.dart';
export 'package:isapp/features/school/screens/class_details_page.dart';
export 'package:isapp/features/school/widgets/add_parent_form.dart';
export 'package:isapp/features/school/widgets/add_student_form.dart';
export 'package:isapp/features/school/widgets/add_teacher_form.dart';
export 'package:isapp/features/school/widgets/edit_profile_form.dart';

part 'faculty_sections/01_school_header.dart';
part 'faculty_sections/02_student_list.dart';
part 'faculty_sections/03_student_details.dart';

class FacultyPage extends StatefulWidget {
  const FacultyPage({super.key});

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FacultyController schoolController = Get.put(FacultyController());
  ConnectController? _connectController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    try {
      _connectController = Get.find<ConnectController>();
    } catch (e) {
      print('ConnectController not found: $e');
    }
  }

  void _onTabChanged() {
    schoolController.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Enhanced School Header
            SliverAppBar(
              expandedHeight: 300,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
              shadowColor: Colors.grey.withOpacity(0.3),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildSchoolHeader(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.deepPurple,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.deepPurple,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(
                            text: 'Staff',
                            icon: Icon(Icons.school_rounded, size: 20),
                          ),
                          Tab(
                            text: 'Students',
                            icon: Icon(Icons.people_rounded, size: 20),
                          ),
                          Tab(
                            text: 'Parents',
                            icon: Icon(Icons.family_restroom_rounded, size: 20),
                          ),
                          Tab(
                            text: 'Classes',
                            icon: Icon(Icons.class_rounded, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Add User Button
                IconButton(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                  tooltip: 'Add User to School',
                ),
                // Announcement Button
                IconButton(
                  onPressed: _showAnnouncementDialog,
                  icon: const Icon(
                    Icons.announcement_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  tooltip: 'Send Announcement',
                ),
              ],
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStaffTab(),
            _buildStudentsTab(),
            _buildParentsTab(),
            _buildClassesTab(),
          ],
        ),
      ),
    );
  }

  // ========== SEARCH SECTIONS ==========

  // ========== FILTER SECTIONS ==========

  // ========== LISTS ==========

  // ========== DIALOGS ==========

  void _editStaffProfile(SchoolUserProfile staff) {
    Get.to(() => EditProfileForm(profile: staff));
  }

  Color _getRoleColor(UserType role) {
  switch (role) {
    case UserType.teacher:
      return Colors.blue;
    case UserType.student:
      return Colors.purple;
    case UserType.parent:
      return Colors.deepOrange;
    case UserType.schoolAdmin:
      return Colors.teal;
    case UserType.kidling:
      return Colors.red;
  }
}

  IconData _getRoleIcon(UserType role) {
  switch (role) {
    case UserType.teacher:
      return Icons.school_rounded;
    case UserType.student:
      return Icons.person_rounded;
    case UserType.parent:
      return Icons.family_restroom_rounded;
    case UserType.schoolAdmin:
      return Icons.admin_panel_settings_rounded;
    case UserType.kidling:
      return Icons.child_care_rounded;
  }
}

  String _getRoleDescription(UserType role) {
  switch (role) {
    case UserType.teacher:
      return 'Teach subjects, assign grades, manage classes';
    case UserType.student:
      return 'Attend classes, submit assignments, participate';
    case UserType.parent:
      return 'Monitor child progress, receive updates';
    case UserType.schoolAdmin:
      return 'Manage school operations, users, and settings';
    case UserType.kidling:
      return 'Fun learning adventures for early childhood education';
  }
}

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _StaffProfileCard extends StatelessWidget {
  final SchoolUserProfile profile;
  final VoidCallback onTap;

  const _StaffProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (profile.teacherDepartment?.color ?? Colors.blue)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: profile.teacherDepartment?.color ?? Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.staffPosition != null)
                      Text(
                        profile.staffPosition!.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (profile.teacherDepartment != null)
                      Text(
                        profile.teacherDepartment!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: profile.teacherDepartment!.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              // Action
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentProfileCard extends StatelessWidget {
  final SchoolUserProfile profile;
  final VoidCallback onTap;

  const _StudentProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (profile.studentClass?.color ?? Colors.purple)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: profile.studentClass?.color ?? Colors.purple,
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
                      profile.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.studentClass != null)
                      Text(
                        profile.studentClass!.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: profile.studentClass!.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (profile.studentId != null)
                      Text(
                        'ID: ${profile.studentId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              // Leadership badges
              if (profile.isClassCaptain || profile.isPrefect) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.isClassCaptain ? 'Captain' : 'Prefect',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentProfileCard extends StatelessWidget {
  final SchoolUserProfile profile;
  final VoidCallback onTap;

  const _ParentProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.userName.substring(0, 1).toUpperCase(),
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
                      profile.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.childrenNames.isNotEmpty)
                      Text(
                        '${profile.childrenNames.length} children',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.deepOrange,
                        ),
                      ),
                    if (profile.relationshipToChild != null)
                      Text(
                        profile.relationshipToChild!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final NigerianClass studentClass;
  final VoidCallback onTap;

  const _ClassCard({required this.studentClass, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: studentClass.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: studentClass.color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(studentClass.icon, color: studentClass.color, size: 32),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: studentClass.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      studentClass.level.substring(0, 1),
                      style: TextStyle(
                        fontSize: 11,
                        color: studentClass.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                studentClass.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                studentClass.level,
                style: TextStyle(
                  fontSize: 13,
                  color: studentClass.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 14,
                    color: studentClass.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '24 Students', // You would get this from stats
                    style: TextStyle(fontSize: 12, color: studentClass.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectUserCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onSelect;

  const _ConnectUserCard({required this.user, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final color = _getUserColor(user);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
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
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.userType.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user is StudentUser)
                    Text(
                      (user as StudentUser).schoolName ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUserColor(BaseUser user) {
    switch (user.userType) {
      case UserType.teacher:
        return Colors.blue;
      case UserType.kidling:
        return Colors.red;
      case UserType.student:
        return Colors.purple;
      case UserType.parent:
        return Colors.deepOrange;
      case UserType.schoolAdmin:
        return Colors.teal;
    }
  }
}

// ========== STAT ITEM WIDGET ==========
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Icon(icon, color: color, size: 10)),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
