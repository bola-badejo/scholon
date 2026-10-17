import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/affairs/screens/pages/affairs_details_page_public.dart';

// Public Events List Page
class PublicEventsListPage extends StatelessWidget {
  final String userType;

  const PublicEventsListPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffairsPublicController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'School Events',
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
        if (controller.events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_rounded,
            title: 'No events',
            subtitle: 'Check back later for school events',
            color: Colors.green,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PublicEventListCard(event: event, userType: userType),
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

class _PublicEventListCard extends StatelessWidget {
  final Event event;
  final String userType;

  const _PublicEventListCard({required this.event, required this.userType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PublicEventDetailPage(event: event, userType: userType)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: event.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event_rounded, color: event.status.color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title.isNotEmpty ? event.title : 'Untitled Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.formattedDate.isNotEmpty ? event.formattedDate : 'Date not set',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        event.location.isNotEmpty ? event.location : 'Location not set',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: event.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.status.displayName.isNotEmpty ? event.status.displayName : 'Upcoming',
                style: TextStyle(
                  fontSize: 12,
                  color: event.status.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
