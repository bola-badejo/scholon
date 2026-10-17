part of '../study_planner_screen.dart';

// _StudyPlannerScreenState: _buildStatTile, _buildQuickActionsSection, _buildQuickActionCard, _buildCourseOverviewSection, _buildGenerateScheduleButton, _showCalendarView
extension StudyPlannerScreenStateSection04 on _StudyPlannerScreenState {
  Widget _buildStatTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, size: 18, color: color)),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.assignment_add,
                    title: 'Add Custom Task',
                    subtitle: 'Create your own study task',
                    color: Color(0xFF667EEA),
                    onTap: () => _addCustomTask(),
                  ),
                  _buildQuickActionCard(
                    icon: Icons.replay,
                    title: 'Reset Progress',
                    subtitle: 'Start fresh',
                    color: Color(0xFFFF416C),
                    onTap: () => _resetProgress(),
                  ),
                  _buildQuickActionCard(
                    icon: Icons.download,
                    title: 'Export Schedule',
                    subtitle: 'Save as PDF/Calendar',
                    color: Color(0xFF11998E),
                    onTap: () => _exportSchedule(),
                  ),
                  _buildQuickActionCard(
                    icon: Icons.share,
                    title: 'Share Progress',
                    subtitle: 'With parents/teachers',
                    color: Color(0xFFFFB347),
                    onTap: () => _shareProgress(),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 20, end: 0, delay: 400.ms);
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
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
                child: Center(child: Icon(icon, color: color, size: 20)),
              ),
              Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseOverviewSection() {
    if (_scholonCurriculum == null || _scholonCurriculum!.courses.isEmpty) {
      return SizedBox();
    }

    final courses = _scholonCurriculum!.courses;
    final totalCredits = courses.fold(
      0.0,
      (sum, course) => sum + course.credits,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curriculum Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${courses.length} courses • ${totalCredits.toInt()} total credits',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),

          ...courses.take(3).map((course) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getCourseColor(course.courseCode),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      course.courseCode.substring(0, 2),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  course.name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${course.credits} credits • ${course.scholonLevel}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStrandColor(course.strand).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course.strand,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getStrandColor(course.strand),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () => _showCourseDetails(course),
              ),
            );
          }),

          if (courses.length > 3)
            Center(
              child: TextButton(
                onPressed: () => _showAllCourses(),
                child: Text(
                  'View all ${courses.length} courses',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms);
  }

  Widget _buildGenerateScheduleButton() {
    final selectedOption = _profileOptions.firstWhere(
      (opt) => opt['profile'] == _selectedProfile,
      orElse: () => _profileOptions[1],
    );

    // Don't show generate button if schedule exists
    if (_currentSchedule != null) {
      return Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'Your study plan is ready',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _generateSchedule(),
                    child: Text('Regenerate'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You can regenerate your schedule if needed',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 1200.ms);
    }

    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selectedOption['gradient'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: selectedOption['gradient'][0].withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _isGeneratingSchedule ? null : _generateSchedule,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isGeneratingSchedule)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(Icons.auto_awesome, size: 22, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  _isGeneratingSchedule
                      ? 'Creating Your Plan...'
                      : 'Generate Study Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 1200.ms);
  }

  void _showCalendarView() {
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                'Select Date',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 30,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  return ListTile(
                    title: Text(DateFormat('EEEE, MMMM d').format(date)),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
