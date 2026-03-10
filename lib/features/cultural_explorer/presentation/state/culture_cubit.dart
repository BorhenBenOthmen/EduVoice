import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_culture_repository.dart';
import 'culture_state.dart';

class CultureCubit extends Cubit<CultureState> {
  final ICultureRepository repository;

  CultureCubit(this.repository) : super(CultureInitial());

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
