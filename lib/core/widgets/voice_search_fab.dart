import 'package:flutter/material.dart';
import '../../core/audio/tts_service.dart';
import '../../core/audio/stt_service.dart';
import '../../core/audio/audio_session_manager.dart';
import '../../core/audio/audio_feedback_service.dart';
import '../../injection_container.dart';
import '../../l10n/app_localizations.dart';

class VoiceSearchFab extends StatefulWidget {
  final ValueChanged<String>? onCommandRecognized;
  final VoidCallback? onInteractionStarted;

  const VoiceSearchFab({
    super.key,
    this.onCommandRecognized,
    this.onInteractionStarted,
  });

  @override
  State<VoiceSearchFab> createState() => _VoiceSearchFabState();
}

class _VoiceSearchFabState extends State<VoiceSearchFab> {
  bool _isListening = false;

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
    final l = AppLocalizations.of(context)!;
    return Semantics(
      label: _isListening ? l.homeListeningButton : l.homeMicButton,
      button: true,
      child: FloatingActionButton.large(
        backgroundColor: _isListening ? Colors.redAccent : Colors.cyanAccent,
        onPressed: _handleVoiceInteraction,
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: Colors.black,
          size: 40,
        ),
      ),
    );
  }
}
