// lib/features/cultural_explorer/data/models/culture_model.dart
import '../../domain/entities/culture_record.dart';

class CultureModel extends CultureRecord {
  CultureModel({
    required super.id,
    required super.name,
    required super.description,
    super.streamUrl,
    required super.transcription,
  });

  factory CultureModel.fromJson(Map<String, dynamic> json) {
    String? parsedStreamUrl;
    if (json['hd_version'] != null && json['hd_version']['src'] != null) {
      parsedStreamUrl = json['hd_version']['src'] as String;
    }

    List<CultureTranscriptionLine> parsedTranscription = [];
    if (json['transcription'] != null && json['transcription']['content'] != null) {
      final contentList = json['transcription']['content'] as List;
      parsedTranscription = contentList
          .map((item) => CultureTranscriptionLineModel.fromJson(item))
          .toList();
    }

    return CultureModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Culture Record',
      description: json['description'] ?? '',
      streamUrl: parsedStreamUrl,
      transcription: parsedTranscription,
    );
  }
}

class CultureTranscriptionLineModel extends CultureTranscriptionLine {
  CultureTranscriptionLineModel({
    required super.index,
    required super.speaker,
    required super.text,
    required super.timestampSeconds,
  });

  factory CultureTranscriptionLineModel.fromJson(Map<String, dynamic> json) {
    return CultureTranscriptionLineModel(
      index: json['index'] ?? 0,
      speaker: json['speaker'] ?? 'Unknown',
      text: json['text'] ?? '',
      timestampSeconds: json['timestamp'] ?? 0,
    );
  }
}
