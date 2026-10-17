part of '../school_home.dart';

// _SchoolHomeScreenState: _buildBottomNavigationBar, _buildNavItem, _showSchoolProfileMenu, _buildMenuOption
extension SchoolHomeScreenStateSection03 on _SchoolHomeScreenState {
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
                    // Dashboard
                    _buildNavItem(
                      index: 0,
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isActive: _currentNavIndex == 0,
                    ),

                    // Faculty
                    _buildNavItem(
                      index: 1,
                      icon: Icons.school_rounded,
                      label: 'Faculty',
                      isActive: _currentNavIndex == 1,
                    ),

                    // Connect
                    _buildNavItem(
                      index: 2,
                      icon: Icons.connect_without_contact_rounded,
                      label: 'Connect',
                      isActive: _currentNavIndex == 2,
                    ),

                    // Affairs
                    _buildNavItem(
                      index: 3,
                      icon: Icons.business_center_rounded,
                      label: 'Affairs',
                      isActive: _currentNavIndex == 3,
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
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(
                    icon,
                    size: 30,
                    color: isActive ? Colors.blue : Colors.grey.shade600,
                  ).animate(delay: 100.ms * index)..scale(
                    duration: 200.ms,
                    begin: isActive ? const Offset(0.8, 0.8) : const Offset(1, 1),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.blue : Colors.grey.shade600,
                  ),
                )
                .animate(delay: 150.ms * index)
                .fadeIn(duration: 300.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }

  void _showSchoolProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _currentUser?.schoolName?.substring(0, 1).toUpperCase() ??
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
                _currentUser?.schoolName ?? 'School',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentUser?.name != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Admin: ${_currentUser!.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (_currentUser?.schoolCode != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Code: ${_currentUser!.schoolCode!}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildMenuOption(
                icon: Icons.business,
                title: 'School Profile',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentNavIndex = 4; // Navigate to Profile
                    _pageController.jumpToPage(4);
                  });
                },
              ),
              _buildMenuOption(
                icon: Icons.settings,
                title: 'School Settings',
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/school-settings');
                },
              ),
              _buildMenuOption(
                icon: Icons.report,
                title: 'Reports',
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/school-reports');
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
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
