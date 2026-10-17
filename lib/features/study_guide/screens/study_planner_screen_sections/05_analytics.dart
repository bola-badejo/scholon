part of '../study_planner_screen.dart';

// _StudyPlannerScreenState: _showAnalytics, _showCourseDetails, _showAllCourses
extension StudyPlannerScreenStateSection05 on _StudyPlannerScreenState {
  void _showAnalytics() {
    Get.snackbar(
      'Analytics',
      'Detailed analytics coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showCourseDetails(AdaptedCourse course) {
    Get.bottomSheet(
      Container(
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        course.name,
                        style: TextStyle(
                          fontSize: 24,
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
                  '${course.courseCode} • ${course.credits} credits • ${course.scholonLevel}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                Text(
                  course.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllCourses() {
    if (_scholonCurriculum == null) return;

    Get.bottomSheet(
      Container(
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                'All Courses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: _scholonCurriculum!.courses.length,
                itemBuilder: (context, index) {
                  final course = _scholonCurriculum!.courses[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCourseColor(course.courseCode),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          course.courseCode.substring(0, 2),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(course.name),
                    subtitle: Text('${course.credits} credits'),
                    trailing: Text(course.strand),
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
