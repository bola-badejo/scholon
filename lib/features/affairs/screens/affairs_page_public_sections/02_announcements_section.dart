part of '../affairs_page_public.dart';

// _AffairsPublicMainScreenState: _buildAnnouncementsSection, _buildStatItem, _buildLoadingShimmer, _buildEmptyState
extension AffairsPublicMainScreenStateSection02 on _AffairsPublicMainScreenState {
  SliverToBoxAdapter _buildAnnouncementsSection(
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
                          'Announcements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.to(
                            () =>
                                PublicAnnouncementsListPage(userType: userType),
                          ),
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.purple,
                              size: 20,
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
                          subtitle: 'Check back later for school announcements',
                          color: Colors.purple,
                          compact: true,
                        );
                      }

                      return Column(
                        children: controller.announcements.take(2).map((
                          announcement,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PublicAnnouncementCard(
                              announcement: announcement,
                              userType: userType,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 80),
                  ],
                )
                .animate()
                .fadeIn(duration: 1000.ms)
                .slideY(begin: 0.2, end: 0, delay: 500.ms),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool compact = false,
  }) {
    return Container(
      width: double.infinity,
      padding: compact ? const EdgeInsets.all(16) : const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: compact ? 40 : 48, color: color.withOpacity(0.3)),
          SizedBox(height: compact ? 8 : 12),
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
        ],
      ),
    );
  }
}
