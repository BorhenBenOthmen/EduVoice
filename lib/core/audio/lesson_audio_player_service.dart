// lib/core/audio/lesson_audio_player_service.dart
import 'package:audioplayers/audioplayers.dart';

/// Wraps [AudioPlayer] from the `audioplayers` package.
///
/// Provides a clean, named API for streaming audio from a remote URL.
/// Each [LessonPlayerScreen] should get its own instance (registered as factory).
class LessonAudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  /// Emits the current playback position as a [Duration].
  Stream<Duration> get positionStream => _player.onPositionChanged;

  /// Emits the total duration once the audio source is prepared.
  Stream<Duration> get durationStream =>
      _player.onDurationChanged;

  /// Emits the current [PlayerState] (playing, paused, stopped, completed).
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  /// Returns the current [PlayerState] synchronously.
  PlayerState get state => _player.state;

  /// Starts streaming audio from [url].
  /// If audio is already playing, it is stopped first.
  Future<void> play(String url) async {
    await _player.play(UrlSource(url));
  }

  /// Pauses playback. Position is preserved for [resume].
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resumes from a paused position.
  Future<void> resume() async {
    await _player.resume();
  }

  /// Stops playback and resets position to the beginning.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seeks to a specific [position] in the audio.
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Releases all resources. Call this from [State.dispose].
  Future<void> dispose() async {
    await _player.dispose();
  }
}
