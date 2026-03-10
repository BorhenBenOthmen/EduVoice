// lib/features/cultural_explorer/domain/repositories/i_culture_repository.dart
import '../entities/culture_record.dart';

abstract class ICultureRepository {
  Future<List<CultureRecord>> fetchCultureRecords();
}
