import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/affairs/controllers/affairs_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/affairs/screens/pages/create_announcement_page.dart';

// Announcements List Page
class AnnouncementsListPage extends StatelessWidget {
  AnnouncementsListPage({super.key});

  final AffairsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Announcements',
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
            subtitle: 'Post your first announcement',
            onAction: () => Get.to(() => CreateAnnouncementPage()),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.announcements.length,
          itemBuilder: (context, index) {
            final announcement = controller.announcements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _AnnouncementListCard(announcement: announcement),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CreateAnnouncementPage()),
        backgroundColor: Colors.purple.shade800,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Post Announcement'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementListCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementListCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              if (announcement.isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  announcement.title,
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
              Text(
                announcement.formattedTargets,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                announcement.timeAgo,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
