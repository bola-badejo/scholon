part of '../affairs_page_public.dart';

// _AffairsPublicMainScreenState: _buildAppBar, _buildUserWelcomeSection, _buildQuickStats, _buildNewsSection, _buildEventsSection, _buildPollsSection
extension AffairsPublicMainScreenStateSection01 on _AffairsPublicMainScreenState {
  SliverAppBar _buildAppBar(String userType, String schoolName) {
    final appBarColor = _getUserTypeColor(userType);

    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: appBarColor,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.3,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getAppBarTitle(userType),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              schoolName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildUserWelcomeSection(
    String userType,
    String userName,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getUserTypeColor(userType),
                _getUserTypeColor(userType).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getUserTypeColor(userType).withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty
                        ? userName.substring(0, 1).toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getUserTypeColor(userType),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getUserTypeDisplay(userType),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'School Affairs',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  SliverToBoxAdapter _buildQuickStats(
    AffairsPublicController controller,
    String userType,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:
            Container(
                  padding: const EdgeInsets.all(16),
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
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 100.ms),
      ),
    );
  }

  SliverToBoxAdapter _buildNewsSection(
    AffairsPublicController controller,
    String userType,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child:
            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'School News',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.to(
                            () => PublicNewsListPage(userType: userType),
                          ),
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.isLoadingNews.value &&
                          controller.newsPosts.isEmpty) {
                        return _buildLoadingShimmer();
                      }

                      if (controller.newsPosts.isEmpty) {
                        return _buildEmptyState(
                          icon: Icons.article_rounded,
                          title: 'No news yet',
                          subtitle: 'Check back later for school news',
                          color: Colors.blue,
                          compact: true,
                        );
                      }

                      return Column(
                        children: controller.newsPosts.take(3).map((news) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PublicNewsCard(
                              news: news,
                              userType: userType,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                )
                .animate()
                .fadeIn(duration: 700.ms)
                .slideY(begin: 0.2, end: 0, delay: 200.ms),
      ),
    );
  }

  SliverToBoxAdapter _buildEventsSection(
    AffairsPublicController controller,
    String userType,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child:
            Column(
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
                        IconButton(
                          onPressed: () => Get.to(
                            () => PublicEventsListPage(userType: userType),
                          ),
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.green,
                              size: 20,
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
                          title: 'No upcoming events',
                          subtitle: 'Check back later for school events',
                          color: Colors.green,
                          compact: true,
                        );
                      }

                      return Column(
                        children: controller.events.take(2).map((event) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PublicEventCard(
                              event: event,
                              userType: userType,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.2, end: 0, delay: 300.ms),
      ),
    );
  }

  SliverToBoxAdapter _buildPollsSection(
    AffairsPublicController controller,
    String userType,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child:
            Column(
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
                        IconButton(
                          onPressed: () => Get.to(
                            () => PublicPollsListPage(userType: userType),
                          ),
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.orange,
                              size: 20,
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
                          subtitle: 'Check back later for school polls',
                          color: Colors.orange,
                          compact: true,
                        );
                      }

                      return Column(
                        children: controller.polls.take(2).map((poll) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PublicPollCard(
                              poll: poll,
                              userType: userType,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                )
                .animate()
                .fadeIn(duration: 900.ms)
                .slideY(begin: 0.2, end: 0, delay: 400.ms),
      ),
    );
  }
}
