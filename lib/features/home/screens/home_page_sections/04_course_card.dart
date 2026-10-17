part of '../home_page.dart';

// _HomeScreenState: _buildCourseCard, _buildQuickAccessSection, _buildQuickAccessCard, _buildLearningToolsSection, _buildToolCard, _buildEducationalGamesSection, _buildGameCard
extension HomeScreenStateSection04 on _HomeScreenState {
  Widget _buildCourseCard(RecommendedCourse course) {
    final progressPercent = (course.progress * 100).toInt();

    return GestureDetector(
      onTap: () => _navigateToCourseDetails(course),
      child: Container(
        width: 180,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: course.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(course.icon, color: course.color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              course.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (course.totalActivities > 0)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text(
                        '${course.completedActivities}/${course.totalActivities}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: course.progress,
                    backgroundColor: Colors.grey[200],
                    color: course.color,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ElevatedButton(
              onPressed: () => _navigateToCourseDetails(course),
              style: ElevatedButton.styleFrom(
                backgroundColor: course.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: course.progress > 0
                  ? const Text('Continue')
                  : const Text('Start Learning'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Courses',
                  subtitle: '${_courses.length} available',
                  icon: Icons.library_books,
                  color: Colors.blue,
                  onTap: _navigateToCourses,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Quizzes',
                  subtitle: '${_quizzes.length} available',
                  icon: Icons.quiz,
                  color: Colors.green,
                  onTap: _navigateToQuizzes,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Exams',
                  subtitle: '${_exams.length} available',
                  icon: Icons.assignment,
                  color: Colors.purple,
                  onTap: _navigateToExams,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Tools',
                  subtitle: '${_tools.length} available',
                  icon: Icons.build,
                  color: Colors.orange,
                  onTap: _navigateToTools,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
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
    final route = tool['route'] ?? '/not-found'; // Get route or default

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
        if (tool['route'] != null) {
          Get.toNamed(tool['route']!); // Navigate to specific route
        }
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

  Widget _buildEducationalGamesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Games',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToGames,
                child: const Text(
                  'Play All',
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
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var game in _games.take(3))
                  Padding(
                    padding: EdgeInsets.only(
                      right: game != _games.last ? 12 : 0,
                    ),
                    child: _buildGameCard(game),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameDetail game) {
    return GestureDetector(
      onTap: () => Get.toNamed(game.route), // Use Get.toNamed for navigation
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: game.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: game.color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: game.color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(game.image, width: 40, height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    game.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              game.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.toNamed(game.route), // Use Get.toNamed
              style: ElevatedButton.styleFrom(
                backgroundColor: game.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text('Play Now'),
            ),
          ],
        ),
      ),
    );
  }
}
