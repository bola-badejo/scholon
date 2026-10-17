part of '../teacher_home.dart';

// _TeacherHomeScreenState: _buildQuickStatsSection, _buildStatCard, _buildMyClassesSection, _buildClassItem, _buildUpcomingLessonsSection, _buildLessonItem, _buildStudentPerformanceSection
extension TeacherHomeScreenStateSection03 on _TeacherHomeScreenState {
  Widget _buildQuickStatsSection() {
    final totalStudents = _currentUser?.totalStudents ?? 0;
    const averageScore = 0;
    const pendingAssignments = 0;
    const totalClasses = 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teaching Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.people,
                value: '$totalStudents',
                label: 'Students',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.bar_chart,
                value: '${averageScore.toStringAsFixed(1)}%',
                label: 'Avg Score',
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.assignment,
                value: '$pendingAssignments',
                label: 'Pending',
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.class_,
                value: '$totalClasses',
                label: 'Classes',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
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
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyClassesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Classes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.lightGreen.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildClassItem(
                  className: 'Grade 7A - Mathematics',
                  time: 'Mon, Wed, Fri • 10:00 AM',
                  students: 35,
                  color: Colors.blue,
                ),
                const Divider(height: 16),
                _buildClassItem(
                  className: 'Grade 8B - Science',
                  time: 'Tue, Thu • 2:00 PM',
                  students: 28,
                  color: Colors.green,
                ),
                const Divider(height: 16),
                _buildClassItem(
                  className: 'Grade 6C - English',
                  time: 'Daily • 9:00 AM',
                  students: 42,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassItem({
    required String className,
    required String time,
    required int students,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.class_, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                className,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$students students',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: Colors.green.shade200),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingLessonsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Lessons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
              children: [
                _buildLessonItem(
                  subject: 'Mathematics',
                  topic: 'Algebra Basics',
                  time: 'Today, 10:00 AM',
                  classInfo: 'Grade 7A',
                  color: Colors.blue,
                ),
                const Divider(height: 16),
                _buildLessonItem(
                  subject: 'Science',
                  topic: 'Photosynthesis',
                  time: 'Tomorrow, 2:00 PM',
                  classInfo: 'Grade 8B',
                  color: Colors.green,
                ),
                const Divider(height: 16),
                _buildLessonItem(
                  subject: 'English',
                  topic: 'Essay Writing',
                  time: 'Friday, 9:00 AM',
                  classInfo: 'Grade 6C',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem({
    required String subject,
    required String topic,
    required String time,
    required String classInfo,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.book, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                topic,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                classInfo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: Colors.green.shade200),
              ),
              child: const Text(
                'Prepare',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentPerformanceSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Performing Students',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.trending_up, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStudentItem(
                  name: 'Sarah Johnson',
                  score: 95,
                  improvement: '+12%',
                ),
                const Divider(height: 12),
                _buildStudentItem(
                  name: 'Michael Brown',
                  score: 88,
                  improvement: '+8%',
                ),
                const Divider(height: 12),
                _buildStudentItem(
                  name: 'Emma Wilson',
                  score: 92,
                  improvement: '+15%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
