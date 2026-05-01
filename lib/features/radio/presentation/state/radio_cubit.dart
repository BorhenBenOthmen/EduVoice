import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/radio_model.dart';
import '../../domain/repositories/i_radio_repository.dart';
import 'radio_state.dart';

class RadioCubit extends Cubit<RadioState> {
  final IRadioRepository repository;

  RadioCubit(this.repository) : super(RadioInitial());

  /// Load radio emissions from a pre-fetched AI payload (no network request).
  /// Falls back to [loadEmissions] if parsing fails.
  void loadFromPayload(dynamic rawJson) {
    debugPrint('[RadioCubit] loadFromPayload called with ${rawJson is List ? rawJson.length : 0} items');
    try {
      final list = (rawJson as List)
          .map((json) => RadioModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      emit(RadioLoaded(list));
    } catch (e) {
      debugPrint('[RadioCubit] loadFromPayload PARSING ERROR: $e');
      loadEmissions();
    }
  }

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
