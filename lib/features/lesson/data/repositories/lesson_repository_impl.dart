// lib/data/repositories/lesson_repository_impl.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for debugPrint

import '../../domain/entities/lesson.dart';
import '../../domain/repositories/i_lesson_repository.dart';
import '../models/lesson_model.dart';
import '../../../../core/network/auth_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/auth/token_manager.dart';

class LessonRepositoryImpl implements ILessonRepository {
  final AuthClient _authClient;
  // ignore: unused_field — kept for future use when accountId is read from storage
  final TokenManager _tokenManager;

  LessonRepositoryImpl(this._authClient, this._tokenManager);

  @override
  Future<List<Lesson>> fetchLessons() async {
    try {
      final accountId = await _tokenManager.getAccountId();
      if (accountId == null) {
        throw Exception("User not authenticated.");
      }

      // Use the search endpoint filtered by the student's level so that
      // only lessons matching their grade are returned.
      final levelName = await _tokenManager.getLevelName();

      final queryParams = <String, String>{};
      if (levelName != null && levelName.isNotEmpty) {
        queryParams['level'] = levelName;
      }

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/lesson/search/$accountId/',
      ).replace(queryParameters: queryParams);

      debugPrint('LessonRepository: fetching $uri');
      final response = await _authClient.get(uri);

      if (response.statusCode == 200) {
        // Parse the raw JSON string defensively
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> items = responseData['items'] ?? [];

        final lessons = items
            .map((json) => LessonModel.fromJson(json))
            .toList();

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

      throw Exception(e.toString());
    }
  }
}
