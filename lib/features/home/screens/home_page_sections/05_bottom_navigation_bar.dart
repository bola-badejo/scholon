part of '../home_page.dart';

// _HomeScreenState: _buildBottomNavigationBar, _buildNavItem, _showStudentProfileMenu, _buildMenuOption
extension HomeScreenStateSection05 on _HomeScreenState {
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Bottom Navigation Bar
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  border: Border.all(color: Colors.grey.shade200, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isActive: _currentNavIndex == 0,
                    ),

                    // Activities
                    _buildNavItem(
                      index: 1,
                      icon: Icons.local_activity_rounded,
                      label: 'Planner',
                      isActive: _currentNavIndex == 1,
                    ),

                    // Spacer for FAB
                    const SizedBox(width: 60),

                    // Explore
                    _buildNavItem(
                      index: 2,
                      icon: Icons.school_rounded,
                      label: 'Classroom',
                      isActive: _currentNavIndex == 2,
                    ),

                    // Profile
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      isActive: _currentNavIndex == 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button for Connect
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            bottom: 25,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _fabExpanded = !_fabExpanded;
                });
                // Navigate to Connect page after animation
                Future.delayed(300.ms, () {
                  Get.toNamed('/connect');
                });
              },
              child: AnimatedContainer(
                duration: 300.ms,
                curve: Curves.easeInOut,
                width: _fabExpanded ? 140 : 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _currentNavIndex == 2
                        ? [Colors.deepPurple, Colors.purple]
                        : [Colors.deepPurple.shade400, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(_fabExpanded ? 20 : 30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(
                        _fabExpanded ? 0.4 : 0.3,
                      ),
                      blurRadius: _fabExpanded ? 20 : 15,
                      spreadRadius: _fabExpanded ? 1 : 0,
                      offset: Offset(0, _fabExpanded ? 8 : 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _fabExpanded
                        ? AnimatedOpacity(
                            duration: 200.ms,
                            opacity: _fabExpanded ? 1 : 0,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 8,
                              ),
                              child:
                                  Text(
                                    'Connect',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ).animate().slideX(
                                    begin: -0.2,
                                    end: 0,
                                    duration: 200.ms,
                                    curve: Curves.easeOut,
                                  ),
                            ),
                          )
                        : Container(),
                    Icon(
                      Icons.connect_without_contact_rounded,
                      color: Colors.white,
                      size: 24,
                    ).animate().rotate(
                      duration: 300.ms,
                      curve: Curves.easeInOut,
                      begin: _fabExpanded ? 0 : -0.5,
                      end: _fabExpanded ? 0.5 : 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
          _pageController.jumpToPage(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.deepPurple.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(
                    icon,
                    size: 30,
                    color: isActive ? Colors.deepPurple : Colors.grey.shade600,
                  ).animate(delay: 100.ms * index)..scale(
                    duration: 200.ms,
                    begin: isActive ? Offset(0.8, 0.8) : Offset(1, 1),
                    end: Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.deepPurple : Colors.grey.shade600,
                  ),
                )
                .animate(delay: 150.ms * index)
                .fadeIn(duration: 300.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }

  void _showStudentProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _currentUser?.name
                              .split(' ')
                              .map((s) => s[0])
                              .take(2)
                              .join()
                              .toUpperCase() ??
                          'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentUser?.name ?? 'Student',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentUser?.schoolName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _currentUser!.schoolName!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (_currentUser?.classGrade != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_currentUser!.gradeLevel}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (_currentUser?.parentName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Parent: ${_currentUser!.parentName!}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 20),
                _buildMenuOption(
                  icon: Icons.person,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentNavIndex = 4;
                      _pageController.jumpToPage(4);
                    });
                  },
                ),
                _buildMenuOption(
                  icon: Icons.bar_chart,
                  title: 'Progress Report',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/progress');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.assignment,
                  title: 'My Assignments',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/assignments');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.school,
                  title: 'My Courses',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCourses();
                  },
                ),
                _buildMenuOption(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/settings');
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _authService.signOut();
                      Get.offAllNamed('/auth');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.grey[700]),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
