import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:audio_session/audio_session.dart';

/// Text-to-Speech service with locale-aware language switching.
///
/// Requests exclusive OS audio focus before speaking so that TalkBack
/// is ducked/paused, then releases focus when done.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final FlutterSecureStorage _storage;
  AudioSession? _audioSession;

  TtsService(this._storage);

  /// Call once at app startup (after [setupDependencies]) to configure the
  /// audio session for speech use. Safe to call multiple times.
  Future<void> _ensureSession() async {
    _audioSession ??= await AudioSession.instance;
    await _audioSession!.configure(const AudioSessionConfiguration(
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
  }

  static const _rateKey = 'tts_rate';
  static const _volumeKey = 'tts_volume';

  double _currentRate = 0.5;
  double _currentVolume = 1.0;

  double get currentRate => _currentRate;
  double get currentVolume => _currentVolume;

  /// Maps our supported language codes to BCP-47 locale tags.
  static const Map<String, String> _languageTags = {
    'fr': 'fr-FR',
    'en': 'en-US',
    'ar': 'ar-SA',
  };

  /// Initialises the TTS engine with the given [languageCode] and saved preferences.
  /// Defaults to French if not provided or unsupported.
  Future<void> initTts({String languageCode = 'fr'}) async {
    final tag = _languageTags[languageCode] ?? 'fr-FR';
    
    // Load saved preferences
    final savedRateStr = await _storage.read(key: _rateKey);
    final savedVolStr = await _storage.read(key: _volumeKey);
    
    _currentRate = savedRateStr != null ? double.tryParse(savedRateStr) ?? 0.5 : 0.5;
    _currentVolume = savedVolStr != null ? double.tryParse(savedVolStr) ?? 1.0 : 1.0;

    try {
      await _flutterTts.setLanguage(tag);
    } catch (e) {
      debugPrint('TtsService: Failed to set language $tag, falling back to fr-FR: $e');
      try { await _flutterTts.setLanguage('fr-FR'); } catch (_) {}
    }
    await _flutterTts.setSpeechRate(_currentRate);
    await _flutterTts.setVolume(_currentVolume);
    await _flutterTts.setPitch(1.0);
  }

  /// Updates the TTS engine language at runtime (called on locale switch).
  /// Returns true if the language was set successfully.
  Future<bool> setLanguage(String languageCode) async {
    final tag = _languageTags[languageCode] ?? 'fr-FR';
    try {
      // Check if the language is available on this device
      final available = await _flutterTts.isLanguageAvailable(tag);
      if (available == true) {
        await _flutterTts.setLanguage(tag);
        debugPrint('TtsService: Language set to $tag');
        return true;
      } else {
        debugPrint('TtsService: Language $tag not available on device');
        return false;
      }
    } catch (e) {
      debugPrint('TtsService: Error setting language $tag: $e');
      return false;
    }
  }

  /// Sets the speech rate (0.1 – 1.0). Called from Settings.
  Future<void> setRate(double rate) async {
    _currentRate = rate.clamp(0.1, 1.0);
    await _storage.write(key: _rateKey, value: _currentRate.toString());
    await _flutterTts.setSpeechRate(_currentRate);
  }

  /// Sets the speech volume (0.0 – 1.0). Called from Settings.
  Future<void> setVolume(double volume) async {
    _currentVolume = volume.clamp(0.0, 1.0);
    await _storage.write(key: _volumeKey, value: _currentVolume.toString());
    await _flutterTts.setVolume(_currentVolume);
  }

  /// Speaks the given [text], ducking TalkBack for the duration.
  Future<void> speak(String text) async {
    debugPrint('TtsService: Speaking -> $text');
    try {
      await _ensureSession();
      await _flutterTts.stop();
      await _audioSession!.setActive(true);
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TtsService: Error during speak: $e');
    } finally {
      try { await _audioSession?.setActive(false); } catch (_) {}
    }
  }

  /// Speaks a notification: reads [announcement] first, then [text].
  /// Ducks TalkBack for the full sequence.
  /// Automatically switches to Arabic TTS voice if [text] contains Arabic characters.
  Future<void> speakNotification(String announcement, String text) async {
    debugPrint('TtsService: Speaking Notification -> $text');
    try {
      await _ensureSession();
      await _flutterTts.stop();
      await _audioSession!.setActive(true);
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.speak(announcement);

      final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      if (isArabic) {
        await _flutterTts.setLanguage('ar-SA');
      }
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TtsService: Error during speakNotification: $e');
    } finally {
      try { await _audioSession?.setActive(false); } catch (_) {}
    }
  }

  /// Speaks after a short delay to let TalkBack finish announcing
  /// the new page's elements after a navigation transition.
  ///
  /// Use this in BlocListeners and post-navigation callbacks.
  Future<void> speakWithDelay(String text, {int delayMs = 500}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    await speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}