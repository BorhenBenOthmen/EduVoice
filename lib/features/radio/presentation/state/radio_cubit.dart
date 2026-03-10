import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_radio_repository.dart';
import 'radio_state.dart';

class RadioCubit extends Cubit<RadioState> {
  final IRadioRepository repository;

  RadioCubit(this.repository) : super(RadioInitial());

  Future<void> loadEmissions({String? query}) async {
    emit(RadioLoading());
    try {
      final emissions = await repository.getRadioEmissions(query: query);
      emit(RadioLoaded(emissions, searchQuery: query));
    } catch (e) {
      emit(RadioError(e.toString()));
    }
  }
}
