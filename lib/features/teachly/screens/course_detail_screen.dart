import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/features/teachly/controllers/learning_center_controller.dart';
import 'package:isapp/features/teachly/models/course_data.dart';
import 'package:isapp/features/teachly/models/teacher_course.dart';

part 'course_detail_screen_sections/01_instructor_info.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  final TeacherCourse? teacherCourse;

  const CourseDetailScreen({
    Key? key,
    required this.course,
    this.teacherCourse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LearningCenterController>();
    final isRegistered = teacherCourse != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with course image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                course.banner.isNotEmpty ? course.banner : course.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Get.theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Iconsax.book,
                      size: 64,
                      color: Get.theme.colorScheme.primary,
                    ),
                  );
                },
              ),
              title: Text(
                course.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Course details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course title and subtitle
                  Text(
                    course.title,
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.subtitle,
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress bar (if registered)
                  if (isRegistered && teacherCourse != null)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Your Progress',
                                    style: Get.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Get.theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    teacherCourse!.progressText,
                                    style: Get.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Get.theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: teacherCourse!.overallProgress,
                                backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.2),
                                color: Get.theme.colorScheme.primary,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              if (teacherCourse!.estimatedTimeRemaining != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Estimated completion: ${teacherCourse!.estimatedTimeRemaining}',
                                    style: Get.textTheme.labelSmall?.copyWith(
                                      color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  
                  // Instructor info
                  _buildInstructorInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // Course details grid
                  _buildDetailsGrid(),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  _buildSection(
                    title: 'Description',
                    child: Text(
                      course.longDescription,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Learning outcomes
                  _buildSection(
                    title: 'What You\'ll Learn',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: course.learningOutcomes
                          .map((outcome) => _buildBulletPoint(outcome))
                          .toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Target audience
                  _buildSection(
                    title: 'Who This Course Is For',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: course.targetAudience
                          .map((audience) => Chip(
                                label: Text(audience),
                                backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                                labelStyle: Get.textTheme.labelMedium?.copyWith(
                                  color: Get.theme.colorScheme.primary,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Prerequisites
                  if (course.prerequisites.isNotEmpty)
                    Column(
                      children: [
                        _buildSection(
                          title: 'Prerequisites',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: course.prerequisites
                                .map((prereq) => _buildBulletPoint(prereq, icon: Iconsax.tick_circle))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  
                  // Features
                  _buildSection(
                    title: 'Course Features',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: course.features
                          .map((feature) => Chip(
                                label: Text(feature),
                                backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
                                labelStyle: Get.textTheme.labelMedium?.copyWith(
                                  color: Get.theme.colorScheme.secondary,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  
                  // Certification info
                  if (course.certification.available)
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildSection(
                          title: 'Certification',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Get.theme.colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.verify,
                                      color: Get.theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      course.certification.type,
                                      style: Get.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Get.theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Issued by: ${course.certification.issuer}',
                                  style: Get.textTheme.bodyMedium,
                                ),
                                if (course.certification.accreditation != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Accreditation: ${course.certification.accreditation}',
                                      style: Get.textTheme.bodySmall?.copyWith(
                                        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom action buttons
      bottomNavigationBar: _buildBottomButtons(controller, isRegistered),
    );
  }
  

  

  

  

  

  

  
  void _startLearning(LearningCenterController controller) {
    Get.snackbar(
      'Course Content',
      'Course learning interface would open here',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Colors.white,
    );
  }
  
  void _registerForCourse(LearningCenterController controller) {
    Get.defaultDialog(
      title: 'Register for Course',
      middleText: 'Are you sure you want to register for "${course.title}"?',
      textConfirm: 'Register',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await controller.registerForCourse(course);
        Get.back(); // Go back to learning center
      },
    );
  }
}