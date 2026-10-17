part of '../connect_screen.dart';

// ConnectScreen: _showGroupDetails, _showConnectDialog, _showAllConnections, _showAllGroups, _showQuickConnectMenu
extension _ConnectScreenSection03 on ConnectScreen {
  void _showGroupDetails(StudyGroup group, ConnectController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    color: Colors.deepPurple,
                    size: 32,
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
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.subject,
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
            const SizedBox(height: 24),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              group.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '${group.memberCount}/${group.maxMembers} members',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Created ${_formatDate(group.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _joinGroup(group, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Join Group'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
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
}
