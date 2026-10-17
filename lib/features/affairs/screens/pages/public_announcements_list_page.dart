import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/affairs/screens/pages/affairs_details_page_public.dart';

// Public Announcements List Page
class PublicAnnouncementsListPage extends StatelessWidget {
  final String userType;

  const PublicAnnouncementsListPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffairsPublicController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Obx(() {
        if (controller.announcements.isEmpty) {
          return _buildEmptyState(
            icon: Icons.announcement_rounded,
            title: 'No announcements',
            subtitle: 'Check back later for school announcements',
            color: Colors.purple,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.announcements.length,
          itemBuilder: (context, index) {
            final announcement = controller.announcements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PublicAnnouncementListCard(announcement: announcement, userType: userType,),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicAnnouncementListCard extends StatelessWidget {
  final Announcement announcement;
  final String userType;

  const _PublicAnnouncementListCard({
    required this.announcement,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PublicAnnouncementDetailPage(
        announcement: announcement,
        userType: userType,
      )),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: announcement.isUrgent ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: announcement.isUrgent ? Colors.red.shade100 : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: announcement.isUrgent ? Colors.red.shade100 : Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.announcement_rounded,
                    color: announcement.isUrgent ? Colors.red : Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (announcement.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          if (announcement.isUrgent) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              announcement.title.isNotEmpty ? announcement.title : 'Announcement',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcement.timeAgo.isNotEmpty ? announcement.timeAgo : 'Recently',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.content.length > 150
                  ? '${announcement.content.substring(0, 150)}...'
                  : announcement.content,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.group_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    announcement.formattedTargets.isNotEmpty 
                        ? announcement.formattedTargets 
                        : 'All users',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
