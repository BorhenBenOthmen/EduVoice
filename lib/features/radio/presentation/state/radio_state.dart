import 'package:equatable/equatable.dart';
import '../../domain/entities/radio_emission.dart';

abstract class RadioState extends Equatable {
  const RadioState();

  @override
  List<Object?> get props => [];
}

class RadioInitial extends RadioState {}

class RadioLoading extends RadioState {}

class RadioLoaded extends RadioState {
  final List<RadioEmission> emissions;
  final String? searchQuery;

  const RadioLoaded(this.emissions, {this.searchQuery});

  @override
  List<Object?> get props => [emissions, searchQuery];
}

class RadioError extends RadioState {
  final String message;

  const RadioError(this.message);

  @override
  List<Object?> get props => [message];
}
