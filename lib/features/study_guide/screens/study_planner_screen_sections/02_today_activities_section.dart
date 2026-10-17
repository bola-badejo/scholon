part of '../study_planner_screen.dart';

// _StudyPlannerScreenState: _buildTodayActivitiesSection, _buildNoActivitiesToday, _buildEnhancedActivityCard, _showActivityDetails
extension StudyPlannerScreenStateSection02 on _StudyPlannerScreenState {
  Widget _buildTodayActivitiesSection() {
    try {
      // Get today's date for filtering
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Filter activities for today from the schedule
      List<DailyActivity> todayScheduledActivities = [];

      if (_currentSchedule != null) {
        for (final entry in _currentSchedule!.dailyActivities.entries) {
          final activityDate = DateTime(
            entry.key.year,
            entry.key.month,
            entry.key.day,
          );

          if (activityDate == today) {
            todayScheduledActivities.addAll(entry.value);
          }
        }
      }

      // Use scheduled activities if available, otherwise use loaded activities
      final activities = todayScheduledActivities.isNotEmpty
          ? todayScheduledActivities
          : _todayActivities
                .where(
                  (activity) =>
                      activity.id.isNotEmpty && activity.title.isNotEmpty,
                )
                .toList();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Schedule",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${activities.length} activities',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(now),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),

            if (activities.isEmpty)
              _buildNoActivitiesToday()
            else
              Column(
                children: activities.map((activity) {
                  return _buildEnhancedActivityCard(activity);
                }).toList(),
              ),
          ],
        ),
      );
    } catch (e) {
      print('Error building today activities: $e');
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Unable to load activities',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }

  Widget _buildNoActivitiesToday() {
    return Container(
      padding: EdgeInsets.all(30),
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
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.calendar_today, size: 40, color: Colors.orange),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Activities Scheduled Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _currentSchedule == null
                ? 'Generate a study plan to get started with your learning journey'
                : 'All caught up! No activities scheduled for today.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          if (_currentSchedule == null)
            ElevatedButton.icon(
              onPressed: _generateSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.play_arrow),
              label: Text('Create Plan Now'),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActivityCard(DailyActivity activity) {
    final isDemo = activity.metadata['isDemo'] == true;
    final courseCode = activity.courseCodes.isNotEmpty
        ? activity.courseCodes.first
        : '';
    final courseName = activity.metadata['courseName'] as String? ?? '';
    final originalContentType =
        activity.metadata['originalContentType'] as String? ?? '';

    // Determine icon based on content type
    final iconData = switch (activity.type) {
      ActivityType.dailyLesson => Icons.menu_book,
      ActivityType.dailyQuiz => Icons.quiz,
      ActivityType.monthlyExam => Icons.assignment,
      ActivityType.practiceSession => Icons.repeat,
      ActivityType.projectWork => Icons.work,
      ActivityType.researchWork => Icons.search,
      ActivityType.experimentLab => Icons.science,
      _ => Icons.school,
    };

    // Determine color based on course
    final color = _getCourseColor(courseCode);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Demo badge if applicable
              if (isDemo)
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science, size: 12, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'DEMO',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Course tag
              if (courseCode.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    courseCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              SizedBox(height: 8),

              // Activity title
              Text(
                activity.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8),

              // Activity description
              Text(
                activity.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 16),

              // Metadata row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Content type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getContentTypeColor(originalContentType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (originalContentType.isNotEmpty
                              ? originalContentType
                              : activity.type.name.replaceAll(
                                  'ActivityType.',
                                  '',
                                ))
                          .toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Duration
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${activity.estimatedDuration.inMinutes} min',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Progress
                  if (activity.isCompleted)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Action buttons
              if (!activity.isCompleted) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startActivity(activity),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.play_arrow),
                        label: Text('Start Now'),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _showActivityDetails(activity),
                      icon: Icon(Icons.info_outline),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(DailyActivity activity) {
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                if (activity.metadata.containsKey('detailedContent'))
                  Text(
                    activity.metadata['detailedContent'] as String,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
