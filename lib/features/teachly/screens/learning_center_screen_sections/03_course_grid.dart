part of '../learning_center_screen.dart';

// LearningCenterScreen: _buildCourseGrid, _showProgressDialog
extension _LearningCenterScreenSection03 on LearningCenterScreen {
  Widget _buildCourseGrid({
    required List<Course> courses,
    required LearningCenterController controller,
    bool showRegisterButton = false,
  }) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courses.isEmpty) {
      return EmptyStateWidget(
        icon: Iconsax.search_normal,
        title: 'No Courses Found',
        message: controller.searchQuery.isNotEmpty
            ? 'No courses match your search'
            : 'No courses available in this category',
        actionText: controller.searchQuery.isNotEmpty ? 'Clear Search' : null,
        onAction: controller.searchQuery.isNotEmpty
            ? controller.endSearch
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => await controller.refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.50,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final isRegistered = controller.isRegisteredForCourse(course.id);
          
          return CourseCard(
            course: course,
            isRegistered: isRegistered,
            onTap: () {
              _navigateToCourseDetail(course, controller);
            },
            onRegister: isRegistered || !showRegisterButton
                ? null
                : () {
                    _registerForCourse(course, controller);
                  },
          );
        },
      ),
    );
  }

  void _showProgressDialog(TeacherCourse teacherCourse, LearningCenterController controller) {
    Get.defaultDialog(
      title: 'Course Progress',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teacherCourse.course.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: teacherCourse.overallProgress,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text('${(teacherCourse.overallProgress * 100).toInt()}% Complete'),
          if (teacherCourse.estimatedTimeRemaining != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Estimated time remaining: ${teacherCourse.estimatedTimeRemaining}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(
                () => CourseDetailScreen(
                  course: teacherCourse.course,
                  teacherCourse: teacherCourse,
                ),
              );
            },
            child: const Text('Continue Learning'),
          ),
        ],
      ),
    );
  }
}
