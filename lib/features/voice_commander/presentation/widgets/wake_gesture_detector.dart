import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:get_it/get_it.dart';
import '../../data/gemini_routing_service.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../core/audio/audio_feedback_service.dart';
import '../../../../l10n/app_localizations.dart';

/// specialized version of shake detector that specifically triggers
/// the Gemini Live Session for the Voice Commander feature.
class WakeGestureDetector extends StatefulWidget {
  final Widget child;

  const WakeGestureDetector({super.key, required this.child});

  @override
  State<WakeGestureDetector> createState() => _WakeGestureDetectorState();
}

class _WakeGestureDetectorState extends State<WakeGestureDetector> {
  final _gemini = GetIt.I<GeminiRoutingService>();
  final _tts = GetIt.I<TtsService>();
  final _earcons = GetIt.I<AudioFeedbackService>();
  
  bool _isBusy = false;

  // Shake detection thresholds (increased to prevent accidental disconnects)
  static const double _shakeThreshold = 25.0;
  DateTime _lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if ((magnitude - 9.8).abs() > _shakeThreshold) {
      final now = DateTime.now();
      if (now.difference(_lastShakeTime) > const Duration(seconds: 2)) {
        _lastShakeTime = now;
        if (!_isBusy) {
          _toggleGeminiSession();
        }
      }
    }
  }

  Future<void> _toggleGeminiSession() async {
    _isBusy = true;
    final l = AppLocalizations.of(context)!;

    try {
      if (_gemini.isConnected) {
        // Disconnect immediately to prevent mic from picking up closing sounds
        _gemini.disconnect();
        await _earcons.playProcessingChime();
        await _tts.speak(l.voiceGoodbyeTts);
      } else {
        // Connect
        await _tts.speak(l.homeListening); // "I'm listening..."
        await _earcons.playSuccessChime();
        await _gemini.connect(
          onErrorCallback: () => _tts.speak(l.voiceErrorTts),
        );
      }
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
