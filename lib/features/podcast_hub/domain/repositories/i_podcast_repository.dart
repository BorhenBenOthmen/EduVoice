// lib/features/podcast_hub/domain/repositories/i_podcast_repository.dart
import '../entities/podcast.dart';

abstract class IPodcastRepository {
  Future<List<Podcast>> fetchPodcasts();
}
