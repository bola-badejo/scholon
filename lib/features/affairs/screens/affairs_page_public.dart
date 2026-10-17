import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/affairs/screens/pages/affairs_details_page_public.dart';

part 'affairs_page_public_sections/01_app_bar.dart';
part 'affairs_page_public_sections/02_announcements_section.dart';

class AffairsPublicMainScreen extends StatefulWidget {
  const AffairsPublicMainScreen({super.key});

  @override
  State<AffairsPublicMainScreen> createState() =>
      _AffairsPublicMainScreenState();
}

class _AffairsPublicMainScreenState extends State<AffairsPublicMainScreen> {
  final controller = Get.find<AffairsPublicController>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkData();
  }

  Future<void> _checkData() async {
    // Check if controller has necessary data
    if (controller.currentUser.value == null ||
        controller.schoolId.value.isEmpty) {
      Get.snackbar(
        'Data Missing',
        'Please select a school first',
        backgroundColor: Colors.orange,
      );
      await Future.delayed(Duration(seconds: 2));
      Get.back();
      return;
    }

    // Load data if needed
    if (controller.newsPosts.isEmpty &&
        controller.events.isEmpty &&
        controller.polls.isEmpty) {
      await controller.refreshAll();
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading school affairs...'),
            ],
          ),
        ),
      );
    }

    return GetBuilder<AffairsPublicController>(
      builder: (controller) {
        // Use the getters from controller
        final userType = controller.userType;
        final userName = controller.userName;
        final schoolName = controller.schoolName;

        // Validate data
        // if (controller.currentUser.value == null &&
        //     controller.currentAdmin.value == null) {
        //   return _buildErrorScreen('No user data found');
        // }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: RefreshIndicator(
            onRefresh: () => controller.refreshAll(),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(userType, schoolName),
                _buildUserWelcomeSection(userType, userName),
                _buildQuickStats(controller, userType),
                _buildNewsSection(controller, userType),
                _buildEventsSection(controller, userType),
                _buildPollsSection(controller, userType),
                _buildAnnouncementsSection(controller, userType),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'student':
        return Colors.purple;
      case 'teacher':
        return Colors.blue;
      case 'parent':
        return Colors.deepOrange;
      case 'schoolAdmin':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _getAppBarTitle(String userType) {
    switch (userType) {
      case 'student':
        return 'School Affairs';
      case 'teacher':
        return 'School Affairs';
      case 'parent':
        return 'School Updates';
      case 'schoolAdmin':
        return 'Affairs Management';
      default:
        return 'School Affairs';
    }
  }

  String _getUserTypeDisplay(String userType) {
    switch (userType) {
      case 'student':
        return 'Student';
      case 'teacher':
        return 'Teacher';
      case 'parent':
        return 'Parent';
      case 'schoolAdmin':
        return 'School Administrator';
      default:
        return 'User';
    }
  }

}

// Public Card Widgets
class _PublicNewsCard extends StatelessWidget {
  final NewsPost news;
  final String userType;

  const _PublicNewsCard({required this.news, required this.userType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => PublicNewsDetailPage(news: news, userType: userType)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
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
            if (news.hasImages)
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(news.imageUrls.first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEWS',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        news.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.content.length > 150
                        ? '${news.content.substring(0, 150)}...'
                        : news.content,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news.authorName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.visibility_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${news.views} views',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicEventCard extends StatelessWidget {
  final Event event;
  final String userType;

  const _PublicEventCard({required this.event, required this.userType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => PublicEventDetailPage(event: event, userType: userType)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event_rounded, color: Colors.green, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
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
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.formattedDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: event.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.status.displayName,
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

class _PublicPollCard extends StatelessWidget {
  final Poll poll;
  final String userType;

  const _PublicPollCard({required this.poll, required this.userType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => PublicPollDetailPage(poll: poll, userType: userType)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
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
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.poll_rounded,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    poll.question,
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
            ...poll.options.take(2).map((option) {
              final percentage = poll.getOptionPercentage(option);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.text,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.orange,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  '${poll.totalVotes} votes',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  poll.isExpired
                      ? 'Ended'
                      : 'Ends ${poll.endDate.day}/${poll.endDate.month}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicAnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final String userType;

  const _PublicAnnouncementCard({
    required this.announcement,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: announcement.isUrgent ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: announcement.isUrgent
              ? Colors.red.shade100
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: announcement.isUrgent
                  ? Colors.red.shade100
                  : Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.announcement_rounded,
              color: announcement.isUrgent ? Colors.red : Colors.purple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (announcement.isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.content.length > 100
                      ? '${announcement.content.substring(0, 100)}...'
                      : announcement.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.group_rounded,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement.formattedTargets,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      announcement.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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
}
