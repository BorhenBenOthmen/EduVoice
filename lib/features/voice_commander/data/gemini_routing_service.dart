import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:record/record.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import '../../../core/auth/token_manager.dart';
import '../../../core/navigation/app_route_resolver.dart';
import '../../../main.dart';

class GeminiRoutingService {
  final TokenManager _tokenManager;
  WebSocketChannel? _channel;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _recordSubscription;

  final String _baseWsUrl = 'ws://127.0.0.1:8000/ws';

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // -------------------------------------------------------------
  // STRICT SOFTWARE MUTING STATE
  // -------------------------------------------------------------
  bool _isAiSpeaking = false;
  Timer? _safetyUnmuteTimer;

  GeminiRoutingService(this._tokenManager);

  Future<void> connect({VoidCallback? onErrorCallback}) async {
    if (_isConnected) return;

    await _cleanup();

    try {
      final firstName = await _tokenManager.getFirstName() ?? 'Student';
      final levelName = await _tokenManager.getLevelCode() ?? 'primary_6';

      final token = await _tokenManager.getAccessToken() ?? '';

      final wsUrl = Uri.parse(
        '$_baseWsUrl?name=$firstName&grade_level=${Uri.encodeComponent(levelName)}&primary_language=Arabic&token=${Uri.encodeComponent(token)}',
      );

      debugPrint('Connecting to Voice Commander AI WebSocket at $wsUrl');
      _channel = WebSocketChannel.connect(wsUrl);

      await _channel!.ready.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException('WebSocket handshake timed out after 8s');
        },
      );

      _isConnected = true;
      debugPrint('Voice Commander AI WebSocket connected successfully.');

      _setupPlayback();

      _channel?.stream.listen(
        (data) {
          if (data is Uint8List) {
            const int headerBytes = 4;
            if (data.lengthInBytes <= headerBytes) return;

            // 1. The AI sent audio. MUTE THE MIC IMMEDIATELY.
            _isAiSpeaking = true;
            
            // Safety fallback: If turn_complete gets lost, unmute after 3 seconds of silence.
            _safetyUnmuteTimer?.cancel();
            _safetyUnmuteTimer = Timer(const Duration(seconds: 3), () {
               _isAiSpeaking = false;
               debugPrint('[GeminiRoutingService] Safety unmute triggered.');
            });

            // 2. Play the audio
            FlutterPcmSound.feed(
              PcmArrayInt16(
                bytes: ByteData.view(
                  data.buffer,
                  data.offsetInBytes + headerBytes,
                  data.lengthInBytes - headerBytes,
                ),
              ),
            );

          } else if (data is String) {
            try {
              final Map<String, dynamic> json = jsonDecode(data);
              final String? type = json['type'] as String?;

              if (type == 'turn_complete') {
                // 3. The AI finished its entire thought! UNMUTE THE MIC.
                debugPrint('[GeminiRoutingService] AI finished speaking. Mic Unmuted.');
                _isAiSpeaking = false;
                _safetyUnmuteTimer?.cancel();

              } else if (type == 'interrupt') {
                debugPrint('[GeminiRoutingService] Interrupt received — flushing audio buffer.');
                FlutterPcmSound.feed(PcmArrayInt16.zeros(count: 0));
                
              } else if (type == 'ui_navigation') {
                final String? route = json['route'] as String?;
                final dynamic payload = json['payload'];

                if (route != null && route.isNotEmpty) {
                  Future.microtask(() {
                    final navState = EduVoiceApp.navigatorKey.currentState;
                    if (navState != null) {
                      final resolvedRoute = AppRouteResolver.resolve(route, payload);
                      if (resolvedRoute != null) {
                        navState.push(resolvedRoute);
                      }
                    }
                  });
                }
              }
            } catch (e) {
              debugPrint('[GeminiRoutingService] Failed to parse JSON: $e');
            }
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

      await _startRecording();
    } catch (e) {
      debugPrint('Voice Commander AI Connection exception: $e');
      _isConnected = false;
      _channel?.sink.close();
      _channel = null;
      onErrorCallback?.call();
    }
  }

  Future<void> _setupPlayback() async {
    await FlutterPcmSound.setup(sampleRate: 24000, channelCount: 1); 
  }

  Future<void> _startRecording() async {
    await _recordSubscription?.cancel();
    _recordSubscription = null;
    
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}

    if (await _recorder.hasPermission()) {
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: true,      
        noiseSuppress: true,   
      );

      final recordStream = await _recorder.startStream(config);

      _recordSubscription = recordStream.listen((data) {
        if (_channel != null && _isConnected) {
          // -------------------------------------------------------------
          // STRICT MIC GATE: Only send data if the AI is totally silent!
          // -------------------------------------------------------------
          if (!_isAiSpeaking) {
            _channel!.sink.add(data);
          }
        }
      });
      debugPrint('Recording started. Strict Mute Gate active.');
    } else {
      debugPrint('[GeminiRoutingService] Microphone permission denied!');
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
    _safetyUnmuteTimer?.cancel();
    await _recordSubscription?.cancel();
    _recordSubscription = null;
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
    try {
      await FlutterPcmSound.release();
    } catch (_) {}
  }

  void sendMessage(String message) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(message);
    }
  }
}