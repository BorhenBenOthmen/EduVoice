import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../podcast_hub/domain/entities/podcast.dart';
import '../../../../injection_container.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../core/audio/lesson_audio_player_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/voice_search_fab.dart';

class SmartPodcastPlayer extends StatefulWidget {
  final Podcast podcast;

  const SmartPodcastPlayer({super.key, required this.podcast});

  @override
  State<SmartPodcastPlayer> createState() => _SmartPodcastPlayerState();
}

class _SmartPodcastPlayerState extends State<SmartPodcastPlayer> {
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
    
    await _tts.speak(l.podcastPlayerOpening(widget.podcast.name));
    
    if (!mounted) return;

    if (widget.podcast.streamUrl != null) {
      await _audioService.play(widget.podcast.streamUrl!);
    } else {
      setState(() => _isTtsFallback = true);
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _audioService.pause();
    } else if (_playerState == PlayerState.paused) {
      await _audioService.resume();
    } else {
      if (widget.podcast.streamUrl != null) {
        await _audioService.play(widget.podcast.streamUrl!);
      }
    }
  }

  Future<void> _toggleTts() async {
    if (_isTtsPlaying) {
      await _tts.stop();
      if (mounted) setState(() => _isTtsPlaying = false);
    } else {
      if (mounted) setState(() => _isTtsPlaying = true);
      await _tts.speak(widget.podcast.description);
      for (final line in widget.podcast.transcription) {
        if (!mounted || !_isTtsPlaying) break;
        await _tts.speak("${line.speaker}: ${line.text}");
      }
      if (mounted) setState(() => _isTtsPlaying = false);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.lightGreenAccent),
        title: Semantics(
          header: true,
          child: Text(
            widget.podcast.name,
            style: const TextStyle(
              color: Colors.lightGreenAccent,
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
            Expanded(
              child: SingleChildScrollView(
                child: Semantics(
                  label: l.podcastPlayerDescription(widget.podcast.description),
                  child: Text(
                    widget.podcast.description,
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

            if (widget.podcast.transcription.isNotEmpty) ...[
              const Divider(color: Colors.lightGreenAccent),
              const SizedBox(height: 8),
              Text(
                l.podcastPlayerTranscript,
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  itemCount: widget.podcast.transcription.length,
                  itemBuilder: (context, index) {
                    final line = widget.podcast.transcription[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${line.speaker}: ",
                              style: const TextStyle(
                                color: Colors.lightGreenAccent,
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

            if (_isTtsFallback) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.lightGreenAccent, width: 1),
                ),
                child: Text(
                  l.podcastPlayerNoAudio,
                  style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTtsButton(l),
            ] else ...[
              Row(
                children: [
                  Text(
                    _formatDuration(_position),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Expanded(
                    child: Slider(
                      value: (_duration.inSeconds > 0)
                          ? _position.inSeconds
                              .toDouble()
                              .clamp(0.0, _duration.inSeconds.toDouble())
                          : 0.0,
                      min: 0.0,
                      max: _duration.inSeconds > 0
                          ? _duration.inSeconds.toDouble()
                          : 1.0,
                      activeColor: Colors.lightGreenAccent,
                      inactiveColor: Colors.white24,
                      onChanged: (value) {
                        _audioService.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Semantics(
                    button: true,
                    label: l.lessonPlayerRewind,
                    child: _controlButton(
                      icon: Icons.replay_10_rounded,
                      onPressed: () {
                        final newPos = _position - const Duration(seconds: 10);
                        _audioService.seek(
                          newPos < Duration.zero ? Duration.zero : newPos,
                        );
                      },
                      color: Colors.white70,
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: _isPlaying ? l.lessonPlayerPause : l.lessonPlayerPlay,
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.lightGreenAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.lightGreenAccent.withOpacity(0.4),
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
                  Semantics(
                    button: true,
                    label: l.lessonPlayerFastForward,
                    child: _controlButton(
                      icon: Icons.forward_10_rounded,
                      onPressed: () {
                        final newPos = _position + const Duration(seconds: 10);
                        _audioService.seek(
                          newPos > _duration ? _duration : newPos,
                        );
                      },
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Semantics(
                    button: true,
                    label: l.lessonPlayerSpeedDecrease,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.lightGreenAccent),
                      iconSize: 36,
                      onPressed: () async {
                        final current = _audioService.playbackRate;
                        if (current > 0.75) {
                          final newRate = current - 0.25;
                          final wasPlaying = _isPlaying;
                          
                          if (wasPlaying) {
                            await _audioService.pause();
                          }
                          
                          await _audioService.setPlaybackRate(newRate);
                          if (mounted) setState(() {});
                          
                          await locator<TtsService>().speak(l.lessonPlayerCurrentSpeed(newRate.toString()));
                          
                          if (wasPlaying && mounted) {
                            await _audioService.resume();
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  Semantics(
                    label: l.lessonPlayerCurrentSpeed(_audioService.playbackRate.toString()),
                    child: Text(
                      "${_audioService.playbackRate}x",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Semantics(
                    button: true,
                    label: l.lessonPlayerSpeedIncrease,
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.lightGreenAccent),
                      iconSize: 36,
                      onPressed: () async {
                        final current = _audioService.playbackRate;
                        if (current < 1.5) {
                          final newRate = current + 0.25;
                          final wasPlaying = _isPlaying;
                          
                          if (wasPlaying) {
                            await _audioService.pause();
                          }
                          
                          await _audioService.setPlaybackRate(newRate);
                          if (mounted) setState(() {});
                          
                          await locator<TtsService>().speak(l.lessonPlayerCurrentSpeed(newRate.toString()));
                          
                          if (wasPlaying && mounted) {
                            await _audioService.resume();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: VoiceSearchFab(
        onInteractionStarted: () async {
          if (_isPlaying) {
            await _audioService.pause();
          }
        },
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return IconButton(
      iconSize: 48,
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }

  Widget _buildTtsButton(AppLocalizations l) {
    return Semantics(
      button: true,
      label: _isTtsPlaying ? l.lessonPlayerStopLabel : l.lessonPlayerListenLabel,
      child: SizedBox(
        width: double.infinity,
        height: 72,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTtsPlaying ? Colors.redAccent : Colors.lightGreenAccent,
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
            _isTtsPlaying ? l.lessonPlayerStopTts : l.podcastPlayerListen,
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
