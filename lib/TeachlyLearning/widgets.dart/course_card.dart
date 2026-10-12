import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/TeachlyLearning/model/course_data.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isRegistered;
  final VoidCallback? onTap;
  final VoidCallback? onRegister;
  final VoidCallback? onViewProgress;
  final bool showProgress;
  final double? progress;

  const CourseCard({
    Key? key,
    required this.course,
    this.isRegistered = false,
    this.onTap,
    this.onRegister,
    this.onViewProgress,
    this.showProgress = false,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course image and badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      course.image,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.book,
                            size: 48,
                            color: Get.theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Badges
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        if (course.isFeatured)
                          _buildBadge('Featured', Colors.amber),
                        if (course.isNew)
                          _buildBadge('New', Colors.green),
                        if (course.isFree)
                          _buildBadge('Free', Colors.blue),
                      ],
                    ),
                  ),
                  
                  // Difficulty badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: course.difficultyColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.difficultyText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Course title
              Text(
                course.title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Instructor
              Row(
                children: [
                  Icon(
                    Iconsax.teacher,
                    size: 14,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course.instructor.name,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Rating and duration
              Row(
                children: [
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Iconsax.star1,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        course.rating.toStringAsFixed(1),
                        style: Get.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${course.totalRatings})',
                        style: Get.textTheme.labelSmall?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Duration
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 14,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.durationText,
                        style: Get.textTheme.labelSmall?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Progress bar (if showProgress is true and progress is provided)
              if (showProgress && progress != null)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                      color: Get.theme.colorScheme.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress! * 100).toInt()}% Complete',
                          style: Get.textTheme.labelSmall?.copyWith(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          course.durationText,
                          style: Get.textTheme.labelSmall?.copyWith(
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              
              // Price and enrollment
              Row(
                children: [
                  // Price
                  if (course.hasDiscount)
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              course.formattedPrice,
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Get.theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                        Text(
                          course.originalPrice,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                          ],
                        ),
                        
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${course.discountPercentage.toStringAsFixed(0)}%',
                            style: Get.textTheme.labelSmall?.copyWith(
                              color: Get.theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      course.formattedPrice,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: course.isFree 
                            ? Get.theme.colorScheme.secondary 
                            : Get.theme.colorScheme.primary,
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Enrollment
                  Row(
                    children: [
                      Icon(
                        Iconsax.people,
                        size: 14,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatEnrollment(course.enrollmentCount),
                        style: Get.textTheme.labelSmall?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              if (showProgress && isRegistered)
                _buildProgressButton()
              else if (isRegistered)
                _buildRegisteredButton()
              else
                _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          'Register',
          style: Get.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildRegisteredButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Get.theme.colorScheme.primary,
          side: BorderSide(color: Get.theme.colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          'View Course',
          style: Get.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onViewProgress,
        icon: Icon(
          Iconsax.trend_up,
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          'Continue Learning',
          style: Get.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
  
  String _formatEnrollment(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}