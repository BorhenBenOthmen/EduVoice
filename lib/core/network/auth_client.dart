import 'package:http/http.dart' as http;
import '../auth/token_manager.dart';

/// Intercepts outgoing HTTP requests to attach the Bearer token.
/// Automatically handles 401 Unauthorized by attempting a token refresh.
class AuthClient extends http.BaseClient {
  final http.Client _inner;
  final TokenManager _tokenManager;

  AuthClient(this._inner, this._tokenManager);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _tokenManager.getAccessToken();
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    var response = await _inner.send(request);

    // Reactive Refresh: If unauthorized, attempt to refresh token and retry once.
    if (response.statusCode == 401) {
      final refreshed = await _tokenManager.refreshToken();
      if (refreshed) {
        final newToken = await _tokenManager.getAccessToken();
        
        // Clone the request since it has already been sent
        final retryRequest = _cloneRequest(request);
        retryRequest.headers['Authorization'] = 'Bearer $newToken';
        
        response = await _inner.send(retryRequest);
      }
    }

    return response;
  }

  http.BaseRequest _cloneRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final clone = http.Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
      clone.headers.addAll(request.headers);
      return clone;
    }
    // Fallback for other request types
    return request;
  }
}