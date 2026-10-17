import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:isapp/features/affairs/controllers/affairs_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/affairs/screens/pages/affairs_details_page.dart';
import 'package:isapp/features/affairs/screens/pages/create_announcement_page.dart';
import 'package:isapp/features/affairs/screens/pages/create_event_page.dart';
import 'package:isapp/features/affairs/screens/pages/create_news_page.dart';
import 'package:isapp/features/affairs/screens/pages/create_poll_page.dart';

part 'affairs_page_sections/01_stats_section.dart';
part 'affairs_page_sections/02_floating_action_button.dart';

class AffairsMainScreen extends StatelessWidget {
  AffairsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AffairsController>(
      init: AffairsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Obx(() {
              if (controller.currentUser.value == null) {
                return const Text(
                  'Affairs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Affairs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    controller.currentUser.value!.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }),
            backgroundColor: Colors.white,
            elevation: 1,
            foregroundColor: Colors.black87,
            actions: [
              IconButton(
                onPressed: () => controller.refreshAll(),
                icon: const Icon(Icons.refresh_rounded, size: 24),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isInitializing.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (!controller.canView.value) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No School Access',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'You need to be associated with a school to view affairs.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () => controller.refreshAll(),
              child: CustomScrollView(
                slivers: [
                  _buildStatsSection(controller),
                  _buildQuickActions(controller),
                  _buildNewsSection(controller),
                  _buildEventsSection(controller),
                  _buildPollsSection(controller),
                  _buildAnnouncementsSection(controller),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          }),
          floatingActionButton: Obx(() {
            if (!controller.canCreateContent) return const SizedBox();
            return _buildFloatingActionButton(controller);
          }),
        );
      },
    );
  }

}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (Get.width - 64) / 2,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
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

class _NewsCard extends StatelessWidget {
  final NewsPost news;
  final AffairsController controller;

  const _NewsCard({required this.news, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.recordNewsView(news.id);
        Get.to(() => NewsDetailPage(news: news));
      },
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        news.authorName,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        controller.getTimeAgo(news.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

class _EventCard extends StatelessWidget {
  final Event event;
  final AffairsController controller;

  const _EventCard({required this.event, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => EventDetailPage(event: event)),
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
              child: const Icon(Icons.event_rounded, color: Colors.green, size: 30),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          controller.getFormattedDate(event.startDate),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                        event.location,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (event.requiresRegistration)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: event.canRegister ? Colors.green.shade50 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${event.registeredCount}/${event.maxAttendees}',
                  style: TextStyle(
                    fontSize: 12,
                    color: event.canRegister ? Colors.green : Colors.grey,
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

class _PollCard extends StatelessWidget {
  final Poll poll;
  final AffairsController controller;

  const _PollCard({required this.poll, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PollDetailPage(poll: poll)),
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
                  child: const Icon(Icons.poll_rounded, color: Colors.orange, size: 22),
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
            if (poll.options.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${poll.options.length - 2} more options',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${poll.totalVotes} votes',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  poll.isExpired ? 'Ended' : 'Ends ${poll.endDate.day}/${poll.endDate.month}',
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

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final AffairsController controller;

  const _AnnouncementCard({required this.announcement, required this.controller});

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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: announcement.isUrgent ? Colors.red.shade100 : Colors.purple.shade50,
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
                    Icon(Icons.group_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      announcement.formattedTargets,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    Text(
                      controller.getTimeAgo(announcement.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

class _QuickCreateCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCreateCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: (Get.width - 64) / 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}