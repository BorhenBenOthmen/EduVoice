import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/lesson_model.dart';
import '../../domain/repositories/i_lesson_repository.dart';
import 'lesson_state.dart';

class LessonCubit extends Cubit<LessonState> {
  final ILessonRepository _repository;

  LessonCubit(this._repository) : super(LessonInitial());

  /// Load lessons from a pre-fetched AI payload (no network request).
  /// Falls back to [loadLessons] if parsing fails.
  void loadFromPayload(dynamic rawJson) {
    debugPrint(
      '[LessonCubit] loadFromPayload called with ${rawJson is List ? rawJson.length : 0} items',
    );
    try {
      final list = (rawJson as List)
          .map((json) => LessonModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      emit(LessonLoaded(list));
    } catch (e) {
      // PRINT THE EXACT ERROR
      debugPrint('=========================================');
      debugPrint('[LessonCubit] PARSING ERROR: $e');
      debugPrint('[LessonCubit] RAW JSON: $rawJson');
      debugPrint('=========================================');

      // DO NOT CALL loadLessons()! We force the screen to show the error.
      emit(LessonError("Parsing Error: $e"));
    }
  }

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
