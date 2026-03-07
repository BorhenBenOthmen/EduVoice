// lib/domain/entities/lesson.dart

class Lesson {
  final int id;
  final String name;
  final String description;
  final String? streamUrl;
  final List<TranscriptionLine> transcription;

  Lesson({
    required this.id,
    required this.name,
    required this.description,
    this.streamUrl,
    required this.transcription,
  });
}

class TranscriptionLine {
  final int index;
  final String speaker;
  final String text;
  final int timestampSeconds;

  TranscriptionLine({
    required this.index,
    required this.speaker,
    required this.text,
    required this.timestampSeconds,
  });
}