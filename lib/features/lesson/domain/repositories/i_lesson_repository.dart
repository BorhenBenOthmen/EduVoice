// lib/domain/repositories/i_lesson_repository.dart
import '../entities/lesson.dart';

abstract class ILessonRepository {
  Future<List<Lesson>> fetchLessons();
}