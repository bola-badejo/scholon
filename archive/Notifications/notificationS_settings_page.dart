import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/notifications/controllers/notifications_controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Daily reminders, task completions, etc.'),
              value: controller.notificationsEnabled,
              onChanged: controller.toggleNotifications,
            )),
            
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Types',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildNotificationType(
                      '🌞 Morning Greetings',
                      'Daily at 8:00 AM',
                    ),
                    _buildNotificationType(
                      '📚 Study Reminders',
                      'Daily at 2:00 PM',
                    ),
                    _buildNotificationType(
                      '🌙 Evening Review',
                      'Daily at 8:00 PM',
                    ),
                    _buildNotificationType(
                      '✅ Task Completed',
                      'When you finish an activity',
                    ),
                    _buildNotificationType(
                      '🔥 Streak Milestones',
                      'When you reach learning streaks',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: controller.sendTestNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('Send Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationType(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}