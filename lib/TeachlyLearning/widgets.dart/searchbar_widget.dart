import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/TeachlyLearning/learning_center_controller.dart';

class SearchBarWidget extends StatelessWidget {
  final LearningCenterController controller;

  const SearchBarWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.search_normal,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed('/search'),
              child: Text(
                controller.searchQuery.isNotEmpty
                    ? controller.searchQuery
                    : 'Search courses, topics, or instructors...',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: controller.searchQuery.isNotEmpty
                      ? Get.theme.colorScheme.onSurface
                      : Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (controller.searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                controller.endSearch();
              },
              icon: Icon(
                Iconsax.close_circle,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}