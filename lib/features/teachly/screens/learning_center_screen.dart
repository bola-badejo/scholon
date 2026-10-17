import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/features/teachly/controllers/learning_center_controller.dart';
import 'package:isapp/features/teachly/models/course_data.dart';
import 'package:isapp/features/teachly/models/teacher_course.dart';
import 'package:isapp/features/teachly/widgets/category_chip.dart';
import 'package:isapp/features/teachly/widgets/course_card.dart';
import 'package:isapp/features/teachly/widgets/empty_page.dart';
import 'package:isapp/features/teachly/widgets/error_retry_page.dart';
import 'package:isapp/features/teachly/widgets/featured_course_card.dart';
import 'package:isapp/features/teachly/widgets/searchbar_widget.dart';
import 'package:isapp/data/library/teachly_courses.dart';
import 'package:isapp/features/teachly/screens/course_detail_screen.dart';

part 'learning_center_screen_sections/01_header.dart';
part 'learning_center_screen_sections/02_stat_card.dart';
part 'learning_center_screen_sections/03_course_grid.dart';

class LearningCenterScreen extends StatelessWidget {
  const LearningCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LearningCenterController>(
      init: LearningCenterController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(controller),
                
                // Search Bar
                _buildSearchBar(controller),
                
                // Tabs
                _buildTabBar(controller),
                
                // Content
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    children: [
                      _buildHomeTab(controller),
                      _buildMyCoursesTab(controller),
                      _buildCategoriesTab(controller),
                      _buildAllCoursesTab(controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: controller.isSearching
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    Get.toNamed('/search');
                  },
                  backgroundColor: Get.theme.primaryColor,
                  child: const Icon(Iconsax.search_normal, color: Colors.white),
                ),
        );
      },
    );
  }

String _calculateAverageDuration(List<Course> courses) {
  if (courses.isEmpty) return '0h';
  final totalHours = courses.fold(0, (sum, course) => sum + course.duration.totalHours);
  final avgHours = totalHours ~/ courses.length;
  return '${avgHours}h';
}

int min(int a, int b) => a < b ? a : b;

  void _navigateToCourseDetail(Course course, LearningCenterController controller) {
    Get.to(
      () => CourseDetailScreen(
        course: course,
        teacherCourse: controller.getTeacherCourse(course.id),
      ),
    );
  }

  void _registerForCourse(Course course, LearningCenterController controller) {
    Get.defaultDialog(
      title: 'Register for Course',
      middleText: 'Are you sure you want to register for "${course.title}"?',
      textConfirm: 'Register',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await controller.registerForCourse(course);
      },
    );
  }

}