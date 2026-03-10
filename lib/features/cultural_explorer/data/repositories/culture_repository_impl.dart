// lib/features/cultural_explorer/data/repositories/culture_repository_impl.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../domain/entities/culture_record.dart';
import '../../domain/repositories/i_culture_repository.dart';
import '../models/culture_model.dart';
import '../../../../core/network/auth_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/auth/token_manager.dart';

class CultureRepositoryImpl implements ICultureRepository {
  final AuthClient _authClient;
  // ignore: unused_field
  final TokenManager _tokenManager;

  CultureRepositoryImpl(this._authClient, this._tokenManager);

  @override
  Future<List<CultureRecord>> fetchCultureRecords() async {
    try {
      const accountId = 1;

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/culture/record/list/$accountId/',
      );

      final response = await _authClient.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> items = responseData['items'] ?? [];

        return items.map((json) => CultureModel.fromJson(json)).toList();
      } else {
        throw Exception(
          "Invalid Status Code: ${response.statusCode} | Body: ${response.body}",
        );
      }
    } catch (e, stacktrace) {
      debugPrint("====== CULTURE REPOSITORY FETCH ERROR ======");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      debugPrint("====================================");
      throw Exception(e.toString());
    }
  }
}
