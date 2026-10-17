part of '../learning_center_screen.dart';

// LearningCenterScreen: _buildStatCard, _buildLoadingState, _buildErrorState, _buildNoCoursesState, _buildDebugInfo, _buildMyCoursesTab, _buildCategoriesTab, _buildAllCoursesTab, _buildCourseSection
extension _LearningCenterScreenSection02 on LearningCenterScreen {
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
}
