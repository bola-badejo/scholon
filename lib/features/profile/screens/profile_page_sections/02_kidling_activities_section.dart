part of '../profile_page.dart';

// UniversalProfileScreen: _buildKidlingActivitiesSection, _buildChildrenSection, _buildParentSchoolSection, _buildEmptyState, _buildProfileHeader, _buildAccountSection, _buildStudentAccountDetails, _buildTeacherAccountDetails, _buildSchoolAdminAccountDetails, _buildParentAccountDetails, _buildDetailRow, _buildPlatformSection, _buildSubscriptionStatus, _buildSettingsSection, _buildSignOutButton, _buildAboutButton
extension _UniversalProfileScreenSection02 on UniversalProfileScreen {
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
}
