import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:record/record.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import '../../../core/auth/token_manager.dart';

class GeminiRoutingService {
  final TokenManager _tokenManager;
  WebSocketChannel? _channel;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _recordSubscription;

  // AI backend WebSocket URL.
  final String _baseWsUrl = 'ws://10.165.155.12:8000/ws';

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isGeminiSpeaking = false;
  Timer? _speechTimer;

  GeminiRoutingService(this._tokenManager);

  Future<void> connect({VoidCallback? onErrorCallback}) async {
    if (_isConnected) return;

    try {
      final firstName = await _tokenManager.getFirstName() ?? 'Student';
      final levelName = await _tokenManager.getLevelName() ?? 'primary_4';

      final wsUrl = Uri.parse(
        '$_baseWsUrl?name=$firstName&grade_level=${Uri.encodeComponent(levelName)}&primary_language=Arabic',
      );

      debugPrint('Connecting to Voice Commander AI WebSocket at $wsUrl');
      _channel = WebSocketChannel.connect(wsUrl);

      // Wait for the actual TCP+WS handshake to complete before proceeding.
      // Without this, the channel object exists but the connection may have
      // silently failed (e.g. cleartext blocked, host unreachable).
      await _channel!.ready.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException('WebSocket handshake timed out after 8s');
        },
      );

      _isConnected = true;
      debugPrint('Voice Commander AI WebSocket connected successfully.');

      // Handle output from Gemini (Audio bytes)
      _setupPlayback();

      _channel?.stream.listen(
        (data) {
          if (data is Uint8List) {
            FlutterPcmSound.feed(
              PcmArrayInt16(
                bytes: ByteData.view(
                  data.buffer,
                  data.offsetInBytes,
                  data.lengthInBytes,
                ),
              ),
            );

            // Software Echo Cancellation: Mute mic while playing
            _isGeminiSpeaking = true;
            _speechTimer?.cancel();
            _speechTimer = Timer(const Duration(milliseconds: 1000), () {
              _isGeminiSpeaking = false;
            });
          } else {
            // Might be JSON message?
            debugPrint('Received non-binary data from Gemini: $data');
          }
        },
        onError: (error) {
          debugPrint('Voice Commander AI WebSocket Error: $error');
          onErrorCallback?.call();
          _handleDisconnection();
        },
        onDone: () {
          debugPrint('Voice Commander AI WebSocket Closed');
          _handleDisconnection();
        },
      );

      // Start Recording
      await _startRecording();
    } catch (e, stackTrace) {
      debugPrint('Voice Commander AI Connection exception: $e');
      debugPrint('Stack trace: $stackTrace');
      _isConnected = false;
      _channel?.sink.close();
      _channel = null;
      onErrorCallback?.call();
    }
  }

  Future<void> _setupPlayback() async {
    // Gemini Live API returns audio at 24000Hz PCM
    await FlutterPcmSound.setup(sampleRate: 24000, channelCount: 1); // 1 = mono
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: false,
        noiseSuppress: false,
      );

      final recordStream = await _recorder.startStream(config);

      _recordSubscription = recordStream.listen((data) {
        if (_channel != null && _isConnected) {
          if (!_isGeminiSpeaking) {
            _channel!.sink.add(data);
          }
        }
      });
      debugPrint('Recording started and streaming to Gemini...');
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _cleanup();
  }

  void disconnect() {
    _handleDisconnection();
    _channel?.sink.close();
    _channel = null;
  }

  Future<void> _cleanup() async {
    _speechTimer?.cancel();
    await _recordSubscription?.cancel();
    _recordSubscription = null;
    await _recorder.stop();
    await FlutterPcmSound.release();
  }

  void sendMessage(String message) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(message);
    } else {
      debugPrint('Cannot send message: WebSocket is not connected');
    }
  }
}
