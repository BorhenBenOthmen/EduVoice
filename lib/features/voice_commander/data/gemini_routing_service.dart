import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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

  // AI backend WebSocket URL.
  // Uses adb reverse tunnel (adb reverse tcp:8000 tcp:8000) so the phone
  // reaches the PC's FastAPI server over USB — no Wi-Fi IP needed.
  final String _baseWsUrl = 'ws://127.0.0.1:8000/ws';

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isGeminiSpeaking = false;
  Timer? _speechTimer;

  GeminiRoutingService(this._tokenManager);

  Future<void> connect({VoidCallback? onErrorCallback}) async {
    if (_isConnected) return;

    // ── FIX 1: Always clean up any previous session before starting a new one.
    // This prevents a stale recorder stream / subscription from a previous
    // session that didn't clean up properly (e.g. background kill, crash).
    await _cleanup();

    // ── FIX 2: Always reset speaking flag so mic is never silently muted
    // at the start of a fresh session.
    _isGeminiSpeaking = false;
    _speechTimer?.cancel();
    _speechTimer = null;

    try {
      final firstName = await _tokenManager.getFirstName() ?? 'Student';
      final levelName = await _tokenManager.getLevelCode() ?? 'primary_6';

      debugPrint(
        '[GeminiRoutingService] Connecting as: name=$firstName, grade_level=$levelName',
      );

      final token = await _tokenManager.getAccessToken() ?? '';

      final wsUrl = Uri.parse(
        '$_baseWsUrl?name=$firstName&grade_level=${Uri.encodeComponent(levelName)}&primary_language=Arabic&token=${Uri.encodeComponent(token)}',
      );

      debugPrint('Connecting to Voice Commander AI WebSocket at $wsUrl');
      _channel = WebSocketChannel.connect(wsUrl);

      // Wait for the actual TCP+WS handshake to complete before proceeding.
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
            // The backend prepends a 4-byte big-endian generation_id header to
            // every audio chunk for barge-in tracking. We must skip those bytes
            // before feeding raw PCM to the speaker.
            const int headerBytes = 4;
            if (data.lengthInBytes <= headerBytes) return; // safety guard

            FlutterPcmSound.feed(
              PcmArrayInt16(
                bytes: ByteData.view(
                  data.buffer,
                  data.offsetInBytes + headerBytes, // skip header
                  data.lengthInBytes - headerBytes, // trim length
                ),
              ),
            );

            // Software Echo Cancellation: Mute mic while playing
            _isGeminiSpeaking = true;
            _speechTimer?.cancel();
            _speechTimer = Timer(const Duration(milliseconds: 1000), () {
              _isGeminiSpeaking = false;
            });
          } else if (data is String) {
            // ── JSON control messages from backend ──
            try {
              final Map<String, dynamic> json = jsonDecode(data);
              final String? type = json['type'] as String?;

              if (type == 'interrupt') {
                // Barge-in: clear the playback buffer immediately.
                debugPrint(
                  '[GeminiRoutingService] Interrupt received — flushing audio buffer.',
                );
                // ── FIX 3: Also reset the speaking flag on interrupt so the
                // mic is unmuted immediately after barge-in is detected.
                _isGeminiSpeaking = false;
                _speechTimer?.cancel();
                FlutterPcmSound.feed(PcmArrayInt16.zeros(count: 0));
              } else if (type == 'ui_navigation') {
                final String? route = json['route'] as String?;
                final dynamic payload = json['payload'];

                debugPrint(
                  '[GeminiRoutingService] Navigation command → $route',
                );

                if (route != null && route.isNotEmpty) {
                  // Future.microtask executes instantly! No swiping down required.
                  Future.microtask(() {
                    final navState = EduVoiceApp.navigatorKey.currentState;
                    if (navState != null) {
                      final resolvedRoute = AppRouteResolver.resolve(
                        route,
                        payload,
                      );
                      if (resolvedRoute != null) {
                        navState.push(resolvedRoute);
                      } else {
                        debugPrint(
                          '[GeminiRoutingService] Unknown route: $route — ignoring.',
                        );
                      }
                    } else {
                      debugPrint(
                        '[GeminiRoutingService] Navigator not mounted — cannot navigate.',
                      );
                    }
                  });
                }
              } else if (type == 'turn_complete') {
                // Silently ignore turn_complete to stop log spamming
              } else {
                debugPrint('[GeminiRoutingService] Unhandled JSON type: $type');
              }
            } catch (e) {
              debugPrint(
                '[GeminiRoutingService] Failed to parse JSON message: $e',
              );
            }
          } else {
            debugPrint(
              '[GeminiRoutingService] Received unexpected data type: ${data.runtimeType}',
            );
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
    // ── FIX 4: Always cancel any existing subscription before starting a new
    // stream. Ensures no two subscriptions ever feed the same or different
    // channels simultaneously.
    await _recordSubscription?.cancel();
    _recordSubscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }

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
        // Guard: only send if channel is still alive and mic is not muted
        if (_channel != null && _isConnected && !_isGeminiSpeaking) {
          _channel!.sink.add(data);
        }
      });
      debugPrint('Recording started and streaming to Gemini...');
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
    _speechTimer?.cancel();
    _speechTimer = null;
    _isGeminiSpeaking = false;
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
    } else {
      debugPrint('Cannot send message: WebSocket is not connected');
    }
  }
}
