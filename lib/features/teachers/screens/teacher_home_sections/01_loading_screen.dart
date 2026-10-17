part of '../teacher_home.dart';

// _TeacherHomeScreenState: _buildLoadingScreen, _buildHomeContent, _buildCoursesContent, _buildTeacherNetworkContent, _buildProfileContent, _buildSubscriptionCard, _buildSubscriptionInfo, _buildRecommendedCoursesSection
extension TeacherHomeScreenStateSection01 on _TeacherHomeScreenState {
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
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.school,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading your teacher dashboard...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Home Content (Original Content)
  Widget _buildHomeContent() {
    final teacherName = _currentUser!.name.split(' ').first;
    final subject = _currentUser!.subjectSpecialization ?? 'Teacher';
    final subscription = _currentUser!.currentSubscription;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome & Teacher Info Section
          _buildTeacherWelcomeSection(teacherName, subject),
          
          // Subscription Status Card
          if (subscription != null) _buildSubscriptionCard(subscription),
          
          // Recommended Courses
          _buildRecommendedCoursesSection(),
          
          // Learning Progress
          _buildLearningProgressSection(),
          
          // Quick Stats
          _buildQuickStatsSection(),
          
          // My Classes
          _buildMyClassesSection(),
          
          // Upcoming Lessons
          _buildUpcomingLessonsSection(),
          
          // Student Performance
          _buildStudentPerformanceSection(),
          
          // Teaching Resources
          _buildTeachingResourcesSection(),

          //Tools Section
          _buildLearningToolsSection(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Courses Content (Placeholder - you'll need to implement this)
  Widget _buildCoursesContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Courses Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'This is where courses would appear',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to actual courses if needed
            },
            child: const Text('Explore Courses'),
          ),
        ],
      ),
    );
  }

  // Teacher Network Content (Placeholder - you'll need to implement this)
  Widget _buildTeacherNetworkContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_rounded, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Desk',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Connect with other teachers',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to actual network if needed
            },
            child: const Text('View Network'),
          ),
        ],
      ),
    );
  }

  // Profile Content (Placeholder - you'll need to implement this)
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
              // Navigate to actual profile if needed
              Get.to(() => UniversalProfileScreen());
            },
            child: const Text('View Full Profile'),
          ),
        ],
      ),
    );
  }

  // SUBSCRIPTION CARD
  Widget _buildSubscriptionCard(TeacherSubscription subscription) {
    final daysRemaining = subscription.daysRemaining;
    final isExpiringSoon = subscription.isExpiringSoon;
    final isActive = subscription.isActive;
    final planDescription = subscription.teacherPlanDescription;

    Color statusColor;
    String statusText;
    
    if (!isActive) {
      statusColor = Colors.red;
      statusText = 'Inactive';
    } else if (subscription.hasExpired) {
      statusColor = Colors.red;
      statusText = 'Expired';
    } else if (isExpiringSoon) {
      statusColor = Colors.orange;
      statusText = 'Expiring Soon';
    } else {
      statusColor = Colors.green;
      statusText = 'Active';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planDescription,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Teacher Subscription',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubscriptionInfo(
                icon: Icons.calendar_today_rounded,
                label: 'Expires In',
                value: '$daysRemaining days',
                color: Colors.grey[700]!,
              ),
              _buildSubscriptionInfo(
                icon: Icons.people_rounded,
                label: 'Max Students',
                value: '${subscription.maxStudents}',
                color: Colors.grey[700]!,
              ),
              _buildSubscriptionInfo(
                icon: Icons.storage_rounded,
                label: 'Storage',
                value: '${subscription.storageGB} GB',
                color: Colors.grey[700]!,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to subscription management
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Manage Subscription',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // RECOMMENDED COURSES SECTION
  Widget _buildRecommendedCoursesSection() {
    final recommendedCourses = [
      {
        'title': 'Classroom Management',
        'description': 'Effective strategies for classroom control',
        'progress': 0.65,
        'color': Colors.blue,
        'lessons': 12,
        'duration': '8 hours',
      },
      {
        'title': 'Digital Teaching Tools',
        'description': 'Master online teaching platforms',
        'progress': 0.30,
        'color': Colors.green,
        'lessons': 8,
        'duration': '6 hours',
      },
      {
        'title': 'Student Assessment',
        'description': 'Modern assessment techniques',
        'progress': 0.85,
        'color': Colors.purple,
        'lessons': 10,
        'duration': '7 hours',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToCourses,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendedCourses.map((course) => 
            _buildRecommendedCourseCard(
              title: course['title'] as String,
              description: course['description'] as String,
              progress: course['progress'] as double,
              color: course['color'] as Color,
              lessons: course['lessons'] as int,
              duration: course['duration'] as String,
            ),
          ).toList(),
        ],
      ),
    );
  }
}
