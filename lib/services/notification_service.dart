import 'package:college_app/services/firestore_service.dart';

/// Notification service - now backed by Firestore
class NotificationService {

  /// Add notification for a specific user or all users
  static Future<void> addNotification({
    required String username, // 'all' for broadcast, or specific userId
    required String title,
    required String message,
    String type = 'general',
  }) async {
    if (username == 'all') {
      await FirestoreService.addNotificationToAll(
        title: title,
        message: message,
        type: type,
      );
    } else {
      await FirestoreService.addNotification(
        userId: username,
        title: title,
        message: message,
        type: type,
      );
    }
  }

  /// Get notifications for current user (returns stream)
  static Stream getNotificationsStream(String userId) {
    return FirestoreService.streamNotifications(userId);
  }

  /// Mark all notifications as read
  static Future<void> markAllRead(String userId) async {
    await FirestoreService.markAllNotificationsRead(userId);
  }

  /// Remove a notification
  static Future<void> removeNotification(String userId, String notifId) async {
    await FirestoreService.deleteNotification(userId, notifId);
  }
}