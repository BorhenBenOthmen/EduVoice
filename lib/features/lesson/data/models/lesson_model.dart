// lib/data/models/lesson_model.dart
import '../../domain/entities/lesson.dart';

class LessonModel extends Lesson {
  LessonModel({
    required super.id,
    required super.name,
    required super.description,
    super.streamUrl,
    required super.transcription,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    // Parse streaming_version.src — the URL used for audio streaming
    String? parsedStreamUrl;
    if (json['streaming_version'] != null && json['streaming_version']['src'] != null) {
      parsedStreamUrl = json['streaming_version']['src'] as String;
    }

    // Defensively parse nested transcription
    List<TranscriptionLine> parsedTranscription = [];
    if (json['transcription'] != null && json['transcription']['content'] != null) {
      final contentList = json['transcription']['content'] as List;
      parsedTranscription = contentList.map((item) => TranscriptionLineModel.fromJson(item)).toList();
    }

    return LessonModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Lesson',
      description: json['description'] ?? '',
      streamUrl: parsedStreamUrl,
      transcription: parsedTranscription,
    );
  }
}

class TranscriptionLineModel extends TranscriptionLine {
  TranscriptionLineModel({
    required super.index,
    required super.speaker,
    required super.text,
    required super.timestampSeconds,
  });

  factory TranscriptionLineModel.fromJson(Map<String, dynamic> json) {
    return TranscriptionLineModel(
      index: json['index'] ?? 0,
      speaker: json['speaker'] ?? 'Unknown',
      text: json['text'] ?? '',
      timestampSeconds: json['timestamp'] ?? 0,
    );
  }
}