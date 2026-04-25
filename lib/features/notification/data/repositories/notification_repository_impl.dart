import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/network/auth_client.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final AuthClient _client;
  final TokenManager _tokenManager;

  NotificationRepositoryImpl(this._client, this._tokenManager);

  @override
  Future<List<NotificationEntity>> getUnreadNotifications() async {
    try {
      final accountId = await _tokenManager.getAccountId();
      debugPrint('🔔 [NOTIF] accountId = $accountId');
      if (accountId == null) {
        debugPrint('🔔 [NOTIF] accountId is NULL — skipping fetch');
        return [];
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/setting/notification/search/$accountId/?is_read=false',
      );
      debugPrint('🔔 [NOTIF] GET $url');
      final response = await _client.get(url);

      debugPrint('🔔 [NOTIF] status=${response.statusCode}');
      debugPrint('🔔 [NOTIF] body=${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        final items = data['items'] as List? ?? [];
        debugPrint('🔔 [NOTIF] items count=${items.length}');
        final notifications = items.map((e) => NotificationModel.fromJson(e)).toList();
        debugPrint('🔔 [NOTIF] parsed ${notifications.length} notifications');
        return notifications;
      }
      debugPrint('🔔 [NOTIF] Non-200 status, returning empty');
      return [];
    } catch (e, st) {
      debugPrint('🔔 [NOTIF] ERROR: $e');
      debugPrint('🔔 [NOTIF] STACK: $st');
      return [];
    }
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    try {
      final accountId = await _tokenManager.getAccountId();
      if (accountId == null) return;

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/setting/notification/read/$accountId/',
      );
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': notificationId}),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to mark notification $notificationId as read.');
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}
