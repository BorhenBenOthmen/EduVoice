import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Text-to-Speech service with locale-aware language switching.
///
/// Respects WCAG 2.1 — uses the user's selected language so the
/// screen-reader voice matches the app's UI language.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  /// Maps our supported language codes to BCP-47 locale tags.
  static const Map<String, String> _languageTags = {
    'fr': 'fr-FR',
    'en': 'en-US',
    'ar': 'ar-SA',
  };

  /// Initialises the TTS engine with the given [languageCode].
  /// Defaults to French if not provided or unsupported.
  Future<void> initTts({String languageCode = 'fr'}) async {
    final tag = _languageTags[languageCode] ?? 'fr-FR';
    await _flutterTts.setLanguage(tag);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  /// Updates the TTS engine language at runtime (called on locale switch).
  Future<void> setLanguage(String languageCode) async {
    final tag = _languageTags[languageCode] ?? 'fr-FR';
    await _flutterTts.setLanguage(tag);
  }

  /// Sets the speech rate (0.1 – 1.0). Called from Settings.
  Future<void> setRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.1, 1.0));
  }

  /// Sets the speech volume (0.0 – 1.0). Called from Settings.
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
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