part of '../teacher_home.dart';

// _TeacherHomeScreenState: _buildStudentItem, _buildLearningToolsSection, _buildToolCard, _buildTeachingResourcesSection, _buildResourceCard, _buildBottomNavigationBar, _buildNavItem
extension TeacherHomeScreenStateSection04 on _TeacherHomeScreenState {
  Widget _buildStudentItem({
    required String name,
    required int score,
    required String improvement,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Score: $score%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            improvement,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningToolsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToTools,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var tool in _tools.take(4))
                  Padding(
                    padding: EdgeInsets.only(
                      right: tool != _tools.last ? 12 : 0,
                    ),
                    child: _buildToolCard(tool),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(Map<String, String> tool) {
    // Parse color from string
    final color = Color(int.parse(tool['color']!));
    final iconName = tool['icon']!;

    // Map icon names to IconData
    final iconMap = {
      'person': Icons.person,
      'security': Icons.security,
      'assessment': Icons.assessment,
      'note_add': Icons.note_add,
      'settings': Icons.settings,
      'lock': Icons.lock,
      'bar_chart': Icons.bar_chart,
      'edit_note': Icons.edit_note,
      'library_books': Icons.library_books,
      'calendar_today': Icons.calendar_today,
    };

    return GestureDetector(
      onTap: () {
        // Handle tool specific navigation
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconMap[iconName] ?? Icons.help_outline,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tool['title']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            if (tool['subtitle'] != null) ...[
              const SizedBox(height: 4),
              Text(
                tool['subtitle']!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeachingResourcesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teaching Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildResourceCard(
                  title: 'Lesson Plans',
                  icon: Icons.description,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildResourceCard(
                  title: 'Worksheets',
                  icon: Icons.assignment,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildResourceCard(
                  title: 'Quizzes',
                  icon: Icons.quiz,
                  color: Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildResourceCard(
                  title: 'Videos',
                  icon: Icons.video_library,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

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

                    // Course
                    _buildNavItem(
                      icon: Icons.menu_book_rounded,
                      label: 'Course',
                      index: 1,
                      onTap: _navigateToCourses,
                    ),

                    // Spacer for FAB
                    const SizedBox(width: 60),

                    // Teacher
                    _buildNavItem(
                      icon: Icons.groups_rounded,
                      label: 'Teacher',
                      index: 2,
                      onTap: _navigateToTeacherNetwork,
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

          // Floating Action Button for Connect
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
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(_fabExpanded ? 20 : 30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(
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
                    ? Colors.green.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isActive ? Colors.green : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.green : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
