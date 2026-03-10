// lib/features/podcast_hub/data/repositories/podcast_repository_impl.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../domain/entities/podcast.dart';
import '../../domain/repositories/i_podcast_repository.dart';
import '../models/podcast_model.dart';
import '../../../../core/network/auth_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/auth/token_manager.dart';

class PodcastRepositoryImpl implements IPodcastRepository {
  final AuthClient _authClient;
  // ignore: unused_field
  final TokenManager _tokenManager;

  PodcastRepositoryImpl(this._authClient, this._tokenManager);

  @override
  Future<List<Podcast>> fetchPodcasts() async {
    try {
      const accountId = 1;

      final uri = Uri.parse('${ApiConstants.baseUrl}/podcast/list/$accountId/');

      final response = await _authClient.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> items = responseData['items'] ?? [];

        return items.map((json) => PodcastModel.fromJson(json)).toList();
      } else {
        throw Exception(
          "Invalid Status Code: ${response.statusCode} | Body: ${response.body}",
        );
      }
    } catch (e, stacktrace) {
      debugPrint("====== PODCAST REPOSITORY FETCH ERROR ======");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      debugPrint("====================================");
      throw Exception(e.toString());
    }
  }
}
