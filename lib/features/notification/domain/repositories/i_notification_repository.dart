import '../entities/notification_entity.dart';

abstract class INotificationRepository {
  /// Fetches unread notifications
  Future<List<NotificationEntity>> getUnreadNotifications();
  
  /// Marks a notification as read
  Future<void> markAsRead(int notificationId);
}
