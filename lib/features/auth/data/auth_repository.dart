import 'dart:convert';
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
        final int? accountId = data['id'] as int?;
        if (accountId == null) {
          // The backend returned no account ID — cannot proceed safely.
          throw Exception("Login response missing account 'id' field.");
        }
        
        // Extract user info based on the schema
        String? firstName;
        String? levelName;
        
        // Handle variations of JSON schema (AuthAccountSchema / AccountSchema)
        if (data.containsKey('first_name')) {
          firstName = data['first_name'] as String?;
        } else if (data.containsKey('user') && data['user'] is Map) {
          firstName = data['user']['first_name'] as String?;
        }
        
        if (data.containsKey('level') && data['level'] is Map) {
          levelName = data['level']['name'] as String?;
        }

        await _tokenManager.saveTokens(
          access: data['access'] ?? '', // Fallback to empty string if missing
          refresh: data['refresh'] ?? '',
          accountId: accountId,
          firstName: firstName,
          levelName: levelName,
        );
        return true;
      }
      return false;
    } catch (e) {
      // TODO: Log error or pass to a Crashlytics service
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenManager.clearTokens();
  }
}