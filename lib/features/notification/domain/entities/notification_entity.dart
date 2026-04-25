import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String note;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.note,
    required this.isRead,
  });

  @override
  List<Object?> get props => [id, note, isRead];
}
