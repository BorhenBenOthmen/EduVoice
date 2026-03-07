// lib/features/lesson_player/presentation/smart_lesson_player.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../lesson/domain/entities/lesson.dart';
import '../../../../injection_container.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../core/audio/lesson_audio_player_service.dart';

/// Full-featured lesson player screen.
///
/// - Streams audio from [lesson.streamUrl] using [LessonAudioPlayerService].
/// - Falls back to TTS reading [lesson.description] when [streamUrl] is null.
/// - Shows real-time seek bar, play/pause/stop controls.
/// - Announces lesson name via TTS on open (accessibility).
class LessonPlayerScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonPlayerScreen({Key? key, required this.lesson}) : super(key: key);

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

    // Accessibility: announce lesson name immediately
    _tts.speak("فتح درس: ${widget.lesson.name}");

    _audioService.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _audioService.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _audioService.playerStateStream.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });

    // Auto-start if there is a stream URL
    if (widget.lesson.streamUrl != null) {
      _audioService.play(widget.lesson.streamUrl!);
    } else {
      // No stream URL — fall back to TTS
      _isTtsFallback = true;
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

  Future<void> _stop() async {
    await _audioService.stop();
    if (mounted) {
      setState(() {
        _position = Duration.zero;
      });
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
                  label: "وصف الدرس: ${widget.lesson.description}",
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
              const Text(
                "النص المكتوب",
                style: TextStyle(
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
                child: const Text(
                  "لا يوجد ملف صوتي متاح. يمكنك الاستماع للوصف بالنص المقروء.",
                  style: TextStyle(color: Colors.yellow, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTtsButton(),
            ] else ...[
              // ── Seek bar ──────────────────────────────────────────────
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
                      activeColor: Colors.yellow,
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

              // ── Play / Pause / Stop controls ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Stop button
                  Semantics(
                    button: true,
                    label: "إيقاف التشغيل وإعادة للبداية",
                    child: _controlButton(
                      icon: Icons.stop_rounded,
                      onPressed: _stop,
                      color: Colors.redAccent,
                    ),
                  ),

                  // Play / Pause button (large)
                  Semantics(
                    button: true,
                    label: _isPlaying ? "إيقاف مؤقت" : "تشغيل",
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

                  // Replay 10s button
                  Semantics(
                    button: true,
                    label: "رجوع 10 ثوانٍ",
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
                ],
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
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

  Widget _buildTtsButton() {
    return Semantics(
      button: true,
      label: _isTtsPlaying
          ? "إيقاف الاستماع. انقر مرتين لإيقاف."
          : "بدء الاستماع للدرس بصوت عالٍ. انقر مرتين للتشغيل.",
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
            _isTtsPlaying ? "إيقاف" : "استمع للدرس",
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
