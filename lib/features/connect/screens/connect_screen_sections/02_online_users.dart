part of '../connect_screen.dart';

// ConnectScreen: _buildOnlineUsers, _buildRecentConnections, _buildFloatingActionButton, _showPendingRequests, _showPendingConnectionsSheet, _showSearchScreen, _showCreateGroupDialog
extension _ConnectScreenSection02 on ConnectScreen {
  // ========== ONLINE USERS ==========
  Widget _buildOnlineUsers(ConnectController controller) {
    return Obx(() {
      final onlineUsers = controller.onlineUsers;
      if (onlineUsers.isEmpty) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Online Now',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: onlineUsers.length,
                itemBuilder: (context, index) {
                  final user = onlineUsers[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < onlineUsers.length - 1 ? 12 : 0,
                    ),
                    child: _OnlineUserCard(
                      user: user,
                      onConnect: () => _showConnectDialog(user, controller),
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

  // ========== RECENT CONNECTIONS ==========
  Widget _buildRecentConnections(ConnectController controller) {
    return Obx(() {
      final connections = controller.connections;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Connections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (connections.isEmpty)
              _EmptyStateCard(
                icon: Icons.person_add_disabled_rounded,
                title: 'No connections yet',
                subtitle: 'Start connecting with people to build your network',
                actionText: 'Find People',
                onAction: () => _showSearchScreen(controller),
                compact: true,
              )
            else
              Column(
                children: connections
                    .take(3)
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ConnectionCard(
                          user: user,
                          onTap: () =>
                              controller.viewConnectionDetails(user.uid),
                          onMessage: () => _sendMessage(user, controller),
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

  // ========== FLOATING ACTION BUTTON ==========
  Widget _buildFloatingActionButton(ConnectController controller) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickConnectMenu(controller),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Connect',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  // ========== DIALOGS AND SHEETS ==========
  void _showPendingRequests(ConnectController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Connection Requests',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Obx(() {
                    final count = controller.pendingRequests.length;
                    if (count > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final requests = controller.pendingRequests;
                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No pending requests',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PendingRequestCard(
                        request: request,
                        onAccept: () => _acceptRequest(request, controller),
                        onReject: () => _rejectRequest(request, controller),
                        onView: () =>
                            controller.viewUserProfile(request.senderId),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _showPendingConnectionsSheet(ConnectController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Pending Connections',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final pendingUsers = controller.pendingConnections;
                if (pendingUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pending_actions_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No pending connections',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = pendingUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PendingConnectionListCard(
                        user: user,
                        onCancel: () => _cancelPendingRequest(user, controller),
                        onView: () => controller.viewUserProfile(user.uid),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _showSearchScreen(ConnectController controller, {ConnectionType? type}) {
    Get.to(() => SearchScreen(initialType: type));
  }

  void _showCreateGroupDialog(ConnectController controller) {
    final subjects = ['Math', 'Science', 'English', 'History', 'General'];
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Study Group',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    prefixIcon: const Icon(Icons.group_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.groupDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.description_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.selectedSubject.value,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.subject_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectedSubject.value = value;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  final result = await controller
                                      .createStudyGroup(
                                        name:
                                            controller.groupNameController.text,
                                        description: controller
                                            .groupDescriptionController
                                            .text,
                                        subject:
                                            controller.selectedSubject.value,
                                      );

                                  if (result.success) {
                                    Get.back();
                                    Get.snackbar(
                                      'Success',
                                      'Group created successfully',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      result.error ?? 'Failed to create group',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Create'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
