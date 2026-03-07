// lib/core/audio/audio_session_manager.dart

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Core Lego Brick for OS-Level Audio Control.
/// Ensures TalkBack/VoiceOver do not speak over our custom TTS or Media.
class AudioSessionManager {
  AudioSession? _session;

  /// Initializes the audio session with speech-optimized configurations.
  Future<void> initSession() async {
    try {
      _session = await AudioSession.instance;
      
      // We configure for speech to prioritize TTS and STT clarity.
      await _session!.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.audibilityEnforced,
          usage: AndroidAudioUsage.assistanceAccessibility,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: true,
      ));
      
      debugPrint("✅ AudioSessionManager initialized successfully.");
    } catch (e) {
      debugPrint("❌ Failed to initialize AudioSessionManager: $e");
      // TODO: [Omni-Architect] Trigger global fallback error sound here.
    }
  }

  /// Call this right before playing Gemini TTS or opening the mic.
  /// It forcefully requests focus, ducking TalkBack.
  Future<bool> requestExclusiveFocus() async {
    if (_session == null) return false;
    
    final success = await _session!.setActive(true);
    if (!success) {
      debugPrint("⚠️ Could not gain exclusive audio focus.");
    }
    return success;
  }

  /// Call this when the app is done speaking to return focus to the OS.
  Future<void> releaseFocus() async {
    if (_session == null) return;
    await _session!.setActive(false);
  }
}