import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Models/user.dart';
import 'package:isapp/Screens/Profile/edit_profile_page.dart';
import 'package:isapp/Screens/affairs/affairs_page.dart';
import 'package:isapp/Screens/affairs/controller/affairs_controller.dart';
import 'package:isapp/Screens/authentication/change_password.dart';
import 'package:isapp/Screens/authentication/controllers/authentication_controller.dart';
import 'package:isapp/Screens/policy/about_app.dart';

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

  List<Widget> _buildStudentSections(StudentUser user) {
    return [
      _sectionTitle('My Classes'),
      _softCard(_buildStudentClassesSection(user)),
      const SizedBox(height: 28),

      _sectionTitle('My School'),
      _softCard(_buildStudentSchoolSection(user)),
      const SizedBox(height: 28),
    ];
  }

  Widget _buildStudentClassesSection(StudentUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.enrolledCourses.isNotEmpty)
          ...user.enrolledCourses.take(3).map((course) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _courseTile(course, user.courseProgress[course] ?? 0),
              ))
        else
          _emptyStateCard(
            icon: Icons.class_rounded,
            title: 'No Classes',
            subtitle: 'You haven\'t enrolled in any classes yet',
            actionText: 'Explore Classes',
            onAction: () {
              // Navigate to classes page
            },
          ),
        if (user.enrolledCourses.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _viewAllButton('View all ${user.enrolledCourses.length} classes', () {}),
          ),
      ],
    );
  }

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

  Widget _buildStudentSchoolSection(StudentUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.schoolName != null && user.schoolName!.isNotEmpty)
          _schoolInfoTile(user.schoolName!, 'School', Icons.school_rounded)
        else
          _emptyStateCard(
            icon: Icons.school_rounded,
            title: 'No School',
            subtitle: 'You\'re not enrolled in a school',
            actionText: 'Join School',
            onAction: () {
              // Navigate to school join page
            },
          ),
        const SizedBox(height: 12),
        if (user.classGrade != null)
          _infoRow('Class Grade', 'Grade ${user.classGrade}'),
        if (user.educationCategory != null)
          _infoRow('Education Category', user.educationCategory!),
      ],
    );
  }

  // ───────────────────────── TEACHER SECTIONS ─────────────────────────

  List<Widget> _buildTeacherSections(TeacherUser user) {
    return [
      _sectionTitle('My School'),
      _softCard(_buildTeacherSchoolSection(user)),
      const SizedBox(height: 28),

      if (user.createdResources.isNotEmpty)
        _sectionTitle('My Resources'),
      if (user.createdResources.isNotEmpty)
        _softCard(_buildTeacherResourcesSection(user)),
      if (user.createdResources.isNotEmpty) const SizedBox(height: 28),
    ];
  }

  Widget _buildTeacherSchoolSection(TeacherUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.schoolName != null && user.schoolName!.isNotEmpty)
          _schoolInfoTile(user.schoolName!, 'School', Icons.business_rounded)
        else
          _emptyStateCard(
            icon: Icons.school_rounded,
            title: 'No School',
            subtitle: 'You\'re not associated with any school',
            actionText: 'Join School',
            onAction: () {
              // Navigate to school join page
            },
          ),
        const SizedBox(height: 12),
        if (user.subjectSpecialization != null)
          _infoRow('Subject Specialization', user.subjectSpecialization!),
        if (user.qualification != null)
          _infoRow('Qualification', user.qualification!),
        if (user.yearsOfExperience != null)
          _infoRow('Experience', user.yearsOfExperience!),
        const SizedBox(height: 16),
        _elevatedButton(
          text: 'School Affairs',
          icon: Icons.newspaper_rounded,
          onPressed: () {
            if (user.schoolName != null && user.schoolName!.isNotEmpty) {
              _navigateToAffairs({
                'schoolName': user.schoolName!,
                'schoolId': user.teacherId ?? '',
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTeacherResourcesSection(TeacherUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...user.createdResources.take(3).map((resource) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _resourceTile(resource),
            )),
        if (user.createdResources.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _viewAllButton('View all ${user.createdResources.length} resources', () {}),
          ),
      ],
    );
  }

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

  List<Widget> _buildSchoolAdminSections(SchoolAdminUser user) {
    return [
      _sectionTitle('My School'),
      _softCard(_buildSchoolAdminSchoolSection(user)),
      const SizedBox(height: 28),

      _sectionTitle('School Stats'),
      _softCard(_buildSchoolStatsSection(user)),
      const SizedBox(height: 28),
    ];
  }

  Widget _buildSchoolAdminSchoolSection(SchoolAdminUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.schoolName != null && user.schoolName!.isNotEmpty)
          _schoolInfoTile(user.schoolName!, 'School', Icons.business_rounded)
        else
          _emptyStateCard(
            icon: Icons.business_rounded,
            title: 'No School',
            subtitle: 'You\'re not managing any school',
            actionText: 'Create School',
            onAction: () {
              // Navigate to school creation
            },
          ),
        const SizedBox(height: 12),
        if (user.schoolCode != null) _infoRow('School Code', user.schoolCode!),
        if (user.adminPosition != null) _infoRow('Position', user.adminPosition!),
        if (user.schoolAddress != null) _infoRow('Address', user.schoolAddress!),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _elevatedButton(
                text: 'School Affairs',
                icon: Icons.newspaper_rounded,
                onPressed: () {
                  if (user.schoolName != null && user.schoolName!.isNotEmpty) {
                    _navigateToAffairs({
                      'schoolName': user.schoolName!,
                      'schoolCode': user.schoolCode ?? '',
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _outlinedButton(
                text: 'Manage',
                icon: Icons.settings_rounded,
                onPressed: () {
                  // Navigate to school management
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSchoolStatsSection(SchoolAdminUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              value: user.totalStudents.toString(),
              label: 'Students',
              icon: Icons.people_rounded,
              color: Colors.blue,
            ),
            _statItem(
              value: user.totalTeachers.toString(),
              label: 'Teachers',
              icon: Icons.school_rounded,
              color: Colors.green,
            ),
            _statItem(
              value: user.totalClasses.toString(),
              label: 'Classes',
              icon: Icons.class_rounded,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _infoRow('Capacity Utilization', '${user.schoolCapacityUtilization.toStringAsFixed(1)}%'),
      ],
    );
  }

  // ───────────────────────── PARENT SECTIONS ─────────────────────────

  List<Widget> _buildParentSections(ParentUser user) {
    // Check if this is a Kidling parent using the platform
    if (user.platform == Platform.kidling) {
      return _buildKidlingParentSections(user);
    }
    
    // Regular parent sections
    final sections = <Widget>[];
    
    if (user.children.isNotEmpty) {
      sections.add(_sectionTitle('My Children'));
      sections.add(_softCard(_buildChildrenSection(user)));
      sections.add(const SizedBox(height: 28));
    }

    sections.add(_sectionTitle('School Information'));
    sections.add(_softCard(_buildParentSchoolSection(user)));
    sections.add(const SizedBox(height: 28));
    
    return sections;
  }

  // ───────────────────────── KIDLING PARENT SECTIONS ─────────────────────────

  List<Widget> _buildKidlingParentSections(ParentUser user) {
    final subscription = user.kidlingSubscription;
    final isPremium = subscription?.kidlingPlan != KidlingPlan.free;
    final dailyLimit = subscription?.dailyActivityLimit ?? 3;
    
    return [
      _sectionTitle('My Little Learner'),
      _softCard(_buildKidlingChildSection(user)),
      const SizedBox(height: 28),

      _sectionTitle('Learning Progress'),
      _softCard(_buildKidlingProgressSection(user, isPremium: isPremium, dailyLimit: dailyLimit)),
      const SizedBox(height: 28),

      _sectionTitle('Favorite Activities'),
      _softCard(_buildKidlingActivitiesSection(user)),
      const SizedBox(height: 28),
    ];
  }

  Widget _buildKidlingChildSection(ParentUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.orange.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  user.childGender?.toLowerCase() == 'female' 
                      ? Icons.face_3_rounded 
                      : Icons.face_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.childName ?? 'Little Learner',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Age: ${user.childAge ?? '3-6'} years',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _infoRow('Learning Interest', user.learningInterest ?? 'General Learning'),
        _infoRow('Preferred Time', user.preferredLearningTime ?? 'Flexible'),
        if (user.childGender != null)
          _infoRow('Gender', user.childGender!),
      ],
    );
  }

  Widget _buildKidlingProgressSection(ParentUser user, {required bool isPremium, required int dailyLimit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _kidlingStatItem(
              value: '12',
              label: 'Activities\nCompleted',
              icon: Icons.check_circle_rounded,
              color: Colors.green,
            ),
            _kidlingStatItem(
              value: '45',
              label: 'Minutes\nToday',
              icon: Icons.timer_rounded,
              color: Colors.blue,
            ),
            _kidlingStatItem(
              value: isPremium ? 'Unlimited' : dailyLimit.toString(),
              label: 'Daily\nLimit',
              icon: Icons.star_rounded,
              color: Colors.amber,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (!isPremium)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.upgrade_rounded, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock unlimited activities and progress reports!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Colors.amber.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Achievement',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed 5 days of learning in a row!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKidlingActivitiesSection(ParentUser user) {
    final activities = [
      {'name': 'Animal Sounds', 'icon': Icons.pets_rounded, 'color': Colors.orange},
      {'name': 'Counting Fun', 'icon': Icons.calculate_rounded, 'color': Colors.blue},
      {'name': 'ABC Adventure', 'icon': Icons.abc_rounded, 'color': Colors.purple},
      {'name': 'Shape Match', 'icon': Icons.category_rounded, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: activities.map((activity) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: (activity['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    activity['name'] as String,
                    style: TextStyle(
                      color: activity['color'] as Color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _elevatedButton(
          text: 'Explore More Activities',
          icon: Icons.explore_rounded,
          onPressed: () {
            // Navigate to Kidling activities
          },
        ),
      ],
    );
  }

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

  Widget _buildChildrenSection(ParentUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...user.children.take(3).map((childId) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _childTile(childId),
            )),
        if (user.children.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _viewAllButton('View all ${user.children.length} children', () {}),
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

  Widget _buildParentSchoolSection(ParentUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.schoolName != null && user.schoolName!.isNotEmpty)
          _schoolInfoTile(user.schoolName!, 'School', Icons.school_rounded)
        else
          _emptyStateCard(
            icon: Icons.school_rounded,
            title: 'No School',
            subtitle: 'Your child is not enrolled in a school',
            actionText: 'Find School',
            onAction: () {
              // Navigate to school search
            },
          ),
        const SizedBox(height: 12),
        if (user.studentName != null) _infoRow('Child\'s Name', user.studentName!),
        if (user.studentClass != null) _infoRow('Class', user.studentClass!),
        if (user.studentId != null) _infoRow('Student ID', user.studentId!),
        const SizedBox(height: 16),
        _elevatedButton(
          text: 'School Affairs',
          icon: Icons.newspaper_rounded,
          onPressed: () {
            if (user.schoolName != null && user.schoolName!.isNotEmpty) {
              _navigateToAffairs({
                'schoolName': user.schoolName!,
                'studentId': user.studentId ?? '',
              });
            }
          },
        ),
      ],
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

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Not Signed In',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Please sign in to view your profile'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/auth'),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    final color = _getUserColor(user);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(_getUserIcon(user), size: 36, color: Colors.white),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getUserTypeString(user),
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(dynamic user) {
    return Column(
      children: [
        if (user is StudentUser) ..._buildStudentAccountDetails(user),
        if (user is TeacherUser) ..._buildTeacherAccountDetails(user),
        if (user is SchoolAdminUser) ..._buildSchoolAdminAccountDetails(user),
        if (user is ParentUser) ..._buildParentAccountDetails(user),
        _buildDetailRow('Account Created', _formatDate(user.createdAt)),
        _buildDetailRow(
          'Account Status',
          user.status.toString().split('.').last.toUpperCase(),
        ),
      ],
    );
  }

  List<Widget> _buildStudentAccountDetails(StudentUser user) {
    return [
      _buildDetailRow('Student ID', user.studentId ?? 'Not set'),
      _buildDetailRow('Class Grade', user.classGrade != null ? 'Grade ${user.classGrade}' : 'Not set'),
      if (user.schoolName != null && user.schoolName!.isNotEmpty)
        _buildDetailRow('School', user.schoolName!),
    ];
  }

  List<Widget> _buildTeacherAccountDetails(TeacherUser user) {
    return [
      _buildDetailRow('Teacher ID', user.teacherId ?? 'Not set'),
      _buildDetailRow('Subject', user.subjectSpecialization ?? 'Not set'),
      _buildDetailRow('Experience', user.yearsOfExperience != null ? '${user.yearsOfExperience} years' : 'Not set'),
      _buildDetailRow('Qualification', user.qualification ?? 'Not set'),
    ];
  }

  List<Widget> _buildSchoolAdminAccountDetails(SchoolAdminUser user) {
    return [
      _buildDetailRow('School Code', user.schoolCode ?? 'Not set'),
      _buildDetailRow('School Name', user.schoolName ?? 'Not set'),
      _buildDetailRow('Admin Position', user.adminPosition ?? 'Administrator'),
    ];
  }

  List<Widget> _buildParentAccountDetails(ParentUser user) {
    if (user.platform == Platform.kidling) {
      return [
        _buildDetailRow('Child\'s Name', user.childName ?? 'Not set'),
        _buildDetailRow('Child\'s Age', user.childAge?.toString() ?? 'Not set'),
        _buildDetailRow('Learning Interest', user.learningInterest ?? 'Not set'),
        if (user.preferredLearningTime != null)
          _buildDetailRow('Preferred Time', user.preferredLearningTime!),
      ];
    }
    
    return [
      _buildDetailRow('Relationship', user.relationship ?? 'Parent'),
      if (user.studentName != null && user.studentName!.isNotEmpty)
        _buildDetailRow('Student Name', user.studentName!),
      if (user.studentId != null && user.studentId!.isNotEmpty)
        _buildDetailRow('Student ID', user.studentId!),
      if (user.studentClass != null && user.studentClass!.isNotEmpty)
        _buildDetailRow('Student Class', user.studentClass!),
    ];
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_getPlatformIcon(user.platform),
                color: _getUserColor(user), size: 18),
            const SizedBox(width: 8),
            Text(
              _getPlatformName(user.platform),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSubscriptionStatus(user),
      ],
    );
  }

  Widget _buildSubscriptionStatus(dynamic user) {
    Subscription? subscription;
    String plan = 'Free';
    bool active = false;

    // Check for Kidling platform first
    if (user is ParentUser && user.platform == Platform.kidling) {
      subscription = user.kidlingSubscription;
      if (subscription != null) {
        plan = _getKidlingPlanName(subscription);
        active = subscription.isActive && !subscription.hasExpired;
      }
    } else {
      subscription = user.currentSubscription;
      if (subscription != null) {
        plan = subscription.plan.name;
        active = subscription.isActive && !subscription.hasExpired;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle : Icons.info,
              color: active ? Colors.green : Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$plan Plan',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (subscription != null)
                  Text(
                    active
                        ? 'Active until ${_formatDate(subscription.expiryDate)}'
                        : 'Inactive subscription',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _settingsTile(
          icon: Icons.lock_outline,
          title: 'Change Password',
          onTap: () => Get.to(() => const ChangePasswordScreen()),
        ),
        _divider(),
        _settingsTile(
          icon: Icons.notifications_none,
          title: 'Notifications',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
        _divider(),
        _settingsTile(icon: Icons.help_outline, title: 'Help & Support'),
      ],
    );
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

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () async {
          final confirmed = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Sign Out',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirmed == true) {
            await authService.signOut();
            Get.offAllNamed('/platforms');
          }
        },
        child:
            const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAboutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Get.to(() => AboutAppPage()),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('About Scholon',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

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