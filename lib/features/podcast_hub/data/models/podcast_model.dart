// lib/features/podcast_hub/data/models/podcast_model.dart
import '../../domain/entities/podcast.dart';

class PodcastModel extends Podcast {
  PodcastModel({
    required super.id,
    required super.name,
    required super.description,
    super.streamUrl,
    required super.transcription,
  });

  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    String? parsedStreamUrl;
    if (json['hd_version'] != null && json['hd_version']['src'] != null) {
      parsedStreamUrl = json['hd_version']['src'] as String;
    }

    List<PodcastTranscriptionLine> parsedTranscription = [];
    if (json['transcription'] != null && json['transcription']['content'] != null) {
      final contentList = json['transcription']['content'] as List;
      parsedTranscription = contentList
          .map((item) => PodcastTranscriptionLineModel.fromJson(item))
          .toList();
    }

    return PodcastModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Podcast',
      description: json['description'] ?? '',
      streamUrl: parsedStreamUrl,
      transcription: parsedTranscription,
    );
  }
}

class PodcastTranscriptionLineModel extends PodcastTranscriptionLine {
  PodcastTranscriptionLineModel({
    required super.index,
    required super.speaker,
    required super.text,
    required super.timestampSeconds,
  });

  factory PodcastTranscriptionLineModel.fromJson(Map<String, dynamic> json) {
    return PodcastTranscriptionLineModel(
      index: json['index'] ?? 0,
      speaker: json['speaker'] ?? 'Unknown',
      text: json['text'] ?? '',
      timestampSeconds: json['timestamp'] ?? 0,
    );
  }
}
