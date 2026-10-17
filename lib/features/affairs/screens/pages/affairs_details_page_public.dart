import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';

export 'package:isapp/features/affairs/screens/pages/public_announcements_list_page.dart';
export 'package:isapp/features/affairs/screens/pages/public_events_list_page.dart';
export 'package:isapp/features/affairs/screens/pages/public_news_detail_page.dart';
export 'package:isapp/features/affairs/screens/pages/public_news_list_page.dart';
export 'package:isapp/features/affairs/screens/pages/public_poll_detail_page.dart';
export 'package:isapp/features/affairs/screens/pages/public_polls_list_page.dart';

// Public Event Detail Page
class PublicEventDetailPage extends StatelessWidget {
  final Event event;
  final String userType;

  const PublicEventDetailPage({super.key, required this.event, required this.userType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffairsPublicController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: event.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_rounded, size: 40, color: event.status.color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title.isNotEmpty ? event.title : 'Untitled Event',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.category.isNotEmpty ? event.category : 'General',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Event Details
            const Text(
              'Event Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.calendar_today_rounded,
              title: 'Date & Time',
              value: event.formattedDate.isNotEmpty ? event.formattedDate : 'Not specified',
            ),
            const SizedBox(height: 12),
            
            _DetailItem(
              icon: Icons.location_on_rounded,
              title: 'Location',
              value: event.location.isNotEmpty ? event.location : 'Not specified',
            ),
            const SizedBox(height: 12),
            
            _DetailItem(
              icon: Icons.person_rounded,
              title: 'Organizer',
              value: event.organizerName.isNotEmpty ? event.organizerName : 'School Admin',
            ),
            
            const SizedBox(height: 24),
            
            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              event.description.isNotEmpty ? event.description : 'No description available',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Registration Info
            if (event.requiresRegistration)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: event.registrationProgress,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.green,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${event.registeredCount} registered',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${event.maxAttendees} total',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (event.canRegister && userType != 'parent') // Parents can't register for students
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _registerForEvent(controller, event),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            userType == 'student' ? 'Register Now' : 'Register Student',
                          ),
                        ),
                      ),
                    if (userType == 'parent')
                      const Text(
                        'Please ask your child to register through their account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _registerForEvent(AffairsPublicController controller, Event event) async {
    try {
      await controller.registerForEvent(event.id);
      Get.snackbar(
        'Success',
        'Registered for ${event.title}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Public Announcement Detail Page
class PublicAnnouncementDetailPage extends StatelessWidget {
  final Announcement announcement;
  final String userType;

  const PublicAnnouncementDetailPage({
    super.key,
    required this.announcement,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffairsPublicController>();
    final userTypeColor = _getUserTypeColor(userType);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Announcement',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Announcement Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: announcement.isUrgent 
                    ? Colors.red.shade50 
                    : Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.announcement_rounded,
                    size: 40,
                    color: announcement.isUrgent ? Colors.red : Colors.purple,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.title.isNotEmpty ? announcement.title : 'Announcement',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (announcement.isUrgent) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Target Audience
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Target Audience',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final target in announcement.targets)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: userTypeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getTargetDisplayName(target),
                            style: TextStyle(
                              fontSize: 12,
                              color: userTypeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Announcement Details
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.calendar_today_rounded,
              title: 'Posted',
              value: announcement.timeAgo.isNotEmpty ? announcement.timeAgo : 'Recently',
            ),
            const SizedBox(height: 12),
            
            _DetailItem(
              icon: Icons.person_rounded,
              title: 'Posted By',
              value: announcement.authorName.isNotEmpty ? announcement.authorName : 'School Admin',
            ),
            
            const SizedBox(height: 24),
            
            // Content
            const Text(
              'Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                announcement.content.isNotEmpty ? announcement.content : 'No content available',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'student': return Colors.purple;
      case 'teacher': return Colors.blue;
      case 'parent': return Colors.deepOrange;
      case 'schoolAdmin': return Colors.green;
      default: return Colors.blue;
    }
  }

  String _getTargetDisplayName(String target) {
    switch (target) {
      case 'all': return 'All Users';
      case 'students': return 'Students';
      case 'teachers': return 'Teachers';
      case 'parents': return 'Parents';
      case 'specificGrade': return 'Specific Grade';
      case 'specificClass': return 'Specific Class';
      default: return target;
    }
  }
}
