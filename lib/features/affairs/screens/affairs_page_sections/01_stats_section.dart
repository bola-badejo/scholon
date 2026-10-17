part of '../affairs_page.dart';

// AffairsMainScreen: _buildStatsSection, _buildQuickActions, _buildNewsSection, _buildEventsSection, _buildPollsSection, _buildAnnouncementsSection, _buildStatItem, _buildLoadingShimmer, _buildEmptyState
extension _AffairsMainScreenSection01 on AffairsMainScreen {
  SliverToBoxAdapter _buildStatsSection(AffairsController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.article_rounded,
                value: controller.totalNews.value.toString(),
                label: 'News',
                color: Colors.blue,
              ),
              _buildStatItem(
                icon: Icons.event_rounded,
                value: controller.totalEvents.value.toString(),
                label: 'Events',
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.poll_rounded,
                value: controller.totalPolls.value.toString(),
                label: 'Polls',
                color: Colors.orange,
              ),
              _buildStatItem(
                icon: Icons.announcement_rounded,
                value: controller.totalAnnouncements.value.toString(),
                label: 'Announcements',
                color: Colors.purple,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  SliverToBoxAdapter _buildQuickActions(AffairsController controller) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (!controller.canCreateContent) return const SliverToBoxAdapter(child: SizedBox());
        
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickActionCard(
                      icon: Icons.add_rounded,
                      label: 'Create News',
                      color: Colors.blue,
                      onTap: () => Get.to(() => CreateNewsPage()),
                    ),
                    _QuickActionCard(
                      icon: Icons.event_rounded,
                      label: 'Schedule Event',
                      color: Colors.green,
                      onTap: () => Get.to(() => CreateEventPage()),
                    ),
                    _QuickActionCard(
                      icon: Icons.poll_rounded,
                      label: 'Create Poll',
                      color: Colors.orange,
                      onTap: () => Get.to(() => CreatePollPage()),
                    ),
                    _QuickActionCard(
                      icon: Icons.announcement_rounded,
                      label: 'Post Announcement',
                      color: Colors.purple,
                      onTap: () => Get.to(() => CreateAnnouncementPage()),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0, delay: 100.ms),
          ),
        );
      }),
    );
  }

  SliverToBoxAdapter _buildNewsSection(AffairsController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest News',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => NewsListPage()),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoadingNews.value && controller.newsPosts.isEmpty) {
                return _buildLoadingShimmer();
              }
              
              if (controller.newsPosts.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.article_rounded,
                  title: 'No news yet',
                  subtitle: 'Check back later for updates',
                  actionText: controller.canCreateContent ? 'Create News' : null,
                  onAction: controller.canCreateContent ? () => Get.to(() => CreateNewsPage()) : null,
                );
              }

              return Column(
                children: controller.newsPosts.take(3).map((news) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NewsCard(news: news, controller: controller),
                  );
                }).toList(),
              );
            }),
          ],
        ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0, delay: 200.ms),
      ),
    );
  }

  SliverToBoxAdapter _buildEventsSection(AffairsController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => EventsListPage()),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.events.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.event_rounded,
                  title: 'No events scheduled',
                  subtitle: 'No upcoming events',
                  actionText: controller.canCreateContent ? 'Schedule Event' : null,
                  onAction: controller.canCreateContent ? () => Get.to(() => CreateEventPage()) : null,
                  compact: true,
                );
              }

              return Column(
                children: controller.events.take(2).map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EventCard(event: event, controller: controller),
                  );
                }).toList(),
              );
            }),
          ],
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0, delay: 300.ms),
      ),
    );
  }

  SliverToBoxAdapter _buildPollsSection(AffairsController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Polls',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => PollsListPage()),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.polls.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.poll_rounded,
                  title: 'No active polls',
                  subtitle: 'No polls available',
                  actionText: controller.canCreateContent ? 'Create Poll' : null,
                  onAction: controller.canCreateContent ? () => Get.to(() => CreatePollPage()) : null,
                  compact: true,
                );
              }

              return Column(
                children: controller.polls.take(2).map((poll) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PollCard(poll: poll, controller: controller),
                  );
                }).toList(),
              );
            }),
          ],
        ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.2, end: 0, delay: 400.ms),
      ),
    );
  }

  SliverToBoxAdapter _buildAnnouncementsSection(AffairsController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Announcements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => AnnouncementsListPage()),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.announcements.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.announcement_rounded,
                  title: 'No announcements',
                  subtitle: 'No announcements available',
                  actionText: controller.canCreateContent ? 'Post Announcement' : null,
                  onAction: controller.canCreateContent ? () => Get.to(() => CreateAnnouncementPage()) : null,
                  compact: true,
                );
              }

              return Column(
                children: controller.announcements.take(2).map((announcement) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AnnouncementCard(announcement: announcement, controller: controller),
                  );
                }).toList(),
              );
            }),
          ],
        ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.2, end: 0, delay: 500.ms),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String? actionText,
    required VoidCallback? onAction,
    bool compact = false,
  }) {
    return Container(
      width: double.infinity,
      padding: compact ? const EdgeInsets.all(16) : const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, size: compact ? 40 : 56, color: Colors.grey.shade300),
          SizedBox(height: compact ? 8 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            SizedBox(height: compact ? 12 : 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(actionText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
