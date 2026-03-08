import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Text-to-Speech service with locale-aware language switching.
///
/// Respects WCAG 2.1 — uses the user's selected language so the
/// screen-reader voice matches the app's UI language.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final FlutterSecureStorage _storage;

  TtsService(this._storage);

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

    await _flutterTts.setLanguage(tag);
    await _flutterTts.setSpeechRate(_currentRate);
    await _flutterTts.setVolume(_currentVolume);
    await _flutterTts.setPitch(1.0);
  }

  /// Updates the TTS engine language at runtime (called on locale switch).
  Future<void> setLanguage(String languageCode) async {
    final tag = _languageTags[languageCode] ?? 'fr-FR';
    await _flutterTts.setLanguage(tag);
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

  Future<void> speak(String text) async {
    debugPrint('TtsService: Speaking -> $text');
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}