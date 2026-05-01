import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/culture_model.dart';
import '../../domain/repositories/i_culture_repository.dart';
import 'culture_state.dart';

class CultureCubit extends Cubit<CultureState> {
  final ICultureRepository repository;

  CultureCubit(this.repository) : super(CultureInitial());

  /// Load culture records from a pre-fetched AI payload (no network request).
  /// Falls back to [loadCultureRecords] if parsing fails.
  void loadFromPayload(dynamic rawJson) {
    debugPrint('[CultureCubit] loadFromPayload called with ${rawJson is List ? rawJson.length : 0} items');
    try {
      final list = (rawJson as List)
          .map((json) => CultureModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      emit(CultureLoaded(list));
    } catch (e) {
      debugPrint('[CultureCubit] loadFromPayload PARSING ERROR: $e');
      loadCultureRecords();
    }
  }

  Future<void> loadCultureRecords() async {
    emit(CultureLoading());
    try {
      final records = await repository.fetchCultureRecords();
      emit(CultureLoaded(records));
    } catch (e) {
      emit(CultureError(e.toString()));
    }
  }
}
