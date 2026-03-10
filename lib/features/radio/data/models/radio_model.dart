import '../../domain/entities/radio_emission.dart';

class RadioModel extends RadioEmission {
  const RadioModel({
    required super.id,
    required super.title,
    required super.description,
    super.posterUrl,
    super.audioUrl,
    required super.transcription,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    // transcription handle
    List<RadioTranscriptionLineModel> parsedTranscription = [];
    if (json['transcription'] != null && json['transcription'] is Map) {
      final tMap = json['transcription'] as Map<String, dynamic>;
      if (tMap.containsKey('segments') && tMap['segments'] is List) {
        parsedTranscription = (tMap['segments'] as List)
            .map((s) => RadioTranscriptionLineModel.fromJson(s))
            .toList();
      }
    }

    String? parsedAudio;
    if (json['streaming_version'] != null && json['streaming_version']['src'] != null) {
      parsedAudio = json['streaming_version']['src'];
    }

    // fallback to emission's poster if available in EpisodeSchema
    String? poster;
    if (json['emission'] != null && json['emission']['poster'] != null) {
      poster = json['emission']['poster'];
    }

    return RadioModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      posterUrl: poster,
      audioUrl: parsedAudio,
      transcription: parsedTranscription,
    );
  }
}

class RadioTranscriptionLineModel extends RadioTranscriptionLine {
  const RadioTranscriptionLineModel({
    required super.startTime,
    required super.endTime,
    required super.text,
  });

  factory RadioTranscriptionLineModel.fromJson(Map<String, dynamic> json) {
    return RadioTranscriptionLineModel(
      startTime: (json['start'] ?? 0).toDouble(),
      endTime: (json['end'] ?? 0).toDouble(),
      text: json['text'] ?? '',
    );
  }
}
