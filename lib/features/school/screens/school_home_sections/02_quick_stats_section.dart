part of '../school_home.dart';

// _SchoolHomeScreenState: _buildQuickStatsSection, _buildStatCard, _buildRecentActivitiesSection, _buildActivityItem, _buildSchoolStaffSection, _buildStaffCard, _buildUpcomingEventsSection, _buildEventItem
extension SchoolHomeScreenStateSection02 on _SchoolHomeScreenState {
  Widget _buildQuickStatsSection() {
    const totalStudents = 1250;
    const totalTeachers = 48;
    const totalClasses = 36;
    const attendanceRate = 94.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'School Statistics',
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
                icon: Icons.school,
                value: '$totalTeachers',
                label: 'Teachers',
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.class_,
                value: '$totalClasses',
                label: 'Classes',
                color: Colors.purple,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.percent,
                value: '$attendanceRate%',
                label: 'Attendance',
                color: Colors.orange,
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

  Widget _buildRecentActivitiesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
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
                _buildActivityItem(
                  title: 'New Student Enrollment',
                  description: '5 new students enrolled in Grade 7',
                  time: '2 hours ago',
                  icon: Icons.person_add,
                  color: Colors.green,
                ),
                const Divider(height: 16),
                _buildActivityItem(
                  title: 'Teacher Meeting',
                  description: 'Staff meeting completed successfully',
                  time: 'Yesterday',
                  icon: Icons.meeting_room,
                  color: Colors.blue,
                ),
                const Divider(height: 16),
                _buildActivityItem(
                  title: 'Fee Payment',
                  description: 'Monthly fee collection completed',
                  time: '2 days ago',
                  icon: Icons.payment,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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

  Widget _buildSchoolStaffSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'School Staff',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStaffCard(
                  name: 'Mr. Johnson',
                  role: 'Principal',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStaffCard(
                  name: 'Mrs. Williams',
                  role: 'Vice Principal',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStaffCard(
                  name: 'Mr. Davis',
                  role: 'Head of Academics',
                  color: Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildStaffCard(
                  name: 'Ms. Brown',
                  role: 'Admin Officer',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard({
    required String name,
    required String role,
    required Color color,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            role,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
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
                _buildEventItem(
                  title: 'Parent-Teacher Meeting',
                  date: 'March 15, 2024',
                  time: '10:00 AM - 2:00 PM',
                  color: Colors.blue,
                ),
                const Divider(height: 16),
                _buildEventItem(
                  title: 'Sports Day',
                  date: 'March 20, 2024',
                  time: '8:00 AM - 4:00 PM',
                  color: Colors.green,
                ),
                const Divider(height: 16),
                _buildEventItem(
                  title: 'Term Exams',
                  date: 'March 25-30, 2024',
                  time: 'All Day',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem({
    required String title,
    required String date,
    required String time,
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
          child: Icon(Icons.event, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
