import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../network/api_constants.dart';

class TokenManager {
  final FlutterSecureStorage _storage;
  Timer? _refreshTimer;

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';
  static const String _accountIdKey = 'account_id';
  static const String _firstNameKey = 'first_name';
  static const String _levelNameKey = 'level_name';

  TokenManager(this._storage);

  Future<void> saveTokens({
    required String access,
    required String refresh,
    required int accountId,
    String? firstName,
    String? levelName,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _accountIdKey, value: accountId.toString());
    if (firstName != null) {
      await _storage.write(key: _firstNameKey, value: firstName);
    }
    if (levelName != null) {
      await _storage.write(key: _levelNameKey, value: levelName);
    }
    _startRefreshTimer();
  }

  Future<int?> getAccountId() async {
    final value = await _storage.read(key: _accountIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  Future<String?> getFirstName() async => await _storage.read(key: _firstNameKey);
  Future<String?> getLevelName() async => await _storage.read(key: _levelNameKey);

  Future<String?> getAccessToken() async =>
      await _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() async =>
      await _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _accountIdKey);
    await _storage.delete(key: _firstNameKey);
    await _storage.delete(key: _levelNameKey);
    _refreshTimer?.cancel();
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    if (token == null) return false;

    if (_isTokenExpired(token)) {
      // Access token is expired, attempt to refresh
      final refreshed = await refreshToken();
      if (refreshed) {
        // _startRefreshTimer is called inside saveTokens which is called inside refreshToken
        return true;
      }
      return false; // Refresh failed, session is invalid
    }

    // Token is valid and not expired
    _startRefreshTimer();
    return true;
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true; // Invalid token format
      }

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final String decodedPayload = utf8.decode(
        base64Url.decode(normalizedPayload),
      );
      final Map<String, dynamic> payloadMap = jsonDecode(decodedPayload);

      final exp = payloadMap['exp'];
      if (exp == null) return true;

      // exp is typically in seconds since epoch
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      // Consider token expired if it expires within the next minute (safety margin)
      return DateTime.now()
          .add(const Duration(minutes: 1))
          .isAfter(expirationDate);
    } catch (e) {
      // If any error occurs during parsing, consider the token invalid
      return true;
    }
  }

  /// Refreshes the token proactively
  Future<bool> refreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The API might return both access and refresh, or just access.
        final newAccess = data['access'];
        final newRefresh = data['refresh'] ?? refresh;
        // Preserve the existing account ID — the refresh endpoint doesn't change it.
        final existingAccountId = await getAccountId() ?? 0;

        await saveTokens(
          access: newAccess,
          refresh: newRefresh,
          accountId: existingAccountId,
        );
        return true;
      } else {
        await clearTokens();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Starts a timer to refresh the token every 14 minutes (proactive approach)
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    // 14 minutes to be safe before the 15-minute expiration
    _refreshTimer = Timer.periodic(const Duration(minutes: 14), (timer) {
      refreshToken();
    });
  }
}
