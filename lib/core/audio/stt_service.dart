import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../injection_container.dart';
import '../network/api_client.dart';

class SttService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _audioFilePath;
  Function(String text)? _onResult;
  bool _isListening = false;

  Future<void> initStt() async {
    if (await _audioRecorder.hasPermission()) {
      debugPrint("Audio recorder initialized properly.");
    } else {
      debugPrint("Failed to get audio recording permissions.");
    }
  }

  Future<void> startListening(Function(String text) onResult) async {
    if (await _audioRecorder.hasPermission()) {
      _onResult = onResult;
      
      final tempDir = await getTemporaryDirectory();
      _audioFilePath = '${tempDir.path}/voice_command.m4a';
      
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _audioFilePath!,
      );
      _isListening = true;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    final path = await _audioRecorder.stop();
    _isListening = false;

    if (path != null && _onResult != null) {
      final file = File(path);
      if (await file.exists()) {
        try {
          final apiClient = locator<ApiClient>();
          debugPrint("Sending audio command to backend: $path");
          final replyText = await apiClient.sendVoiceCommandAudio(file);
          
          if (replyText.isNotEmpty) {
            _onResult!(replyText);
          }
        } catch (e) {
          debugPrint("SttService: Backend call failed: $e");
          _onResult!("Erreur de connexion au serveur.");
        }
      }
    }
  }

  bool get isListening => _isListening;
}
