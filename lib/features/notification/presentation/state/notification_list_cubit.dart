import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/datasources/local_notification_storage.dart';

abstract class NotificationListState {}

class NotificationListInitial extends NotificationListState {}

class NotificationListLoading extends NotificationListState {}

class NotificationListLoaded extends NotificationListState {
  final List<NotificationEntity> notifications;
  NotificationListLoaded(this.notifications);
}

class NotificationListError extends NotificationListState {
  final String message;
  NotificationListError(this.message);
}

class NotificationListCubit extends Cubit<NotificationListState> {
  final LocalNotificationStorage _storage;

  NotificationListCubit(this._storage) : super(NotificationListInitial());

  Future<void> loadNotifications() async {
    emit(NotificationListLoading());
    try {
      final list = await _storage.getNotifications();
      emit(NotificationListLoaded(list));
    } catch (e) {
      emit(NotificationListError(e.toString()));
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _storage.deleteNotification(id);
      await loadNotifications();
    } catch (e) {
      // Ignored for now
    }
  }
}
