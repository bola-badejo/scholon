import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/TeachlyLearning/learning_center_controller.dart';
import 'package:isapp/TeachlyLearning/model/course_data.dart';
import 'package:isapp/TeachlyLearning/model/teacher_course.dart';
import 'package:isapp/TeachlyLearning/widgets.dart/category_chip.dart';
import 'package:isapp/TeachlyLearning/widgets.dart/course_card.dart';
import 'package:isapp/TeachlyLearning/widgets.dart/empty_page.dart';
import 'package:isapp/TeachlyLearning/widgets.dart/error_retry_page.dart';
import 'package:isapp/TeachlyLearning/widgets.dart/featured_course_card.dart';
import 'package:isapp/TeachlyLearning/widgets.dart/searchbar_widget.dart';
import 'package:isapp/Utils/library/teachly_courses.dart';
import 'course_detail_screen.dart';

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

  Widget _buildHeader(LearningCenterController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Center',
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final count = controller.totalRegisteredCourses;
                    return Text(
                      '$count registered course${count != 1 ? 's' : ''}',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    );
                  }),
                ],
              ),
              IconButton(
                onPressed: () => controller.refresh(),
                icon: const Icon(Iconsax.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress summary
          Obx(() {
            if (!controller.hasTeacherCourses) return const SizedBox();
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Learning Progress',
                          style: Get.textTheme.labelMedium?.copyWith(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: controller.overallProgress,
                          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.2),
                          color: Get.theme.colorScheme.primary,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(controller.overallProgress * 100).toInt()}% Complete',
                              style: Get.textTheme.labelSmall?.copyWith(
                                color: Get.theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              '${controller.completedCourses}/${controller.totalRegisteredCourses} completed',
                              style: Get.textTheme.labelSmall?.copyWith(
                                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.trend_up, color: Colors.white, size: 20),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LearningCenterController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SearchBarWidget(
        controller: controller,
      ),
    );
  }

  Widget _buildTabBar(LearningCenterController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: controller.tabController,
        labelColor: Get.theme.colorScheme.primary,
        unselectedLabelColor: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: Get.theme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: Get.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: Get.textTheme.labelLarge,
        tabs: const [
          Tab(text: 'Home'),
          Tab(text: 'My Courses'),
          Tab(text: 'Categories'),
          Tab(text: 'Browse'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(LearningCenterController controller) {
  return Obx(() {
    if (controller.isLoading) {
      return _buildLoadingState();
    }

    if (controller.error.isNotEmpty) {
      return _buildErrorState(controller);
    }

    // Check if we have any courses at all
    if (controller.allCourses.isEmpty) {
      return _buildNoCoursesState(controller);
    }

    return RefreshIndicator(
      onRefresh: () async => await controller.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(controller),
            
            // Recommended for you (based on registered courses)
            if (controller.recommendedCourses.isNotEmpty)
              _buildCourseSection(
                title: 'Recommended For You',
                subtitle: 'Based on your teaching interests',
                courses: controller.recommendedCourses,
                isHorizontal: true,
                controller: controller,
              ),
            
            // Featured courses (high rating & enrollment)
            if (controller.featuredCourses.isNotEmpty)
              _buildCourseSection(
                title: 'Featured Courses',
                subtitle: 'Top-rated by teachers',
                courses: controller.featuredCourses,
                isHorizontal: true,
                controller: controller,
              ),
            
            // New courses
            if (controller.newCourses.isNotEmpty)
              _buildCourseSection(
                title: 'New & Trending',
                subtitle: 'Recently added courses',
                courses: controller.newCourses,
                controller: controller,
              ),
            
            // Popular courses
            if (controller.popularCourses.isNotEmpty)
              _buildCourseSection(
                title: 'Most Popular',
                subtitle: 'Highly enrolled courses',
                courses: controller.popularCourses,
                controller: controller,
              ),
            
            // Free courses
            if (controller.freeCourses.isNotEmpty)
              _buildCourseSection(
                title: 'Free Courses',
                subtitle: 'Start learning for free',
                courses: controller.freeCourses,
                controller: controller,
              ),
            
            // Beginner courses
            if (controller.beginnerCourses.isNotEmpty)
              _buildCourseSection(
                title: 'Beginner Friendly',
                subtitle: 'Perfect for getting started',
                courses: controller.beginnerCourses,
                controller: controller,
              ),
            
            // All categories section
            _buildAllCategoriesSection(controller),
            
            // Quick stats
            _buildQuickStats(controller),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  });
}

Widget _buildWelcomeSection(LearningCenterController controller) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Get.theme.colorScheme.primary.withOpacity(0.1),
          Get.theme.colorScheme.secondary.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Teachly Academy! 👨‍🏫',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore ${controller.allCourses.length} courses across ${controller.categories.length} categories to enhance your teaching skills.',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              if (controller.hasTeacherCourses)
                Row(
                  children: [
                    Chip(
                      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.2),
                      label: Text(
                        '${controller.totalRegisteredCourses} enrolled',
                        style: Get.textTheme.labelSmall?.copyWith(
                          color: Get.theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.2),
                      label: Text(
                        '${(controller.overallProgress * 100).toInt()}% progress',
                        style: Get.textTheme.labelSmall?.copyWith(
                          color: Get.theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Iconsax.book,
          size: 48,
          color: Get.theme.colorScheme.primary,
        ),
      ],
    ),
  );
}

Widget _buildAllCategoriesSection(LearningCenterController controller) {
  if (controller.categories.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Text(
        'Browse by Category',
        style: Get.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Explore courses in specific teaching areas',
        style: Get.textTheme.bodyMedium?.copyWith(
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      const SizedBox(height: 16),
      
      // Category chips with course counts
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.categories.map((category) {
          final courseCount = controller.getCoursesByCategory(category).length;
          return InkWell(
            onTap: () {
              controller.selectCategory(category);
              controller.selectTab(2); // Switch to Categories tab
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Get.theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category,
                    style: Get.textTheme.labelMedium?.copyWith(
                      color: Get.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$courseCount',
                      style: Get.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      
      const SizedBox(height: 24),
    ],
  );
}

Widget _buildQuickStats(LearningCenterController controller) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Get.theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
      ),
    ),
    child: Column(
      children: [
        Text(
          'Course Statistics',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              icon: Iconsax.book,
              label: 'Total Courses',
              value: '${controller.allCourses.length}',
              color: Colors.blue,
            ),
            _buildStatCard(
              icon: Iconsax.teacher,
              label: 'Instructors',
              value: '${controller.allCourses.map((c) => c.instructor.name).toSet().length}',
              color: Colors.green,
            ),
            _buildStatCard(
              icon: Iconsax.crown,
              label: 'Categories',
              value: '${controller.categories.length}',
              color: Colors.orange,
            ),
            _buildStatCard(
              icon: Iconsax.clock,
              label: 'Avg Duration',
              value: '${_calculateAverageDuration(controller.allCourses)}',
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
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    width: 140,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(0.3),
      ),
    ),
    child: Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Get.textTheme.labelSmall?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    ),
  );
}

String _calculateAverageDuration(List<Course> courses) {
  if (courses.isEmpty) return '0h';
  final totalHours = courses.fold(0, (sum, course) => sum + course.duration.totalHours);
  final avgHours = totalHours ~/ courses.length;
  return '${avgHours}h';
}

Widget _buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Get.theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading courses...',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorState(LearningCenterController controller) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 64,
            color: Get.theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Courses',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Get.theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.error,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refresh(),
            icon: const Icon(Iconsax.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Show debug info
              Get.defaultDialog(
                title: 'Debug Information',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Courses: ${controller.allCourses.length}'),
                    Text('Published Courses: ${controller.filteredCourses.length}'),
                    Text('Categories: ${controller.categories.length}'),
                    const SizedBox(height: 8),
                    Text('JSON Source: TeachlyCourses.curriculum'),
                    Text('First 100 chars: ${TeachlyCourses.curriculum.substring(0, min(100, TeachlyCourses.curriculum.length))}'),
                  ],
                ),
              );
            },
            child: const Text('Show Debug Info'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildNoCoursesState(LearningCenterController controller) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.book,
            size: 64,
            color: Get.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Courses Available',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no courses to display. This could be because:\n\n1. No courses are published\n2. There\'s an issue with the course data\n3. No courses match your filters',
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refresh(),
            icon: const Icon(Iconsax.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Get.defaultDialog(
                title: 'Course Data Status',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total courses loaded: ${controller.allCourses.length}'),
                    Text('Published courses: ${controller.filteredCourses.length}'),
                    Text('Categories: ${controller.categories.join(", ")}'),
                    const SizedBox(height: 8),
                    if (controller.allCourses.isNotEmpty)
                      ...controller.allCourses.take(3).map((course) => Text(
                        '- ${course.title} (${course.status})',
                        style: Get.textTheme.bodySmall,
                      )),
                  ],
                ),
              );
            },
            child: const Text('View Data Status'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDebugInfo(LearningCenterController controller) {
  return Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Debug Info (Development Only)',
          style: Get.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Courses: ${controller.allCourses.length}',
          style: Get.textTheme.bodySmall,
        ),
        Text(
          'Published: ${controller.filteredCourses.length}',
          style: Get.textTheme.bodySmall,
        ),
        Text(
          'Categories: ${controller.categories.length}',
          style: Get.textTheme.bodySmall,
        ),
        Text(
          'My Courses: ${controller.teacherCourses.length}',
          style: Get.textTheme.bodySmall,
        ),
      ],
    ),
  );
}

int min(int a, int b) => a < b ? a : b;

  Widget _buildMyCoursesTab(LearningCenterController controller) {
    return Obx(() {
      final teacherCourses = controller.teacherCourses;
      
      if (controller.isLoading && teacherCourses.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (teacherCourses.isEmpty) {
        return EmptyStateWidget(
          icon: Iconsax.book,
          title: 'No Registered Courses',
          message: 'Register for courses to track your progress here',
          actionText: 'Browse Courses',
          onAction: () => controller.selectTab(3), // Switch to Browse tab
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await controller.refresh(),
        child: ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: teacherCourses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final teacherCourse = teacherCourses[index];
            final course = teacherCourse.course;
            
            return CourseCard(
              course: course,
              isRegistered: true,
              showProgress: true,
              progress: teacherCourse.overallProgress,
              onTap: () {
                Get.to(
                  () => CourseDetailScreen(
                    course: course,
                    teacherCourse: teacherCourse,
                  ),
                );
              },
              onViewProgress: () {
                _showProgressDialog(teacherCourse, controller);
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildCategoriesTab(LearningCenterController controller) {
  return Column(
    children: [
      // Category filter chips
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CategoryChip(
                label: 'All Courses',
                isSelected: controller.selectedCategory.isEmpty,
                onTap: () => controller.selectCategory(''),
                count: controller.allCourses.length,
              ),
              ...controller.categories.map((category) {
                final courseCount = controller.getCoursesByCategory(category).length;
                return CategoryChip(
                  label: category,
                  isSelected: controller.selectedCategory == category,
                  onTap: () => controller.selectCategory(category),
                  count: courseCount,
                );
              }).toList(),
            ],
          ),
        ),
      ),
      
      // Courses in selected category
      Expanded(
        child: _buildCourseGrid(
          courses: controller.filteredCourses,
          controller: controller,
          showRegisterButton: true,
        ),
      ),
    ],
  );
}

  Widget _buildAllCoursesTab(LearningCenterController controller) {
  return Column(
    children: [
      // Filter chips
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CategoryChip(
                label: 'All',
                isSelected: controller.selectedCategory.isEmpty,
                onTap: () => controller.selectCategory(''),
                count: controller.allCourses.length,
              ),
              CategoryChip(
                label: 'Beginner',
                isSelected: false,
                onTap: () {
                  // You can add filtering logic here
                },
                color: Colors.green,
                count: controller.beginnerCourses.length,
              ),
              CategoryChip(
                label: 'Intermediate',
                isSelected: false,
                onTap: () {
                  // You can add filtering logic here
                },
                color: Colors.orange,
                count: controller.intermediateCourses.length,
              ),
              CategoryChip(
                label: 'Advanced',
                isSelected: false,
                onTap: () {
                  // You can add filtering logic here
                },
                color: Colors.red,
                count: controller.advancedCourses.length,
              ),
              CategoryChip(
                label: 'Free',
                isSelected: false,
                onTap: () {
                  // You can add filtering logic here
                },
                color: Colors.blue,
                count: controller.freeCourses.length,
              ),
              CategoryChip(
                label: 'Paid',
                isSelected: false,
                onTap: () {
                  // You can add filtering logic here
                },
                color: Colors.purple,
                count: controller.paidCourses.length,
              ),
            ],
          ),
        ),
      ),
      
      // All courses grid
      Expanded(
        child: _buildCourseGrid(
          courses: controller.filteredCourses,
          controller: controller,
          showRegisterButton: true,
        ),
      ),
    ],
  );
}

  Widget _buildCourseSection({
    required String title,
    required String subtitle,
    required List<Course> courses,
    required LearningCenterController controller,
    bool isHorizontal = false,
  }) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        
        if (isHorizontal)
          SizedBox(
            height: 350,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final course = courses[index];
                final isRegistered = controller.isRegisteredForCourse(course.id);
                
                return FeaturedCourseCard(
                  course: course,
                  isRegistered: isRegistered,
                  onTap: () {
                    _navigateToCourseDetail(course, controller);
                  },
                  onRegister: isRegistered
                      ? null
                      : () {
                          _registerForCourse(course, controller);
                        },
                );
              },
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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
                onRegister: isRegistered
                    ? null
                    : () {
                        _registerForCourse(course, controller);
                      },
              );
            },
          ),
        
        const SizedBox(height: 32),
      ],
    );
  }

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