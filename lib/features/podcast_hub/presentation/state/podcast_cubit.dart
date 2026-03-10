import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_podcast_repository.dart';
import 'podcast_state.dart';

class PodcastCubit extends Cubit<PodcastState> {
  final IPodcastRepository _repository;

  PodcastCubit(this._repository) : super(PodcastInitial());

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
