import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

class LocalNotificationStorage {
  final FlutterSecureStorage _storage;
  static const _key = 'local_notifications';

  LocalNotificationStorage(this._storage);

  Future<List<NotificationEntity>> getNotifications() async {
    final data = await _storage.read(key: _key);
    if (data == null) return [];
    try {
      final List decoded = json.decode(data);
      return decoded.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotification(NotificationEntity notification) async {
    final current = await getNotifications();
    // Avoid duplicates
    if (!current.any((n) => n.id == notification.id)) {
      current.insert(0, notification); // Add to top
      
      // Keep only the latest 100 notifications to prevent storage limits
      if (current.length > 100) {
        current.removeLast();
      }

      await _saveAll(current);
    }
  }

  Future<void> deleteNotification(int id) async {
    final current = await getNotifications();
    current.removeWhere((n) => n.id == id);
    await _saveAll(current);
  }

  Future<void> _saveAll(List<NotificationEntity> list) async {
    final data = list.map((e) {
      return {
        'id': e.id,
        'note': e.note,
        'is_read': e.isRead,
      };
    }).toList();
    await _storage.write(key: _key, value: json.encode(data));
  }
}
