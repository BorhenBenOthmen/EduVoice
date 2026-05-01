import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/podcast_model.dart';
import '../../domain/repositories/i_podcast_repository.dart';
import 'podcast_state.dart';

class PodcastCubit extends Cubit<PodcastState> {
  final IPodcastRepository _repository;

  PodcastCubit(this._repository) : super(PodcastInitial());

  /// Load podcasts from a pre-fetched AI payload (no network request).
  /// Falls back to [loadPodcasts] if parsing fails.
  void loadFromPayload(dynamic rawJson) {
    debugPrint('[PodcastCubit] loadFromPayload called with ${rawJson is List ? rawJson.length : 0} items');
    try {
      final list = (rawJson as List)
          .map((json) => PodcastModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      emit(PodcastLoaded(list));
    } catch (e) {
      debugPrint('[PodcastCubit] loadFromPayload PARSING ERROR: $e');
      loadPodcasts();
    }
  }

  Future<void> loadPodcasts() async {
    emit(PodcastLoading());
    try {
      final podcasts = await _repository.fetchPodcasts();
      emit(PodcastLoaded(podcasts));
    } catch (e) {
      emit(PodcastError(e.toString()));
    }
  }
}
