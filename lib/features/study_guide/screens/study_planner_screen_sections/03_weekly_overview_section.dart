part of '../study_planner_screen.dart';

// _StudyPlannerScreenState: _buildWeeklyOverviewSection, _buildSelectedDayContent, _showAllScheduleDates, _buildProgressStatsSection
extension StudyPlannerScreenStateSection03 on _StudyPlannerScreenState {
  Widget _buildWeeklyOverviewSection() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = _weeklyActivities.keys.toList()..sort();

    // Debug: Print what's in weeklyActivities
    print('\n🎯 Building weekly overview section');
    print('   Weekly activities map has ${_weeklyActivities.length} entries');
    print(
      '   Selected date: ${DateFormat('EEE, MMM d').format(_selectedDate)}',
    );

    int daysWithActivities = _weeklyActivities.values
        .where((list) => list.isNotEmpty)
        .length;
    print('   Days with activities: $daysWithActivities');

    for (final entry in _weeklyActivities.entries) {
      if (entry.value.isNotEmpty) {
        print(
          '   ${DateFormat('EEE, MMM d').format(entry.key)}: ${entry.value.length} activities',
        );
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          // Debug info in dev mode
          if (daysWithActivities == 0 && _currentSchedule != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Schedule starts on ${DateFormat('MMM d').format(_currentSchedule!.startDate)}. '
                      'No activities for current week.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                // Week header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: weekDays.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final date = dates.length > index
                          ? dates[index]
                          : DateTime.now();
                      final isToday =
                          date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;
                      final isSelected = _selectedDate.day == date.day;
                      final hasActivities =
                          _weeklyActivities[date]?.isNotEmpty == true;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : isToday
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                        ? Colors.blue
                                        : Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: hasActivities
                                        ? Colors.green
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Selected day activities OR empty state
                Container(
                  padding: EdgeInsets.all(20),
                  child: _buildSelectedDayContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 20, end: 0, delay: 200.ms);
  }

  Widget _buildSelectedDayContent() {
    final selectedActivities = _weeklyActivities[_selectedDate] ?? [];
    final hasSchedule = _currentSchedule != null;

    if (selectedActivities.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(_selectedDate),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          ...selectedActivities.take(2).map((activity) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getActivityColor(activity.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getActivityIcon(activity.type),
                        color: _getActivityColor(activity.type),
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${activity.estimatedDuration.inMinutes} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 12),
                            if (activity.courseCodes.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCourseColor(
                                    activity.courseCodes.first,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  activity.courseCodes.first,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getCourseColor(
                                      activity.courseCodes.first,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (selectedActivities.length > 2)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '+ ${selectedActivities.length - 2} more activities',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      );
    } else {
      // Empty state
      return Column(
        children: [
          Icon(Icons.beach_access, size: 40, color: Colors.blue.shade300),
          SizedBox(height: 12),
          Text(
            'No activities scheduled',
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasSchedule && _currentSchedule!.dailyActivities.isNotEmpty)
            Column(
              children: [
                SizedBox(height: 8),
                Text(
                  'Schedule has ${_currentSchedule!.dailyActivities.values.fold(0, (sum, list) => sum + list.length)} total activities',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Show all schedule dates
                    _showAllScheduleDates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('View All Scheduled Dates'),
                ),
              ],
            ),
        ],
      );
    }
  }

  void _showAllScheduleDates() {
    if (_currentSchedule == null || _currentSchedule!.dailyActivities.isEmpty)
      return;

    final allDates = _currentSchedule!.dailyActivities.keys.toList()..sort();

    Get.bottomSheet(
      Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'All Scheduled Dates',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: allDates.length,
                itemBuilder: (context, index) {
                  final date = allDates[index];
                  final activities =
                      _currentSchedule!.dailyActivities[date] ?? [];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${activities.length}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(DateFormat('EEEE, MMMM d, yyyy').format(date)),
                    subtitle: Text('${activities.length} activities'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Jump to this date in weekly view
                      setState(() {
                        _selectedDate = date;
                        // Regenerate weekly view centered on this date
                        _generateWeeklyViewCenteredOn(date);
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

  Widget _buildProgressStatsSection() {
    final averageScore =
        (_progressData['averageScore'] as num?)?.toDouble() ?? 0.0;
    final completedActivities =
        (_progressData['completedActivities'] as int?) ?? 0;
    final streak = (_progressData['streak'] as int?) ?? 0;
    final weeklyHours =
        (_progressData['weeklyHours'] as num?)?.toDouble() ?? 0.0;

    return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Learning Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Overall progress
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${(averageScore).toInt()}%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${completedActivities} activities completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 50,
                          lineWidth: 8,
                          percent: averageScore / 100,
                          center: Text(
                            '${(averageScore).toInt()}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          progressColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Stats grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _buildStatTile(
                          icon: Icons.local_fire_department,
                          value: streak.toString(),
                          label: 'Day Streak',
                          color: Colors.orange,
                          bgColor: Colors.white.withOpacity(0.1),
                        ),
                        _buildStatTile(
                          icon: Icons.access_time,
                          value: '${weeklyHours.toStringAsFixed(1)}h',
                          label: 'Weekly Hours',
                          color: Colors.green,
                          bgColor: Colors.white.withOpacity(0.1),
                        ),
                        _buildStatTile(
                          icon: Icons.check_circle,
                          value: completedActivities.toString(),
                          label: 'Completed',
                          color: Colors.blue,
                          bgColor: Colors.white.withOpacity(0.1),
                        ),
                        _buildStatTile(
                          icon: Icons.trending_up,
                          value: '${(averageScore / 20).toStringAsFixed(1)}',
                          label: 'Avg. Grade',
                          color: Colors.purple,
                          bgColor: Colors.white.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 700.ms)
        .slideY(begin: 20, end: 0, delay: 300.ms);
  }
}
