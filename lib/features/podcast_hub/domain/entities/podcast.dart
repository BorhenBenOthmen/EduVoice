// lib/features/podcast_hub/domain/entities/podcast.dart

class Podcast {
  final int id;
  final String name;
  final String description;
  final String? streamUrl;
  final List<PodcastTranscriptionLine> transcription;

  Podcast({
    required this.id,
    required this.name,
    required this.description,
    this.streamUrl,
    required this.transcription,
  });
}

class PodcastTranscriptionLine {
  final int index;
  final String speaker;
  final String text;
  final int timestampSeconds;

  PodcastTranscriptionLine({
    required this.index,
    required this.speaker,
    required this.text,
    required this.timestampSeconds,
  });
}
