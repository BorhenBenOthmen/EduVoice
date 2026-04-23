// lib/features/lesson_player/presentation/smart_lesson_player.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../lesson/domain/entities/lesson.dart';
import '../../../../injection_container.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../core/audio/lesson_audio_player_service.dart';
import '../../../../l10n/app_localizations.dart';

/// Full-featured lesson player screen.
///
/// - Streams audio from [lesson.streamUrl] using [LessonAudioPlayerService].
/// - Falls back to TTS reading [lesson.description] when [streamUrl] is null.
/// - Shows real-time seek bar, play/pause/stop controls.
/// - Announces lesson name via TTS on open (accessibility).
class LessonPlayerScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonPlayerScreen({super.key, required this.lesson});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late final LessonAudioPlayerService _audioService;
  late final TtsService _tts;

  bool _isTtsFallback = false;
  bool _isTtsPlaying = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _audioService = locator<LessonAudioPlayerService>();
    _tts = locator<TtsService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPlayer();
    });

    _audioService.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _audioService.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _audioService.playerStateStream.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
  }

  Future<void> _initPlayer() async {
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;

    // Accessibility: announce lesson name immediately, await completion before playing
    await _tts.speak(l.lessonPlayerOpening(widget.lesson.name));

    if (!mounted) return;

    // Auto-start if there is a stream URL after the intro completes
    if (widget.lesson.streamUrl != null) {
      await _audioService.play(widget.lesson.streamUrl!);
    } else {
      // No stream URL — fall back to TTS
      setState(() => _isTtsFallback = true);
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    _tts.stop();
    super.dispose();
  }

  // ─── Audio controls ──────────────────────────────────────────────────────

  Future<void> _togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _audioService.pause();
    } else if (_playerState == PlayerState.paused) {
      await _audioService.resume();
    } else {
      // Stopped or completed — restart from the URL
      if (widget.lesson.streamUrl != null) {
        await _audioService.play(widget.lesson.streamUrl!);
      }
    }
  }

  // ─── TTS fallback controls ────────────────────────────────────────────────

  Future<void> _toggleTts() async {
    if (_isTtsPlaying) {
      await _tts.stop();
      if (mounted) setState(() => _isTtsPlaying = false);
    } else {
      if (mounted) setState(() => _isTtsPlaying = true);
      await _tts.speak(widget.lesson.description);
      for (final line in widget.lesson.transcription) {
        if (!mounted || !_isTtsPlaying) break;
        await _tts.speak("${line.speaker}: ${line.text}");
      }
      if (mounted) setState(() => _isTtsPlaying = false);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  bool _wasPlayingBeforeSeek = false;

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Human-readable format for TalkBack: "1 min 15 s" instead of "75s"
  String _formatSemanticDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    }
    return '${seconds}s';
  }

  Future<void> _cycleSpeed() async {
    final currentRate = _audioService.playbackRate;
    int currentIndex = _speedOptions.indexOf(currentRate);
    if (currentIndex == -1) currentIndex = 2; // default to 1.0x
    final nextIndex = (currentIndex + 1) % _speedOptions.length;
    final newRate = _speedOptions[nextIndex];

    final wasPlaying = _isPlaying;
    if (wasPlaying) await _audioService.pause();

    await _audioService.setPlaybackRate(newRate);
    if (mounted) setState(() {});

    final l = AppLocalizations.of(context)!;
    await _tts.speak(l.lessonPlayerCurrentSpeed(newRate.toString()));

    if (wasPlaying && mounted) await _audioService.resume();
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.yellow),
          title: Semantics(
            header: true,
            child: Text(
              widget.lesson.name,
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Description ────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Semantics(
                    label: l.lessonPlayerDescription(widget.lesson.description),
                    child: Text(
                      widget.lesson.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Transcription ──────────────────────────────────────────────
              if (widget.lesson.transcription.isNotEmpty) ...[
                const Divider(color: Colors.yellow),
                const SizedBox(height: 8),
                Text(
                  l.lessonPlayerTranscript,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    itemCount: widget.lesson.transcription.length,
                    itemBuilder: (context, index) {
                      final line = widget.lesson.transcription[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${line.speaker}: ",
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              TextSpan(
                                text: line.text,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Player section ─────────────────────────────────────────────
              if (_isTtsFallback) ...[
                // No audio URL — show TTS fallback banner + button
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.yellow, width: 1),
                  ),
                  child: Text(
                    l.lessonPlayerNoAudio,
                    style: const TextStyle(color: Colors.yellow, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildTtsButton(l),
              ] else ...[
                // ── Seek bar ──────────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: (_duration.inSeconds > 0)
                            ? _position.inSeconds.toDouble().clamp(
                                0.0,
                                _duration.inSeconds.toDouble(),
                              )
                            : 0.0,
                        min: 0.0,
                        max: _duration.inSeconds > 0
                            ? _duration.inSeconds.toDouble()
                            : 1.0,
                        divisions: _duration.inSeconds > 0
                            ? (_duration.inSeconds ~/ 10).clamp(1, 10000)
                            : null,
                        activeColor: Colors.yellow,
                        inactiveColor: Colors.white24,
                        semanticFormatterCallback: (value) {
                          final pos = Duration(seconds: value.toInt());
                          return '${_formatSemanticDuration(pos)} / ${_formatSemanticDuration(_duration)}';
                        },
                        onChangeStart: (_) {
                          _wasPlayingBeforeSeek = _isPlaying;
                          if (_isPlaying) _audioService.pause();
                        },
                        onChangeEnd: (_) {
                          if (_wasPlayingBeforeSeek) _audioService.resume();
                        },
                        onChanged: (value) {
                          _audioService.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Play / Pause controls ──────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play / Pause button (large)
                    Semantics(
                      button: true,
                      label: _isPlaying
                          ? l.lessonPlayerPause
                          : l.lessonPlayerPlay,
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // ── Speed Control (YouTube-style cycle button) ─────────────
                Semantics(
                  button: true,
                  label: l.lessonPlayerCurrentSpeed(
                    _audioService.playbackRate.toString(),
                  ),
                  hint: l.lessonPlayerSpeedIncrease,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.yellow,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _cycleSpeed,
                      icon: const Icon(
                        Icons.speed_rounded,
                        color: Colors.yellow,
                        size: 28,
                      ),
                      label: Text(
                        '${_audioService.playbackRate}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
  }

  Widget _buildTtsButton(AppLocalizations l) {
    return Semantics(
      button: true,
      label: _isTtsPlaying
          ? l.lessonPlayerStopLabel
          : l.lessonPlayerListenLabel,
      child: SizedBox(
        width: double.infinity,
        height: 72,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTtsPlaying ? Colors.redAccent : Colors.yellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _toggleTts,
          icon: Icon(
            _isTtsPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
            color: Colors.black,
            size: 32,
          ),
          label: Text(
            _isTtsPlaying ? l.lessonPlayerStopTts : l.lessonPlayerListen,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
