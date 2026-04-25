import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../data/datasources/local_notification_storage.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final INotificationRepository _repository;
  final LocalNotificationStorage _storage;
  Timer? _pollingTimer;
  final Set<int> _processedIds = {}; // Prevent duplicate alerts

  NotificationCubit(this._repository, this._storage) : super(NotificationInitial());

  void startPolling({int intervalSeconds = 30}) {
    debugPrint('🔔 [CUBIT] startPolling called (interval=${intervalSeconds}s)');
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      debugPrint('🔔 [CUBIT] Timer tick — calling _fetchUnread');
      _fetchUnread();
    });
    // Fetch immediately upon start
    _fetchUnread();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchUnread() async {
    try {
      debugPrint('🔔 [CUBIT] _fetchUnread called, processedIds=$_processedIds');
      final unreadList = await _repository.getUnreadNotifications();
      debugPrint('🔔 [CUBIT] got ${unreadList.length} unread notifications');
      for (final notification in unreadList) {
        debugPrint(
          '🔔 [CUBIT] notification id=${notification.id}, note="${notification.note}", alreadyProcessed=${_processedIds.contains(notification.id)}',
        );
        if (!_processedIds.contains(notification.id)) {
          _processedIds.add(notification.id);
          debugPrint(
            '🔔 [CUBIT] EMITTING NotificationNewReceived for id=${notification.id}',
          );
          emit(NotificationNewReceived(notification));

          // Save locally
          await _storage.saveNotification(notification);

          // Once emitted, mark as read so it doesn't stay unread on server
          await _repository.markAsRead(notification.id);

          // Only process one new notification at a time to prevent overlapping TTS/Banners
          // Next poll will pick up the rest if any.
          break;
        }
      }
    } catch (e) {
      debugPrint('🔔 [CUBIT] polling error: $e');
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
