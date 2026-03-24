import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/audio/tts_service.dart';
import '../../core/audio/stt_service.dart';
import '../../core/audio/audio_session_manager.dart';
import '../../core/audio/audio_feedback_service.dart';
import '../../injection_container.dart';
import '../../l10n/app_localizations.dart';

/// Invisible wrapper widget that listens for a phone shake gesture
/// and triggers the voice assistant (STT → command recognition).
///
/// Replaces the old visible [FloatingActionButton] so that visually
/// impaired users can simply shake the phone to start/stop listening.
class ShakeVoiceDetector extends StatefulWidget {
  /// Called with the recognized text after STT finishes.
  final ValueChanged<String>? onCommandRecognized;

  /// Called when the voice interaction starts (useful for pausing audio).
  final VoidCallback? onInteractionStarted;

  /// The child widget (usually the screen's body/Scaffold).
  final Widget child;

  const ShakeVoiceDetector({
    super.key,
    this.onCommandRecognized,
    this.onInteractionStarted,
    required this.child,
  });

  @override
  State<ShakeVoiceDetector> createState() => _ShakeVoiceDetectorState();
}

class _ShakeVoiceDetectorState extends State<ShakeVoiceDetector> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  bool _isListening = false;

  // Shake detection parameters
  static const double _shakeThreshold = 15.0; // m/s²
  static const Duration _shakeCooldown = Duration(seconds: 2);
  DateTime _lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _accelerometerSub = accelerometerEventStream().listen(
      _onAccelerometerEvent,
    );
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    super.dispose();
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Subtract gravity (~9.8) and check threshold
    if ((magnitude - 9.8).abs() > _shakeThreshold) {
      final now = DateTime.now();
      if (now.difference(_lastShakeTime) > _shakeCooldown) {
        _lastShakeTime = now;
        _handleVoiceInteraction();
      }
    }
  }

  Future<void> _handleVoiceInteraction() async {
    final stt = locator<SttService>();
    final audio = locator<AudioSessionManager>();
    final tts = locator<TtsService>();
    final earcons = locator<AudioFeedbackService>();
    final l = AppLocalizations.of(context)!;

    if (_isListening) {
      await stt.stopListening();
      if (mounted) setState(() => _isListening = false);
      await earcons.playProcessingChime();
      await tts.speak(l.homeSearching);
      await audio.releaseFocus();
    } else {
      if (mounted) setState(() => _isListening = true);
      widget.onInteractionStarted?.call();
      await audio.requestExclusiveFocus();
      await tts.speak(l.homeListening);
      await stt.startListening((text) {
        if (widget.onCommandRecognized != null) {
          widget.onCommandRecognized!(text);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
