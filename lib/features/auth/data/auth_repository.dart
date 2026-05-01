import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/api_constants.dart';
import '../../../core/auth/token_manager.dart';

class AuthRepository {
  final TokenManager _tokenManager;
  final http.Client _client; // This will be our AuthClient

  AuthRepository(this._tokenManager, this._client);

  /// Authenticates user and saves tokens. Returns true if successful.
  Future<bool> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[AuthRepository] LOGIN RESPONSE KEYS: ${data.keys.toList()}');
        debugPrint('[AuthRepository] LOGIN RESPONSE: ${response.body.substring(0, response.body.length.clamp(0, 500))}');
        final int? accountId = data['id'] as int?;
        if (accountId == null) {
          // The backend returned no account ID — cannot proceed safely.
          throw Exception("Login response missing account 'id' field.");
        }
        
        String? firstName;
        String? lastName;
        String? levelName;
        final accessToken = data['access'] as String?;

        // 1. Fetch the profile data using the new access token
        if (accessToken != null) {
          try {
            final profileUrl = '${ApiConstants.baseUrl}/account/detail/1/$accountId/';
            debugPrint('[AuthRepository] Fetching profile from: $profileUrl');
            
            // We use a raw http.get here because the token isn't in TokenManager yet
            final profileResponse = await http.get(
              Uri.parse(profileUrl),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
            );

            if (profileResponse.statusCode == 200) {
              final profileData = jsonDecode(profileResponse.body);
              debugPrint('[AuthRepository] PROFILE RESPONSE: ${profileResponse.body.substring(0, profileResponse.body.length.clamp(0, 500))}');
              
              if (profileData.containsKey('first_name')) {
                firstName = profileData['first_name'] as String?;
              } else if (profileData.containsKey('user') && profileData['user'] is Map) {
                firstName = profileData['user']['first_name'] as String?;
              }

              if (profileData.containsKey('last_name')) {
                lastName = profileData['last_name'] as String?;
              } else if (profileData.containsKey('user') && profileData['user'] is Map) {
                lastName = profileData['user']['last_name'] as String?;
              }
              
              if (profileData.containsKey('level') && profileData['level'] is Map) {
                levelName = profileData['level']['name'] as String?;
              }
            } else {
              debugPrint('[AuthRepository] Failed to fetch profile, status: ${profileResponse.statusCode}');
            }
          } catch (e) {
            debugPrint('[AuthRepository] Error fetching profile: $e');
          }
        }

        // 2. Save all tokens and profile info
        await _tokenManager.saveTokens(
          access: accessToken ?? '',
          refresh: data['refresh'] ?? '',
          accountId: accountId,
          firstName: firstName,
          lastName: lastName,
          levelName: levelName,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AuthRepository] Login Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenManager.clearTokens();
  }

  /// Changes the user's password via the Django backend.
  ///
  /// Returns `null` on success, or a localized-key-style error string on failure:
  ///   - `'mismatch'`   — the two new passwords didn't match (caller-side check)
  ///   - `'old_wrong'`  — the server rejected the current password (403)
  ///   - `'network'`    — any other HTTP / network error
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final accountId = await _tokenManager.getAccountId();
      if (accountId == null) return 'network';

      final token = await _tokenManager.getAccessToken();
      if (token == null) return 'network';

      // Use a fresh http.Client to avoid any AuthClient interceptor weirdness
      // with PUT/PATCH requests and JSON bodies.
      final client = http.Client();
      try {
        final response = await client.patch(
          Uri.parse(ApiConstants.changePassword(accountId)),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'password': oldPassword,
            'new_password': newPassword,
            'new_password_verification': confirmPassword,
          }),
        );

        debugPrint('[AuthRepository] changePassword status: ${response.statusCode}');
        debugPrint('[AuthRepository] changePassword body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 204) {
          return null; // success
        } else if (response.statusCode == 403 || response.statusCode == 400) {
          // Backend rejected the current password or validation failed
          return 'old_wrong';
        } else {
          return 'network';
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('[AuthRepository] changePassword error: $e');
      return 'network';
    }
  }
}