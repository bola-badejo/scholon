part of '../connect_screen.dart';

// ConnectScreen: _buildHeroSection, _buildQuickStats, _buildStatItem, _buildPendingConnections, _buildPendingRequests, _buildConnectionTypes, _buildStudyGroups
extension _ConnectScreenSection01 on ConnectScreen {
  // ========== HERO SECTION ==========
  Widget _buildHeroSection(ConnectController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade600, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with Status
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
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
                    child: Obx(() {
                      final user = controller.currentUser.value;
                      return Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final user = controller.currentUser.value;
                    return Text(
                      user?.name ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  const SizedBox(height: 4),
                  Obx(() {
                    final user = controller.currentUser.value;
                    return Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  const SizedBox(height: 12),
                  Obx(() {
                    final user = controller.currentUser.value;
                    final userType = user?.userType ?? UserType.student;
                    final typeColor = _getUserTypeColor(userType);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getUserTypeIcon(userType),
                            size: 14,
                            color: typeColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            userType.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== QUICK STATS ==========
  Widget _buildQuickStats(ConnectController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
              icon: Icons.people_alt_rounded,
              value: controller.totalConnections.value.toString(),
              label: 'Connections',
              color: Colors.deepPurple,
              onTap: () => _showAllConnections(controller),
            ),
            _buildStatItem(
              icon: Icons.group_rounded,
              value: controller.totalGroups.value.toString(),
              label: 'Groups',
              color: Colors.green,
              onTap: () => _showAllGroups(controller),
            ),
            _buildStatItem(
              icon: Icons.pending_actions_rounded,
              value: controller.totalPending.value.toString(),
              label: 'Pending',
              color: Colors.orange,
              onTap: () => _showPendingConnectionsSheet(controller),
            ),
            _buildStatItem(
              icon: Icons.online_prediction_rounded,
              value: controller.onlineUsers.length.toString(),
              label: 'Online',
              color: Colors.blue,
              onTap: () => _scrollToOnlineUsers(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ========== PENDING CONNECTIONS ==========
  Widget _buildPendingConnections(ConnectController controller) {
    return Obx(() {
      if (controller.pendingConnections.isEmpty) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Connections',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => _showPendingConnectionsSheet(controller),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.pendingConnections.length,
                itemBuilder: (context, index) {
                  final user = controller.pendingConnections[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < controller.pendingConnections.length - 1
                          ? 12
                          : 0,
                    ),
                    child: _PendingConnectionCard(
                      user: user,
                      onCancel: () => _cancelPendingRequest(user, controller),
                      onTap: () => controller.viewUserProfile(user.uid),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // ========== PENDING REQUESTS ==========
  Widget _buildPendingRequests(ConnectController controller) {
    return Obx(() {
      if (controller.pendingRequests.isEmpty) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Connection Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Badge(
                  label: Text(controller.pendingRequests.length.toString()),
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    onPressed: () => _showPendingRequests(controller),
                    icon: const Icon(Icons.notifications_rounded),
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...controller.pendingRequests.take(2).map((request) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PendingRequestCard(
                  request: request,
                  onAccept: () => _acceptRequest(request, controller),
                  onReject: () => _rejectRequest(request, controller),
                  onView: () => controller.viewUserProfile(request.senderId),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  // ========== CONNECTION TYPES ==========
  Widget _buildConnectionTypes(ConnectController controller) {
    final types = controller.getAvailableConnectionTypes();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connect With',
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
            children: types.map((type) {
              return _ConnectionTypeChip(
                type: type,
                onTap: () => _showSearchScreen(controller, type: type),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ========== STUDY GROUPS ==========
  Widget _buildStudyGroups(ConnectController controller) {
    return Obx(() {
      final groups = controller.studyGroups;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Study Groups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => _showCreateGroupDialog(controller),
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (groups.isEmpty)
              _EmptyStateCard(
                icon: Icons.group_off_rounded,
                title: 'No active groups',
                subtitle: 'Create or join a study group to get started',
                actionText: 'Create Group',
                onAction: () => _showCreateGroupDialog(controller),
              )
            else
              Column(
                children: groups
                    .take(2)
                    .map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StudyGroupCard(
                          group: group,
                          onJoin: () => _joinGroup(group, controller),
                          onTap: () => _showGroupDetails(group, controller),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      );
    });
  }
}
