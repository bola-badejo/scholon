part of '../course_detail_screen.dart';

// CourseDetailScreen: _buildInstructorInfo, _buildDetailsGrid, _buildDetailItem, _buildSection, _buildBulletPoint, _buildBottomButtons
extension _CourseDetailScreenSection01 on CourseDetailScreen {
  Widget _buildInstructorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Instructor image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(course.instructor.image),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle error
                },
              ),
              border: Border.all(
                color: Get.theme.colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Instructor details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructor',
                  style: Get.textTheme.labelSmall?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course.instructor.name,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course.instructor.bio,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      course.instructor.rating.toStringAsFixed(1),
                      style: Get.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${course.instructor.coursesTaught} courses)',
                      style: Get.textTheme.labelSmall?.copyWith(
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
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
  }

  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3,
      children: [
        _buildDetailItem(
          icon: Iconsax.clock,
          title: 'Duration',
          value: course.durationText,
        ),
        _buildDetailItem(
          icon: Iconsax.cpu,
          title: 'Difficulty',
          value: course.difficultyText,
          color: course.difficultyColor,
        ),
        _buildDetailItem(
          icon: Iconsax.people,
          title: 'Enrolled',
          value: '${course.enrollmentCount}+',
        ),
        _buildDetailItem(
          icon: Iconsax.global,
          title: 'Language',
          value: course.language,
        ),
        _buildDetailItem(
          icon: Iconsax.award,
          title: 'Rating',
          value: course.rating.toStringAsFixed(1),
          iconColor: Colors.amber,
        ),
        _buildDetailItem(
          icon: Iconsax.category,
          title: 'Category',
          value: course.category,
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? color ?? Get.theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Get.textTheme.labelSmall?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color ?? Get.theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildBulletPoint(String text, {IconData icon = Iconsax.tick_circle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Icon(icon, size: 16, color: Get.theme.colorScheme.primary),
          ),
          Expanded(
            child: Text(
              text,
              style: Get.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(LearningCenterController controller, bool isRegistered) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Price
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.hasDiscount)
                  Row(
                    children: [
                      Text(
                        course.formattedPrice,
                        style: Get.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        course.originalPrice,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    course.formattedPrice,
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: course.isFree 
                          ? Get.theme.colorScheme.secondary 
                          : Get.theme.colorScheme.primary,
                    ),
                  ),
                if (course.hasDiscount)
                  Text(
                    '${course.discountPercentage.toStringAsFixed(0)}% OFF',
                    style: Get.textTheme.labelSmall?.copyWith(
                      color: Get.theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Action button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (isRegistered) {
                  // Navigate to course learning interface
                  _startLearning(controller);
                } else {
                  // Register for course
                  _registerForCourse(controller);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRegistered 
                    ? Get.theme.colorScheme.secondary 
                    : Get.theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRegistered ? Iconsax.play : Iconsax.add,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRegistered ? 'Continue Learning' : 'Register Now',
                    style: Get.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
