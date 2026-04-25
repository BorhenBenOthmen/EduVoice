import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationNewReceived extends NotificationState {
  final NotificationEntity notification;

  const NotificationNewReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}
