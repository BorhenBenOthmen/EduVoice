import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';
import '../../injection_container.dart';
import '../locale/locale_service.dart';

class SttService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  // Explicit async initialization
  Future<void> initStt() async {
    if (_isInitialized) return;

    _isInitialized = await _speechToText.initialize(
      onError: (error) => debugPrint('STT Error: ${error.errorMsg}'),
      onStatus: (status) => debugPrint('STT Status: $status'),
    );

    if (!_isInitialized) {
      debugPrint("Failed to initialize Speech-to-Text. Check permissions.");
    }
  }

  Future<void> startListening(Function(String text) onResult) async {
    // If it's already initialized during boot, this instantly passes
    if (!_isInitialized) await initStt();

    // Determine the user's active language
    String localeId = 'fr-FR'; // fallback
    try {
      final localeService = locator<LocaleService>();
      final langCode = localeService.current.languageCode;

      switch (langCode) {
        case 'ar':
          localeId = 'ar-SA';
          break;
        case 'en':
          localeId = 'en-US';
          break;
        case 'fr':
        default:
          localeId = 'fr-FR';
          break;
      }
    } catch (e) {
      debugPrint("Error fetching locale for STT: $e");
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}
