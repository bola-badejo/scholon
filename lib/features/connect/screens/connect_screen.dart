import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/controllers/connect_controller.dart';
import 'package:isapp/features/connect/models/connection_request.dart';
import 'package:isapp/features/connect/models/connection_status.dart';
import 'package:isapp/features/connect/models/connection_type.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';
import 'package:isapp/features/connect/models/study_group.dart';

export 'package:isapp/features/connect/controllers/connect_binding.dart';
export 'package:isapp/features/connect/controllers/connect_controller.dart';
export 'package:isapp/features/connect/models/connection_request.dart';
export 'package:isapp/features/connect/models/connection_result.dart';
export 'package:isapp/features/connect/models/connection_status.dart';
export 'package:isapp/features/connect/models/connection_type.dart';
export 'package:isapp/features/connect/models/group_result.dart';
export 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';
export 'package:isapp/features/connect/models/study_group.dart';
export 'package:isapp/features/connect/models/user_online_status.dart';
export 'package:isapp/features/connect/models/validation_result.dart';

part 'connect_screen_sections/01_hero_section.dart';
part 'connect_screen_sections/02_online_users.dart';
part 'connect_screen_sections/03_group_details.dart';

// ========== CONNECT SCREEN ==========
class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectController>(
      init: ConnectController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Obx(() {
              final user = controller.currentUser.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  if (user != null)
                    Text(
                      'Welcome, ${user.name.split(' ').first}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                ],
              );
            }),
            backgroundColor: Colors.deepPurple,
            elevation: 4,
            actions: [
              Obx(() {
                final pendingCount = controller.pendingRequests.length;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => _showPendingRequests(controller),
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Notifications',
                      color: Colors.white,
                    ),
                    if (pendingCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            pendingCount > 9 ? '9+' : pendingCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.reinitialize();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section
                  _buildHeroSection(controller),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildQuickStats(controller),
                  const SizedBox(height: 24),

                  // Pending Connections
                  _buildPendingConnections(controller),

                  // Pending Requests
                  if (controller.pendingRequests.isNotEmpty) ...[
                    _buildPendingRequests(controller),
                    const SizedBox(height: 24),
                  ],

                  // Connection Types
                  _buildConnectionTypes(controller),
                  const SizedBox(height: 24),

                  // Active Study Groups
                  _buildStudyGroups(controller),
                  const SizedBox(height: 24),

                  // Online Now
                  _buildOnlineUsers(controller),
                  const SizedBox(height: 24),

                  // Recent Connections
                  _buildRecentConnections(controller),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Floating Action Button
          floatingActionButton: _buildFloatingActionButton(controller),
        );
      },
    );
  }

  // ========== HELPER METHODS ==========
  Color _getUserTypeColor(UserType userType) {
    switch (userType) {
      case UserType.teacher:
        return Colors.blue;
      case UserType.schoolAdmin:
        return Colors.green;
      case UserType.parent:
        return Colors.deepOrange;
      default:
        return Colors.purple;
    }
  }

  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.teacher:
        return Icons.school_rounded;
      case UserType.schoolAdmin:
        return Icons.business_rounded;
      case UserType.parent:
        return Icons.family_restroom_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  void _acceptRequest(ConnectionRequest request, ConnectController controller) {
    controller.respondToConnectionRequest(
      requestId: request.id,
      response: ConnectionStatus.accepted,
    );
    Get.snackbar(
      'Connection Accepted',
      'You are now connected with ${request.senderName}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _rejectRequest(ConnectionRequest request, ConnectController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Request'),
        content: Text('Reject connection request from ${request.senderName}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.respondToConnectionRequest(
                requestId: request.id,
                response: ConnectionStatus.rejected,
                rejectionReason: 'Request rejected by user',
              );
              Get.snackbar(
                'Request Rejected',
                'Connection request rejected',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _cancelPendingRequest(BaseUser user, ConnectController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Request'),
        content: Text('Cancel connection request to ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          TextButton(
            onPressed: () async {
              Get.back();
              final requests = await controller.firestoreDb
                  .collection('connection_requests')
                  .where(
                    'senderId',
                    isEqualTo: controller.firebaseAuth.currentUser!.uid,
                  )
                  .where('receiverId', isEqualTo: user.uid)
                  .where('status', isEqualTo: 'pending')
                  .get();

              if (requests.docs.isNotEmpty) {
                await controller.cancelPendingRequest(requests.docs.first.id);
                Get.snackbar(
                  'Request Cancelled',
                  'Connection request cancelled',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _joinGroup(
    StudyGroup group,
    ConnectController controller,
  ) async {
    final result = await controller.joinStudyGroup(group.id);
    if (result.success) {
      Get.snackbar(
        'Success',
        'Joined ${group.name} successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        result.error ?? 'Failed to join group',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendConnectionRequestWithType(
    BaseUser user,
    ConnectionType type,
    ConnectController controller,
  ) async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send Connection Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.connectionMessageController,
                decoration: InputDecoration(
                  labelText: 'Message (optional)',
                  hintText: 'Add a personal message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await controller.sendConnectionRequest(
                          receiverId: user.uid,
                          type: type,
                          message: controller.connectionMessageController.text,
                        );

                        Get.back();
                        controller.connectionMessageController.clear();

                        if (result.success) {
                          Get.snackbar(
                            'Request Sent',
                            'Connection request sent to ${user.name}',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            result.error ?? 'Failed to send request',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: type.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Send as ${type.displayName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToOnlineUsers() {
    // Implementation for scrolling to online users section
  }

  void _sendMessage(BaseUser user, ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'Messaging feature will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }
}

class _PendingConnectionCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onCancel;
  final VoidCallback onTap;

  const _PendingConnectionCard({
    required this.user,
    required this.onCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    final connectionType = controller.getConnectionTypeForUser(user);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: connectionType.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: connectionType.color,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.pending_rounded,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                user.name.split(' ').first,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: onCancel,
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineUserCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onConnect;

  const _OnlineUserCard({required this.user, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    final connectionType = controller.getConnectionTypeForUser(user);
    final isOnline = controller.isUserOnline(user);

    return Container(
      width: 90,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => controller.viewUserProfile(user.uid),
            child: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: connectionType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: connectionType.color,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.name.split(' ').first,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: connectionType.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.userType.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                color: connectionType.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  const _ConnectionCard({
    required this.user,
    required this.onTap,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    final connectionType = controller.getConnectionTypeForUser(user);
    final isOnline = controller.isUserOnline(user);

    return Container(
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
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: connectionType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: connectionType.color,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.userType.displayName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (user is StudentUser) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Grade ${(user as StudentUser).classGrade ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onMessage,
            icon: Icon(
              Icons.message_rounded,
              color: Colors.deepPurple,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== SEARCH SCREEN ==========
class SearchScreen extends StatelessWidget {
  final ConnectionType? initialType;

  const SearchScreen({super.key, this.initialType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialType != null) {
        controller.selectedConnectionType.value = initialType;
        controller.searchUsers(type: initialType);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final type = controller.selectedConnectionType.value;
          return Text(
            type != null ? 'Find ${type.displayName}s' : 'Search People',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          );
        }),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: controller.clearSearch,
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          _buildTypeFilter(controller),
          Expanded(child: _buildSearchResults(controller)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ConnectController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              const Icon(Icons.search_rounded, color: Colors.grey, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: controller.selectedConnectionType.value != null
                        ? 'Search ${controller.selectedConnectionType.value!.displayName.toLowerCase()}s...'
                        : 'Search by name, email, or school...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    controller.searchQuery.value = value;
                  },
                ),
              ),
              if (controller.searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    controller.clearSearch();
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter(ConnectController controller) {
    final types = controller.getAvailableConnectionTypes();
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: types.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Obx(() {
                final isSelected =
                    controller.selectedConnectionType.value == null;
                return ChoiceChip(
                  label: const Text('All'),
                  selected: isSelected,
                  onSelected: (_) {
                    controller.selectedConnectionType.value = null;
                    controller.searchUsers();
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.deepPurple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            );
          }

          final type = types[index - 1];
          return Padding(
            padding: EdgeInsets.only(right: index < types.length ? 8 : 0),
            child: Obx(() {
              final isSelected =
                  controller.selectedConnectionType.value == type;
              return ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (_) {
                  controller.selectedConnectionType.value = type;
                  controller.searchUsers(type: type);
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: type.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                avatar: isSelected
                    ? Icon(type.icon, size: 16, color: Colors.white)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(ConnectController controller) {
    return Obx(() {
      if (controller.isSearching.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
              ),
              const SizedBox(height: 16),
              Text(
                'Searching...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      if (controller.searchQuery.value.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Start searching',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a name or keyword to find people',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords or filters',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final user = controller.searchResults[index];
          final type =
              controller.selectedConnectionType.value ??
              controller.getConnectionTypeForUser(user);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SearchResultCard(
              user: user,
              connectionType: type,
              onConnect: () => _showConnectDialog(user, controller),
              onView: () => controller.viewUserProfile(user.uid),
            ),
          );
        },
      );
    });
  }

  void _showConnectDialog(BaseUser user, ConnectController controller) {
    final availableTypes = controller.getAvailableConnectionTypes();
    final connectionType = controller.getConnectionTypeForUser(user);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: connectionType.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: connectionType.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.userType.displayName,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connect as:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTypes.map((type) {
                  return FilterChip(
                    label: Text(type.displayName),
                    selected: false,
                    onSelected: (_) async {
                      Get.back();
                      await _sendConnectionRequestWithType(
                        user,
                        type,
                        controller,
                      );
                    },
                    backgroundColor: type.color.withOpacity(0.1),
                    selectedColor: type.color,
                    labelStyle: TextStyle(color: type.color),
                    avatar: Icon(type.icon, size: 16, color: type.color),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendConnectionRequestWithType(
    BaseUser user,
    ConnectionType type,
    ConnectController controller,
  ) async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send Connection Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.connectionMessageController,
                decoration: InputDecoration(
                  labelText: 'Message (optional)',
                  hintText: 'Add a personal message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await controller.sendConnectionRequest(
                          receiverId: user.uid,
                          type: type,
                          message: controller.connectionMessageController.text,
                        );

                        Get.back();
                        controller.connectionMessageController.clear();

                        if (result.success) {
                          Get.snackbar(
                            'Request Sent',
                            'Connection request sent to ${user.name}',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            result.error ?? 'Failed to send request',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: type.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Send as ${type.displayName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllConnections(ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'All connections view will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  void _showAllGroups(ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'All groups view will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  void _scrollToOnlineUsers() {
    // Implementation for scrolling to online users section
  }

  void _showQuickConnectMenu(ConnectController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Quick Connect',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _quickActions.map((action) {
                  return SizedBox(
                    width: (Get.width - 64) / 3,
                    child: _QuickActionGridCard(
                      icon: action.icon,
                      label: action.label,
                      color: action.color,
                      onTap: () => action.onTap(controller),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(child: Text('Close')),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _sendMessage(BaseUser user, ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'Messaging feature will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }
}

class _SearchResultCard extends StatelessWidget {
  final BaseUser user;
  final ConnectionType connectionType;
  final VoidCallback onConnect;
  final VoidCallback onView;

  const _SearchResultCard({
    required this.user,
    required this.connectionType,
    required this.onConnect,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    final schoolName = controller.getSchoolName(user);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onView,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: connectionType.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: connectionType.color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: onView,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getUserTypeIcon(user.userType),
                          size: 12,
                          color: connectionType.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.userType.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            color: connectionType.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (schoolName != null && schoolName.isNotEmpty)
                      const SizedBox(height: 4),
                    if (schoolName != null && schoolName.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schoolName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                IconButton(
                  onPressed: onView,
                  icon: Icon(
                    Icons.visibility_rounded,
                    color: Colors.deepPurple.shade300,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: onConnect,
                  icon: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: connectionType.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: connectionType.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.teacher:
        return Icons.school_rounded;
      case UserType.schoolAdmin:
        return Icons.business_rounded;
      case UserType.parent:
        return Icons.family_restroom_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}

// ========== QUICK ACTIONS DATA ==========
class _QuickActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final Function(ConnectController) onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

final List<_QuickActionItem> _quickActions = [
  _QuickActionItem(
    icon: Icons.search_rounded,
    label: 'Find People',
    color: Colors.deepPurple,
    onTap: (controller) {
      Get.back();
      Get.to(() => SearchScreen());
    },
  ),
  _QuickActionItem(
    icon: Icons.group_add_rounded,
    label: 'Create Group',
    color: Colors.green,
    onTap: (controller) {
      Get.back();
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
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
                                        subject: 'General',
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
      );
    },
  ),
  _QuickActionItem(
    icon: Icons.pending_actions_rounded,
    label: 'Requests',
    color: Colors.orange,
    onTap: (controller) {
      Get.back();
      controller.pendingRequests.isNotEmpty
          ? _showPendingRequests(controller)
          : Get.snackbar(
              'No Requests',
              'You have no pending requests',
              backgroundColor: Colors.deepPurple,
              colorText: Colors.white,
            );
    },
  ),
  _QuickActionItem(
    icon: Icons.people_alt_rounded,
    label: 'Connections',
    color: Colors.purple,
    onTap: (controller) {
      Get.back();
      Get.snackbar(
        'Coming Soon',
        'Connections list will be available soon',
        backgroundColor: Colors.purple,
        colorText: Colors.white,
      );
    },
  ),
];

class _PendingRequestCard extends StatelessWidget {
  final ConnectionRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _PendingRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(request.type.icon, color: request.type.color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${request.type.displayName} Request',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatTimeAgo(request.sentAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onView,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: request.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      request.senderName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: request.type.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Wants to connect as ${request.type.displayName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: request.type.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.message!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Accept'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reject', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

class _ConnectionTypeChip extends StatelessWidget {
  final ConnectionType type;
  final VoidCallback onTap;

  const _ConnectionTypeChip({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: type.color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 18, color: type.color),
            const SizedBox(width: 8),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: type.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyGroupCard extends StatelessWidget {
  final StudyGroup group;
  final VoidCallback onJoin;
  final VoidCallback onTap;

  const _StudyGroupCard({
    required this.group,
    required this.onJoin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: group.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group_rounded,
                  color: group.isActive ? Colors.green : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount}/${group.maxMembers} members',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            group.subject,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: group.canJoin ? onJoin : null,
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: group.canJoin
                        ? Colors.deepPurple
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: group.canJoin
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    group.canJoin ? Icons.add_rounded : Icons.lock_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final bool compact;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact ? const EdgeInsets.all(20) : const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: compact ? 48 : 56, color: Colors.grey.shade300),
          SizedBox(height: compact ? 12 : 16),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(actionText!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionGridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionGridCard({
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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

class _PendingConnectionListCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onCancel;
  final VoidCallback onView;

  const _PendingConnectionListCard({
    required this.user,
    required this.onCancel,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${user.userType}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onView,
                  icon: Icon(
                    Icons.visibility_rounded,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: onCancel,
                  icon: Icon(Icons.close_rounded, color: Colors.red, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show pending requests
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Pending Requests',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Obx(() {
              final requests = controller.pendingRequests;
              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
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
                  return _PendingRequestCard(
                    request: request,
                    onAccept: () => controller.respondToConnectionRequest(
                      requestId: request.id,
                      response: ConnectionStatus.accepted,
                    ),
                    onReject: () => controller.respondToConnectionRequest(
                      requestId: request.id,
                      response: ConnectionStatus.rejected,
                    ),
                    onView: () => controller.viewUserProfile(request.senderId),
                  );
                },
              );
            }),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
