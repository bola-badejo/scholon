import 'dart:async';
//import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  bool _initialized = false;
  bool _permissionGranted = false;

  // For web notifications
  List<Map<String, String>> _pendingNotifications = [];
  Timer? _notificationChecker;

  // Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    print('🔔 Initializing Notification Service...');

    // For web platform
    if (kIsWeb) {
      await _initializeForWeb();
    } else {
      await _initializeForMobile();
    }

    _initialized = true;
    print('✅ Notification Service initialized successfully');
    
    // Schedule daily notifications
    await _scheduleDailyNotifications();
  }

  // Initialize for web platform
  Future<void> _initializeForWeb() async {
    print('🌐 Initializing Web Notifications...');

      // final permission = await html.Notification.requestPermission();
      // _permissionGranted = permission == 'granted';
      // print('🔔 Web Notification permission: $permission');
      
      // Start checking for pending notifications
      _startNotificationChecker();
  }

  // Initialize for mobile platform
  Future<void> _initializeForMobile() async {
    print('📱 Initializing Mobile Notifications...');
    
    // Initialize timezone database
    tz.initializeTimeZones();

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    try {
      await _flutterLocalNotificationsPlugin!.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      _permissionGranted = true;
    } catch (e) {
      print('❌ Error initializing mobile notifications: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    
    // Handle navigation based on payload
    if (response.payload != null) {
      if (response.payload!.contains('daily')) {
        Get.toNamed('/home');
      } else if (response.payload!.contains('activity')) {
        Get.toNamed('/activities');
      } else if (response.payload!.contains('reminder')) {
        Get.toNamed('/home');
      }
    }
  }

  // Start checking for pending notifications (web only)
  void _startNotificationChecker() {
    _notificationChecker = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_pendingNotifications.isNotEmpty) {
        for (var notification in List.from(_pendingNotifications)) {
          final now = DateTime.now();
          final scheduledTime = DateTime.parse(notification['scheduledTime']!);
          
          if (now.isAfter(scheduledTime) || now.isAtSameMomentAs(scheduledTime)) {
            _showWebNotification(
              title: notification['title']!,
              body: notification['body']!,
              icon: notification['icon'],
            );
            _pendingNotifications.remove(notification);
          }
        }
      }
    });
  }

  // Show web notification
  Future<void> _showWebNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
  }) async {
    if (!_permissionGranted) return;

    try {
      
      // html.Notification(title, body: body, icon: 'assets/images/logo.png', tag: tag);
      
      print('✅ Web notification shown: $title');
    } catch (e) {
      print('❌ Error showing web notification: $e');
    }
  }

  // Schedule daily greeting notifications
  Future<void> _scheduleDailyNotifications() async {
    if (kIsWeb) {
      await _scheduleDailyForWeb();
    } else {
      await _scheduleDailyForMobile();
    }
  }

  // Schedule daily notifications for web
  Future<void> _scheduleDailyForWeb() async {
    if (!_permissionGranted) return;

    final now = DateTime.now();
    
    // Morning greeting (8:00 AM)
    var morningTime = DateTime(now.year, now.month, now.day, 8, 0);
    if (morningTime.isBefore(now)) {
      morningTime = morningTime.add(const Duration(days: 1));
    }
    
    _pendingNotifications.add({
      'title': 'Good Morning! 🌞',
      'body': 'Start your day with productive learning!',
      'scheduledTime': morningTime.toIso8601String(),
      'icon': 'assets/images/logo.png',
      'payload': 'daily_morning',
    });

    // Study reminder (2:00 PM)
    var studyTime = DateTime(now.year, now.month, now.day, 14, 0);
    if (studyTime.isBefore(now)) {
      studyTime = studyTime.add(const Duration(days: 1));
    }
    
    _pendingNotifications.add({
      'title': 'Study Time! 📚',
      'body': 'Time for your scheduled study session!',
      'scheduledTime': studyTime.toIso8601String(),
      'icon': 'assets/images/logo.png',
      'payload': 'daily_study',
    });

    // Evening reminder (8:00 PM)
    var eveningTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (eveningTime.isBefore(now)) {
      eveningTime = eveningTime.add(const Duration(days: 1));
    }
    
    _pendingNotifications.add({
      'title': 'Evening Review 🌙',
      'body': 'Review what you learned today!',
      'scheduledTime': eveningTime.toIso8601String(),
      'icon': 'assets/images/logo.png',
      'payload': 'daily_evening',
    });

    print('✅ Scheduled ${_pendingNotifications.length} daily notifications for web');
  }

  // Schedule daily notifications for mobile
  Future<void> _scheduleDailyForMobile() async {
    if (_flutterLocalNotificationsPlugin == null || !_permissionGranted) return;

    // Morning greeting (8:00 AM)
    await _scheduleMobileDaily(
      id: 100,
      title: 'Good Morning! 🌞',
      body: 'Start your day with productive learning!',
      hour: 8,
      minute: 0,
      payload: 'daily_morning',
    );

    // Study reminder (2:00 PM)
    await _scheduleMobileDaily(
      id: 101,
      title: 'Study Time! 📚',
      body: 'Time for your scheduled study session!',
      hour: 14,
      minute: 0,
      payload: 'daily_study',
    );

    // Evening reminder (8:00 PM)
    await _scheduleMobileDaily(
      id: 102,
      title: 'Evening Review 🌙',
      body: 'Review what you learned today!',
      hour: 20,
      minute: 0,
      payload: 'daily_evening',
    );
  }

  // Schedule a daily notification for mobile
  Future<void> _scheduleMobileDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_channel',
      'Daily Notifications',
      channelDescription: 'Daily greetings and reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosPlatformChannelSpecifics = DarwinNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin!.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      print('✅ Scheduled mobile notification: $title at $hour:$minute');
    } catch (e) {
      print('❌ Error scheduling mobile notification: $e');
    }
  }

  // Show immediate notification
  Future<void> showActivityNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) return;

    if (kIsWeb) {
      await _showWebNotification(
        title: title,
        body: body,
        icon: 'assets/images/logo.png',
        tag: payload,
      );
    } else {
      await _showMobileNotification(
        title: title,
        body: body,
        payload: payload,
      );
    }
  }

  // Show mobile notification
  Future<void> _showMobileNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (_flutterLocalNotificationsPlugin == null || !_permissionGranted) return;

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'activity_channel',
      'Activity Notifications',
      channelDescription: 'Notifications for completed activities',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosPlatformChannelSpecifics = DarwinNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin!.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      print('✅ Mobile activity notification shown: $title');
    } catch (e) {
      print('❌ Error showing mobile notification: $e');
    }
  }

  // Show task completion notification
  Future<void> showTaskCompletedNotification(String taskName) async {
    await showActivityNotification(
      title: 'Task Completed! 🎉',
      body: 'Great job completing "$taskName"!',
      payload: 'task_completed_$taskName',
    );
  }

  // Show streak notification
  Future<void> showStreakNotification(int streakDays) async {
    await showActivityNotification(
      title: '🔥 $streakDays Day Streak!',
      body: 'You\'re on fire! Keep up the great work!',
      payload: 'streak_$streakDays',
    );
  }

  // Show achievement unlocked notification
  Future<void> showAchievementNotification(String achievement) async {
    await showActivityNotification(
      title: 'Achievement Unlocked! 🏆',
      body: 'You unlocked "$achievement"!',
      payload: 'achievement_$achievement',
    );
  }

  // Schedule a one-time reminder
  Future<void> scheduleReminder({
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    if (!_initialized) return;

    if (kIsWeb) {
      final scheduledTime = DateTime.now().add(delay);
      _pendingNotifications.add({
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.toIso8601String(),
        'icon': 'assets/images/logo.png',
        'payload': payload ?? 'reminder',
      });
      print('✅ Scheduled web reminder: $title in ${delay.inMinutes} minutes');
    } else {
      await _scheduleMobileReminder(
        title: title,
        body: body,
        delay: delay,
        payload: payload,
      );
    }
  }

  // Schedule mobile reminder
  Future<void> _scheduleMobileReminder({
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    if (_flutterLocalNotificationsPlugin == null || !_permissionGranted) return;

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Scheduled reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosPlatformChannelSpecifics = DarwinNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin!.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      print('✅ Scheduled mobile reminder: $title in ${delay.inMinutes} minutes');
    } catch (e) {
      print('❌ Error scheduling mobile reminder: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) {
      _pendingNotifications.clear();
    } else {
      await _flutterLocalNotificationsPlugin?.cancelAll();
    }
    print('🔔 All notifications cancelled');
  }

  // Request permission manually
  Future<bool> requestPermission() async {
    if (kIsWeb) {
        // final permission = await html.Notification.requestPermission();
        _permissionGranted == 'granted';
        return _permissionGranted;
    } else {
      // For mobile, permission is handled by the OS
      return _permissionGranted;
    }
  }

  // Check if notifications are enabled
  bool get areNotificationsEnabled => _permissionGranted;

  // Get pending notifications count
  int get pendingNotificationsCount => _pendingNotifications.length;

  // Clear specific notification
  void clearNotification(String payload) {
    _pendingNotifications.removeWhere((n) => n['payload'] == payload);
  }
}