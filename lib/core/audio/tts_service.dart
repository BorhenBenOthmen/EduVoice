import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'audio_session_manager.dart';

/// Text-to-Speech service with locale-aware language switching.
///
/// Automatically manages audio focus via [AudioSessionManager] so that
/// TalkBack is paused while our TTS speaks, preventing overlap.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final FlutterSecureStorage _storage;
  final AudioSessionManager _audioSession;

  TtsService(this._storage, this._audioSession);

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

  /// Speaks the given [text] with automatic audio focus management.
  ///
  /// 1. Stops any in-progress speech
  /// 2. Requests exclusive audio focus (pauses TalkBack)
  /// 3. Speaks the text and waits for completion
  /// 4. Releases audio focus (resumes TalkBack)
  Future<void> speak(String text) async {
    debugPrint('TtsService: Speaking -> $text');
    
    try {
      // Stop any in-progress speech to prevent queue pile-up
      await _flutterTts.stop();
      
      // Request exclusive focus — this pauses TalkBack
      await _audioSession.requestExclusiveFocus();
      
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TtsService: Error during speak: $e');
    } finally {
      // Always release focus, even if speak throws
      try {
        await _audioSession.releaseFocus();
      } catch (_) {}
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