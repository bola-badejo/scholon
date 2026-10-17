part of '../home_page.dart';

// _HomeScreenState: _buildLoadingScreen, _buildHomePageContent, _buildCustomAppBar, _buildStudentWelcomeSection
extension HomeScreenStateSection01 on _HomeScreenState {
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
                  colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading your learning journey...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  // ====================
  // PAGE VIEW CONTENT
  // ====================
  Widget _buildHomePageContent() {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No user data found', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/auth'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final studentName = _currentUser!.name.split(' ').first;
    final gradeLevel = _currentUser!.gradeLevel;
    final subscription = _currentUser!.currentSubscription;
    final hasActiveSubscription = _currentUser!.hasActiveSubscription;
    final isOnTrial = _currentUser!.isOnFreeTrial;
    final daysRemaining = _currentUser!.currentSubscription?.daysRemaining ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome & User Info Section
          _buildStudentWelcomeSection(
            studentName,
            gradeLevel,
            _courses.length,
            _quizzes.length,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

          // Subscription Status Section
          _buildSubscriptionSection(
                hasActiveSubscription,
                isOnTrial,
                daysRemaining,
                subscription,
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, delay: 100.ms),

          // Quick Stats
          _buildQuickStatsSection()
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, delay: 200.ms),

          // Continue Learning
          _buildContinueLearningSection()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, end: 0, delay: 300.ms),

          // Today's Study Items (Updated)
          _buildTodaysStudySection()
              .animate()
              .fadeIn(duration: 700.ms)
              .slideY(begin: 0.1, end: 0, delay: 400.ms),

          // Upcoming Quizzes (Dynamic)
          _buildUpcomingQuizzesSection()
              .animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.1, end: 0, delay: 500.ms),

          // Recommended Courses (Dynamic)
          _buildRecommendedCoursesSection()
              .animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.1, end: 0, delay: 500.ms),

          // Quick Access Cards (Courses, Quizzes, Exams)
          _buildQuickAccessSection()
              .animate()
              .fadeIn(duration: 900.ms)
              .slideY(begin: 0.1, end: 0, delay: 600.ms),

          _buildVideoListCard()
              .animate()
              .fadeIn(duration: 1000.ms)
              .slideY(begin: 0.1, end: 0, delay: 700.ms),

          // Learning Tools
          _buildLearningToolsSection()
              .animate()
              .fadeIn(duration: 1100.ms)
              .slideY(begin: 0.1, end: 0, delay: 800.ms),

          // Educational Games
          _buildEducationalGamesSection()
              .animate()
              .fadeIn(duration: 1200.ms)
              .slideY(begin: 0.1, end: 0, delay: 900.ms),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final studentName = _currentUser?.name.split(' ').first ?? 'Student';

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
                      colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.school,
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
                      'iStudyApp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Student Learning Platform',
                      style: TextStyle(fontSize: 9, color: Colors.grey),
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
                      child: Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              size: 20,
                            ),
                            color: Colors.grey,
                            onPressed: () {},
                          ),
                          if (_upcomingQuizzes.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showStudentProfileMenu,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _currentUser?.profileImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _currentUser!.profileImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  studentName.substring(0, 1).toUpperCase(),
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

  Widget _buildStudentWelcomeSection(
    String studentName,
    String gradeLevel,
    int totalCourses,
    int totalQuizzes,
  ) {
    final greeting = _getTimeBasedGreeting();

    // Get dynamic data
    final dailyGoalMinutes = _learningStats['dailyGoalMinutes'] as int? ?? 120;
    final examsCount = _learningStats['examsCount'] as int? ?? 0;
    final hours = dailyGoalMinutes ~/ 60;
    final minutes = dailyGoalMinutes % 60;

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
                    colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Icon(Icons.school, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $studentName! 👋',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grade $gradeLevel • ${_currentUser?.schoolName ?? "No school"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.3,
              ),
              children: [
                const TextSpan(text: 'Ready to explore '),
                TextSpan(
                  text: '$totalCourses courses',
                  style: const TextStyle(color: Colors.deepPurple),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: '$totalQuizzes quizzes',
                  style: const TextStyle(color: Colors.deepPurple),
                ),
                const TextSpan(text: ' today?'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.amber.shade700),
                    const SizedBox(width: 6),
                    Text(
                      hours > 0
                          ? 'Daily Goal: ${hours}h ${minutes}m'
                          : 'Daily Goal: ${minutes}m',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_turned_in,
                      size: 14,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$examsCount exam${examsCount != 1 ? 's' : ''} preps',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
