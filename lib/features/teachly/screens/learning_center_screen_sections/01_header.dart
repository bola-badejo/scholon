part of '../learning_center_screen.dart';

// LearningCenterScreen: _buildHeader, _buildSearchBar, _buildTabBar, _buildHomeTab, _buildWelcomeSection, _buildAllCategoriesSection, _buildQuickStats
extension _LearningCenterScreenSection01 on LearningCenterScreen {
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
}
