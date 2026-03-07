import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_lesson_repository.dart';
import 'lesson_state.dart';

class LessonCubit extends Cubit<LessonState> {
  final ILessonRepository _repository;

  LessonCubit(this._repository) : super(LessonInitial());

  Future<void> loadLessons() async {
    emit(LessonLoading());
    try {
      // The repository handles the TTS network announcements natively.
      final lessons = await _repository.fetchLessons();
      emit(LessonLoaded(lessons));
    } catch (e) {
      emit(LessonError(e.toString()));
    }
  }
}