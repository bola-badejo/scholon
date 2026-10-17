part of '../parent_home.dart';

// _ParentHomeScreenState: _buildLoadingScreen, _buildHomeContent, _buildChildrenContent, _buildParentDashboardContent, _buildProfileContent, _buildCustomAppBar, _buildParentWelcomeSection, _buildChildOverviewSection
extension ParentHomeScreenStateSection01 on _ParentHomeScreenState {
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.family_restroom,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading parent dashboard...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  // Home Content (Original Parent Content - No changes to content)
  Widget _buildHomeContent() {
    final parentName = _currentUser!.name.split(' ').first;
    final studentName = _currentUser!.studentName ?? 'Your Child';
    final studentClass = _currentUser!.studentClass ?? 'Not specified';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome & Parent Info Section
          _buildParentWelcomeSection(parentName, studentName, studentClass),
          
          // Child Overview
          _buildChildOverviewSection(),
          
          // Child's Performance
          _buildChildPerformanceSection(),
          
          // Attendance & Behavior
          _buildAttendanceBehaviorSection(),
          
          // Upcoming Events
          _buildUpcomingEventsSection(),
          
          // School Notifications
          _buildSchoolNotificationsSection(),
          
          // Quick Actions
          _buildQuickActionsSection(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Children Content (Placeholder - you'll need to implement ChildrenListScreen)
  Widget _buildChildrenContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text(
            'Children',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Manage your children\'s profiles',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to actual children screen if needed 
            },
            child: const Text('View Children'),
          ),
        ],
      ),
    );
  }

  // Parent Dashboard Content (Placeholder - you'll need to implement ParentDashboardScreen)
  Widget _buildParentDashboardContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Parent Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Parent-specific analytics and tools',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to actual dashboard if needed
            },
            child: const Text('View Dashboard'),
          ),
        ],
      ),
    );
  }

  // Profile Content
  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded, size: 80, color: Colors.purple),
          const SizedBox(height: 20),
          const Text(
            'Profile Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'This is your profile section',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.to(() => UniversalProfileScreen());
            },
            child: const Text('View Full Profile'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final parentName = _currentUser?.name.split(' ').first ?? 'Parent';
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // App Logo
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.family_restroom,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Parents Portal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Parent Dashboard',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Notification & Profile
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, size: 20),
                        color: Colors.grey,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentNavIndex = 3;
                          _fabExpanded = false;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            parentName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentWelcomeSection(String parentName, String studentName, String studentClass) {
    final greeting = _getTimeBasedGreeting();
    final relationship = _currentUser?.relationship ?? 'Parent';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Icon(
                    Icons.family_restroom,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $parentName! 👨‍👩‍👧‍👦',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$relationship of $studentName',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Stay updated on your child\'s progress',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school, size: 14, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Text(
                  '$studentClass • Student ID: ${_currentUser?.studentId ?? "N/A"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildOverviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.amber.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentUser?.studentName ?? 'Your Child',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChildInfoItem(
                icon: Icons.school,
                label: 'Class',
                value: _currentUser?.studentClass ?? 'Not set',
              ),
              const SizedBox(width: 20),
              _buildChildInfoItem(
                icon: Icons.badge,
                label: 'Student ID',
                value: _currentUser?.studentId ?? 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChildInfoItem(
                icon: Icons.date_range,
                label: 'School',
                value: _currentUser?.schoolName ?? 'Not set',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
