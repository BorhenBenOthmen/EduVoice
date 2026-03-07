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

  TokenManager(this._storage);

  Future<void> saveTokens({
    required String access,
    required String refresh,
    required int accountId,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _accountIdKey, value: accountId.toString());
    _startRefreshTimer();
  }

  Future<int?> getAccountId() async {
    final value = await _storage.read(key: _accountIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _accountIdKey);
    _refreshTimer?.cancel();
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    if (token != null) {
      _startRefreshTimer();
      return true;
    }
    return false;
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