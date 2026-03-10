// lib/features/cultural_explorer/domain/entities/culture_record.dart

class CultureRecord {
  final int id;
  final String name;
  final String description;
  final String? streamUrl;
  final List<CultureTranscriptionLine> transcription;

  CultureRecord({
    required this.id,
    required this.name,
    required this.description,
    this.streamUrl,
    required this.transcription,
  });
}

class CultureTranscriptionLine {
  final int index;
  final String speaker;
  final String text;
  final int timestampSeconds;

  CultureTranscriptionLine({
    required this.index,
    required this.speaker,
    required this.text,
    required this.timestampSeconds,
  });
}
