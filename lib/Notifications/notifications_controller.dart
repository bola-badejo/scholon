import 'package:get/get.dart';
import 'package:isapp/Notifications/notifications_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final RxBool _notificationsEnabled = false.obs;
  final RxInt _pendingCount = 0.obs;
  
  bool get notificationsEnabled => _notificationsEnabled.value;
  int get pendingCount => _pendingCount.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }
  
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    _notificationsEnabled.value = _notificationService.areNotificationsEnabled;
    _pendingCount.value = _notificationService.pendingNotificationsCount;
  }
  
  Future<void> toggleNotifications(bool enabled) async {
    if (enabled) {
      final granted = await _notificationService.requestPermission();
      _notificationsEnabled.value = granted;
      
      if (granted) {
        Get.snackbar(
          'Notifications Enabled',
          'You will now receive daily reminders and activity notifications',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        // Refresh pending count
        _pendingCount.value = _notificationService.pendingNotificationsCount;
      }
    } else {
      await _notificationService.cancelAllNotifications();
      _notificationsEnabled.value = false;
      _pendingCount.value = 0;
      Get.snackbar(
        'Notifications Disabled',
        'You will no longer receive notifications',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  Future<void> sendTestNotification() async {
    await _notificationService.showActivityNotification(
      title: 'Test Notification ✅',
      body: 'Your notifications are working perfectly!',
      payload: 'test',
    );
    
    // Show success message
    Get.snackbar(
      'Test Notification Sent',
      'Check your browser notifications',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
  
  Future<void> notifyTaskCompleted(String taskName) async {
    await _notificationService.showTaskCompletedNotification(taskName);
    
    // Schedule a follow-up reminder for tomorrow
    await _notificationService.scheduleReminder(
      title: 'Continue Learning! 📚',
      body: 'Keep up the momentum with another study session today!',
      delay: const Duration(hours: 24),
      payload: 'follow_up_$taskName',
    );
    
    _pendingCount.value = _notificationService.pendingNotificationsCount;
  }
  
  Future<void> notifyStreak(int days) async {
    await _notificationService.showStreakNotification(days);
    
    // If it's a milestone (5, 10, 30 days), schedule a celebration reminder
    if (days == 5 || days == 10 || days == 30 || days % 30 == 0) {
      await _notificationService.scheduleReminder(
        title: 'Milestone Celebration! 🎊',
        body: 'You reached $days days! Time to celebrate your achievement!',
        delay: const Duration(hours: 12),
        payload: 'milestone_$days',
      );
    }
    
    _pendingCount.value = _notificationService.pendingNotificationsCount;
  }
  
  Future<void> scheduleStudyReminder(DateTime studyTime) async {
    final now = DateTime.now();
    final delay = studyTime.difference(now);
    
    if (delay.isNegative) {
      Get.snackbar(
        'Invalid Time',
        'Please select a future time for the reminder',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    await _notificationService.scheduleReminder(
      title: 'Study Reminder 📚',
      body: 'Time for your scheduled study session!',
      delay: delay,
      payload: 'study_reminder',
    );
    
    _pendingCount.value = _notificationService.pendingNotificationsCount;
    
    Get.snackbar(
      'Reminder Set',
      'You will be notified when it\'s time to study',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void clearPendingNotification(String payload) {
    _notificationService.clearNotification(payload);
    _pendingCount.value = _notificationService.pendingNotificationsCount;
  }
}