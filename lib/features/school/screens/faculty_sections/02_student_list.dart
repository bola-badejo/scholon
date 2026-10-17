part of '../faculty.dart';

// _FacultyPageState: _buildStudentList, _buildParentList, _buildClassList, _showAddUserDialog, _buildConnectedUsersList, _showUserRoleDialog, _showRoleForm, _showAnnouncementDialog, _showStaffDetails
extension FacultyPageStateSection02 on _FacultyPageState {
  SliverList _buildStudentList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final studentList = schoolController.schoolStudents;
        if (index >= studentList.length) return null;
        final student = studentList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _StudentProfileCard(
            profile: student,
            onTap: () => _showStudentDetails(student),
          ),
        );
      }, childCount: schoolController.schoolStudents.length),
    );
  }

  SliverList _buildParentList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final parentList = schoolController.schoolParents;
        if (index >= parentList.length) return null;
        final parent = parentList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _ParentProfileCard(
            profile: parent,
            onTap: () => _showParentDetails(parent),
          ),
        );
      }, childCount: schoolController.schoolParents.length),
    );
  }

  SliverGrid _buildClassList() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final classes = schoolController.activeClasses;
        if (index >= classes.length) return null;
        final studentClass = classes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _ClassCard(
            studentClass: studentClass,
            onTap: () => _showClassDetails(studentClass),
          ),
        );
      }, childCount: schoolController.activeClasses.length),
    );
  }

  void _showAddUserDialog() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Add User to School',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
            // User Type Selection
            Expanded(child: _buildConnectedUsersList()),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  Widget _buildConnectedUsersList() {
    final connectedUsers = _connectController?.connections ?? [];
    final schoolUsersIds = schoolController.schoolUsers
        .map((u) => u.userId)
        .toSet();

    // Filter out users already in school
    final availableUsers = connectedUsers
        .where((user) => !schoolUsersIds.contains(user.uid))
        .toList();

    if (availableUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Connected Users',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Connect with users first to add them to your school',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: availableUsers.length,
      itemBuilder: (context, index) {
        final user = availableUsers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ConnectUserCard(
            user: user,
            onSelect: () => _showUserRoleDialog(user),
          ),
        );
      },
    );
  }

  void _showUserRoleDialog(BaseUser user) {
    Get.back();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add ${user.name} to School',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select user role in school',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              // Role Selection
              ...UserType.values.map((role) {
                if (role == UserType.schoolAdmin) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getRoleColor(role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getRoleIcon(role),
                        color: _getRoleColor(role),
                      ),
                    ),
                    title: Text(role.displayName),
                    subtitle: Text(_getRoleDescription(role)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showRoleForm(user, role),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleForm(BaseUser user, UserType role) {
    Get.back();

    switch (role) {
      case UserType.teacher:
        Get.to(() => AddTeacherForm(user: user));
        break;
      case UserType.student:
        Get.to(() => AddStudentForm(user: user));
        break;
      case UserType.parent:
        Get.to(() => AddParentForm(user: user));
        break;
      default:
        break;
    }
  }

  void _showAnnouncementDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send Announcement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Send announcement
                        Get.back();
                        Get.snackbar(
                          'Announcement Sent',
                          'Your announcement has been sent',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStaffDetails(SchoolUserProfile staff) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color:
                          staff.teacherDepartment?.color.withOpacity(0.1) ??
                          Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        staff.userName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: staff.teacherDepartment?.color ?? Colors.blue,
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
                          staff.userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          staff.displayRole,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Details
              _buildDetailSection(
                title: 'Contact Information',
                children: [
                  _buildDetailItem(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: staff.userEmail,
                  ),
                  if (staff.phoneNumber != null)
                    _buildDetailItem(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: staff.phoneNumber!,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection(
                title: 'Professional Information',
                children: [
                  if (staff.employeeId != null)
                    _buildDetailItem(
                      icon: Icons.badge_rounded,
                      label: 'Employee ID',
                      value: staff.employeeId!,
                    ),
                  if (staff.teacherDepartment != null)
                    _buildDetailItem(
                      icon: staff.teacherDepartment!.icon,
                      label: 'Department',
                      value: staff.teacherDepartment!.name,
                      color: staff.teacherDepartment!.color,
                    ),
                  if (staff.staffPosition != null)
                    _buildDetailItem(
                      icon: staff.staffPosition!.icon,
                      label: 'Position',
                      value: staff.staffPosition!.title,
                    ),
                  if (staff.assignedSubjects.isNotEmpty)
                    _buildDetailItem(
                      icon: Icons.subject_rounded,
                      label: 'Subjects',
                      value: staff.assignedSubjects.join(', '),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _editStaffProfile(staff),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
