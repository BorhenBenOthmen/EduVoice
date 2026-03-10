import 'package:equatable/equatable.dart';
import '../../domain/entities/culture_record.dart';

abstract class CultureState extends Equatable {
  const CultureState();

  @override
  List<Object?> get props => [];
}

class CultureInitial extends CultureState {}

class CultureLoading extends CultureState {}

class CultureLoaded extends CultureState {
  final List<CultureRecord> records;

  const CultureLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class CultureError extends CultureState {
  final String message;

  const CultureError(this.message);

  @override
  List<Object?> get props => [message];
}
