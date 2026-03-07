// lib/data/repositories/lesson_repository_impl.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for debugPrint

import '../../domain/entities/lesson.dart';
import '../../domain/repositories/i_lesson_repository.dart';
import '../models/lesson_model.dart';
import '../../../../core/network/auth_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../core/auth/token_manager.dart';

class LessonRepositoryImpl implements ILessonRepository {
  final AuthClient _authClient;
  final TtsService _ttsService;
  // ignore: unused_field — kept for future use when accountId is read from storage
  final TokenManager _tokenManager;

  LessonRepositoryImpl(this._authClient, this._ttsService, this._tokenManager);

  @override
  Future<List<Lesson>> fetchLessons() async {
    // Accessibility hook: Announce network initialization
    await _ttsService.speak("جاري تحميل الدروس، يرجى الانتظار.");

    try {
      // Hardcoded account ID for testing.
      const accountId = 1;

      // Correct endpoint: /lesson/list/{current_account_id}/
      final uri = Uri.parse('${ApiConstants.baseUrl}/lesson/list/$accountId/');

      final response = await _authClient.get(uri);

      if (response.statusCode == 200) {
        // Parse the raw JSON string defensively
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> items = responseData['items'] ?? [];

        final lessons = items
            .map((json) => LessonModel.fromJson(json))
            .toList();

        // Accessibility hook: Confirm success
        await _ttsService.speak("تم العثور على ${lessons.length} دروس.");
        return lessons;
      } else {
        throw Exception(
          "Invalid Status Code: ${response.statusCode} | Body: ${response.body}",
        );
      }
    } catch (e, stacktrace) {
      // Hardened Debugging: Print the exact failure to the VS Code console
      debugPrint("====== REPOSITORY FETCH ERROR ======");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      debugPrint("====================================");

      // Accessibility hook: Graceful error announcement
      await _ttsService.speak(
        "حدث خطأ أثناء تحميل الدروس. يرجى المحاولة مرة أخرى.",
      );
      throw Exception(e.toString());
    }
  }
}
