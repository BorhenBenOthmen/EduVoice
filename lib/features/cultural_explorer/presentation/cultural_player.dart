import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../domain/entities/culture_record.dart';
import '../../../../injection_container.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../core/audio/lesson_audio_player_service.dart';
import '../../../../l10n/app_localizations.dart';

class CulturePlayerScreen extends StatefulWidget {
  final CultureRecord record;

  const CulturePlayerScreen({super.key, required this.record});

  @override
  State<CulturePlayerScreen> createState() => _CulturePlayerScreenState();
}

class _CulturePlayerScreenState extends State<CulturePlayerScreen> {
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

    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(widget.record.name);
    if (isArabic) {
      await _tts.speakNotification(l.cultureTitle, widget.record.name);
    } else {
      await _tts.speak(l.culturePlayerOpening(widget.record.name));
    }

    if (!mounted) return;

    if (widget.record.streamUrl != null) {
      await _audioService.play(widget.record.streamUrl!);
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
      if (widget.record.streamUrl != null) {
        await _audioService.play(widget.record.streamUrl!);
      }
    }
  }

  Future<void> _toggleTts() async {
    if (_isTtsPlaying) {
      await _tts.stop();
      if (mounted) setState(() => _isTtsPlaying = false);
    } else {
      if (mounted) setState(() => _isTtsPlaying = true);
      await _tts.speak(widget.record.description);
      for (final line in widget.record.transcription) {
        if (!mounted || !_isTtsPlaying) break;
        await _tts.speak("${line.speaker}: ${line.text}");
      }
      if (mounted) setState(() => _isTtsPlaying = false);
    }
  }

  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  bool _wasPlayingBeforeSeek = false;

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatSemanticDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    }
    return '${seconds}s';
  }

  Future<void> _cycleSpeed() async {
    final l = AppLocalizations.of(context)!;
    final currentRate = _audioService.playbackRate;
    int currentIndex = _speedOptions.indexOf(currentRate);
    if (currentIndex == -1) currentIndex = 2;
    final nextIndex = (currentIndex + 1) % _speedOptions.length;
    final newRate = _speedOptions[nextIndex];

    final wasPlaying = _isPlaying;
    if (wasPlaying) await _audioService.pause();

    await _audioService.setPlaybackRate(newRate);
    if (mounted) setState(() {});

    await _tts.speak(l.lessonPlayerCurrentSpeed(newRate.toString()));

    if (wasPlaying && mounted) await _audioService.resume();
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabicName = RegExp(r'[\u0600-\u06FF]').hasMatch(widget.record.name);
    final isArabicDesc = RegExp(r'[\u0600-\u06FF]').hasMatch(widget.record.description);

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.lightGreenAccent),
          title: Semantics(
            header: true,
            child: Text(
              widget.record.name,
              locale: isArabicName ? const Locale('ar') : null,
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
                  child: Text(
                    widget.record.description,
                    locale: isArabicDesc ? const Locale('ar') : null,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (widget.record.transcription.isNotEmpty) ...[
                const Divider(color: Colors.lightGreenAccent),
                const SizedBox(height: 8),
                Text(
                  l.culturePlayerTranscript,
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
                    itemCount: widget.record.transcription.length,
                    itemBuilder: (context, index) {
                      final line = widget.record.transcription[index];
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
                    color: Colors.lightGreenAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.lightGreenAccent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    l.culturePlayerNoAudio,
                    style: const TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildTtsButton(l),
              ] else ...[
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
                        activeColor: Colors.lightGreenAccent,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                            color: Colors.lightGreenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.lightGreenAccent.withValues(alpha: 0.4),
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
                          color: Colors.lightGreenAccent,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _cycleSpeed,
                      icon: const Icon(
                        Icons.speed_rounded,
                        color: Colors.lightGreenAccent,
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
            backgroundColor: _isTtsPlaying
                ? Colors.redAccent
                : Colors.lightGreenAccent,
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
            _isTtsPlaying ? l.lessonPlayerStopTts : l.culturePlayerListen,
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
