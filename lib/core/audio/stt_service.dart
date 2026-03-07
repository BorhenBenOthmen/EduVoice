import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';

class SttService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  // Explicit async initialization
  Future<void> initStt() async {
    if (_isInitialized) return;
    
    _isInitialized = await _speechToText.initialize(
      onError: (error) => debugPrint('STT Error: $error'),
      onStatus: (status) => debugPrint('STT Status: $status'),
    );
    
    if (!_isInitialized) {
      debugPrint("Failed to initialize Speech-to-Text. Check permissions.");
    }
  }

  Future<void> startListening(Function(String text) onResult) async {
    // If it's already initialized during boot, this instantly passes
    if (!_isInitialized) await initStt();

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: 'fr-FR', 
      cancelOnError: true,
      partialResults: true, 
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}