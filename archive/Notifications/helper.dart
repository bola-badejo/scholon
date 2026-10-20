import 'dart:html' as html;

class WebNotificationHelper {
  static bool get isNotificationSupported {
    return true;
  }
  
  static String get permissionStatus {
    if (!isNotificationSupported) return 'unsupported';
    return html.Notification.permission ?? 'default';
  }
  
  static Future<String> requestPermission() async {
    if (!isNotificationSupported) {
      return 'unsupported';
    }
    
    try {
      final permission = await html.Notification.requestPermission();
      return permission;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return 'denied';
    }
  }
  
  static void showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    Function()? onClick,
  }) {
    if (!isNotificationSupported || html.Notification.permission != 'granted') {
      return;
    }
    
    final notification = html.Notification(title, body: body,
      icon: icon ?? 'assets/images/logo.png',
      tag: tag,);
    
    if (onClick != null) {
      notification.onClick.listen((event) {
        onClick();
        notification.close();
      });
    }
    
    // Auto-close after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      notification.close();
    });
  }
  
  static void closeAllNotifications() {
    // Notifications close automatically or by user
    // This is mainly for cleanup
  }
}