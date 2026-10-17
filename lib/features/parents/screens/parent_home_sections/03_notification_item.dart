part of '../parent_home.dart';

// _ParentHomeScreenState: _buildNotificationItem, _buildQuickActionsSection, _buildActionButton, _buildBottomNavigationBar, _buildNavItem
extension ParentHomeScreenStateSection03 on _ParentHomeScreenState {
  Widget _buildNotificationItem({
    required String title,
    required String description,
    required String time,
    required bool isImportant,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isImportant ? Colors.red.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isImportant ? Icons.warning : Icons.info,
            color: isImportant ? Colors.red : Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isImportant ? Colors.red : Colors.black,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.message,
                label: 'Message\nTeacher',
                color: Colors.blue,
              ),
              _buildActionButton(
                icon: Icons.payment,
                label: 'Pay\nFees',
                color: Colors.green,
              ),
              _buildActionButton(
                icon: Icons.download,
                label: 'Download\nReports',
                color: Colors.purple,
              ),
              _buildActionButton(
                icon: Icons.calendar_today,
                label: 'View\nCalendar',
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // EXACT SAME BOTTOM NAVIGATION BAR AS TEACHER (with orange theme)
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
                      icon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                      onTap: _navigateToHome,
                    ),

                    // Children
                    _buildNavItem(
                      icon: Icons.child_care_rounded,
                      label: 'Children',
                      index: 1,
                      onTap: _navigateToChildren,
                    ),

                    // Spacer for FAB
                    const SizedBox(width: 60),

                    // Dashboard
                    _buildNavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      index: 2,
                      onTap: _navigateToParentDashboard,
                    ),

                    // Profile
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      index: 3,
                      onTap: _navigateToProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button for Connect (EXACT SAME AS TEACHER)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            bottom: 25,
            child: GestureDetector(
              onTap: _navigateToConnect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _fabExpanded ? 140 : 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFF57C00)], // Orange theme
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(_fabExpanded ? 20 : 30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(
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
                    if (_fabExpanded)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                        ),
                        child: Text(
                          'Connect',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Icon(
                      Icons.connect_without_contact_rounded,
                      color: Colors.white,
                      size: 24,
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

  // EXACT SAME NAV ITEM BUILDER AS TEACHER
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = _currentNavIndex == index;
    
    return GestureDetector(
      onTap: onTap,
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
                    ? Colors.orange.withOpacity(0.1) // Orange theme
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isActive ? Colors.orange : Colors.grey.shade600, // Orange theme
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.orange : Colors.grey.shade600, // Orange theme
              ),
            ),
          ],
        ),
      ),
    );
  }
}
