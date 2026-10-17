part of '../home_page.dart';

// _HomeScreenState: _buildTodaysStudySection, _buildStudyItem, _buildUpcomingQuizzesSection, _buildQuizItem, _buildRecommendedCoursesSection
extension HomeScreenStateSection03 on _HomeScreenState {
  Widget _buildTodaysStudySection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Study Plan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_todaysStudyItems.length} activities',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_todaysStudyItems.isNotEmpty)
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
                  for (int i = 0; i < _todaysStudyItems.length && i < 3; i++)
                    Column(
                      children: [
                        if (i > 0) const Divider(height: 24),
                        _buildStudyItem(_todaysStudyItems[i]),
                      ],
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No activities scheduled for today',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visit the Study Planner to create your schedule',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudyItem(Map<String, dynamic> item) {
    final icon = item['icon'] as IconData? ?? Icons.school;
    final color = item['color'] as Color? ?? Colors.blue;
    final isCompleted = item['isCompleted'] as bool? ?? false;
    final progress = (item['progress'] as num?)?.toDouble() ?? 0.0;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title']?.toString() ?? 'Activity',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['description']?.toString() ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${item['duration'] ?? 30} min',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 12),
                  if (item['courseName'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['courseName']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton(
                onPressed: () {
                  // Navigate to activity
                  Get.to(() => StudyPlannerScreen());
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.deepPurple.shade200),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                ),
              ),
            if (!isCompleted)
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: Colors.deepPurple,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingQuizzesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Quizzes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToQuizzes,
                child: const Text(
                  'View Schedule',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_upcomingQuizzes.isNotEmpty)
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
                  for (int i = 0; i < _upcomingQuizzes.length && i < 3; i++)
                    Column(
                      children: [
                        if (i > 0) const Divider(height: 24),
                        _buildQuizItem(_upcomingQuizzes[i]),
                      ],
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.quiz, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No upcoming quizzes',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for scheduled quizzes',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizItem(UpcomingQuiz quiz) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: quiz.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(quiz.icon, color: quiz.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                quiz.topic,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.duration} min • ${quiz.totalQuestions} questions',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              quiz.formattedDate,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () => _navigateToQuizzes(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: Colors.deepPurple.shade200),
              ),
              child: const Text(
                'Prepare',
                style: TextStyle(fontSize: 12, color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendedCoursesSection() {
    final studentGrade = _currentUser?.classGrade ?? 1;
    final String? grade = _currentUser!.educationCategory;
    String parsedGrade = 'Primary';

    if (grade == 'Senior Secondary Education') {
      parsedGrade = 'SS';
    } else {
      parsedGrade = 'Primary';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended For $parsedGrade $studentGrade',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (_recommendedCourses.isNotEmpty)
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var course in _recommendedCourses.take(4))
                    Padding(
                      padding: EdgeInsets.only(
                        right: course != _recommendedCourses.last ? 12 : 0,
                      ),
                      child: _buildCourseCard(course),
                    ),
                ],
              ),
            )
          else
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 50, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No courses available',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visit the Study Planner to create your schedule',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
