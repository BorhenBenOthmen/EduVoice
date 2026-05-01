class ApiConstants {
  static const String baseUrl = 'https://radio.backend.ecocloud.tn';
  
  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String refreshToken = '$baseUrl/auth/token/refresh';

  // Account Endpoints
  /// PUT /account/update/password/{accountId}/{accountId}/ — change password.
  static String changePassword(int accountId) =>
      '$baseUrl/account/update/password/$accountId/$accountId/';
}