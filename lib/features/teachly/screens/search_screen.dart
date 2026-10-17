import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/features/teachly/screens/course_detail_screen.dart';
import 'package:isapp/features/teachly/controllers/learning_center_controller.dart';
import 'package:isapp/features/teachly/widgets/course_card.dart';
import 'package:isapp/features/teachly/widgets/empty_page.dart';

class SearchScreenCourses extends StatefulWidget {
  SearchScreenCourses({Key? key}) : super(key: key);

  @override
  State<SearchScreenCourses> createState() => _SearchScreenCoursesState();
}

class _SearchScreenCoursesState extends State<SearchScreenCourses> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LearningCenterController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Iconsax.arrow_left),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search courses, topics, instructors...',
            border: InputBorder.none,
            hintStyle: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          style: Get.textTheme.bodyMedium,
          onChanged: (value) {
            controller.updateSearchQuery(value);
            if (value.isNotEmpty) {
              controller.performSearch();
            }
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              controller.performSearch();
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                controller.updateSearchQuery('');
                controller.performSearch();
              },
              icon: const Icon(Iconsax.close_circle),
            ),
        ],
      ),
      body: Obx(() {
        final isLoading = controller.isLoading;
        final searchResults = controller.searchResults;
        final searchQuery = controller.searchQuery;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchQuery.isEmpty) {
          return EmptyStateWidget(
            icon: Iconsax.search_normal,
            title: 'Start Searching',
            message: 'Enter keywords to find courses',
          );
        }

        if (searchResults.isEmpty) {
          return EmptyStateWidget(
            icon: Iconsax.search_status,
            title: 'No Results Found',
            message: 'Try different keywords or browse categories',
            actionText: 'Browse All Courses',
            onAction: () {
              Get.back();
              controller.selectTab(3); // Browse tab
            },
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: searchResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final course = searchResults[index];
            final isRegistered = controller.isRegisteredForCourse(course.id);

            return CourseCard(
              course: course,
              isRegistered: isRegistered,
              onTap: () {
                Get.to(
                  () => CourseDetailScreen(
                    course: course,
                    teacherCourse: controller.getTeacherCourse(course.id),
                  ),
                );
              },
              onRegister: isRegistered
                  ? null
                  : () {
                      controller.registerForCourse(course);
                    },
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}