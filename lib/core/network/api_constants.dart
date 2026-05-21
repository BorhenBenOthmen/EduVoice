class ApiConstants {
  static const String baseUrl = 'https://radio.backend.ecocloud.tn';

  // ── AI Voice Assistant (Basira) ─────────────────────────────────────────────
  /// Production: secure WebSocket through Traefik + Let's Encrypt TLS.
  static const String aiWsUrl = 'wss://basira.ecocloud.tn/ws';

  /// Development: plain WebSocket to Android-emulator host (10.0.2.2 maps to
  /// the host machine's localhost). Change to 'ws://127.0.0.1:8000/ws' when
  /// testing on a physical device connected to the same Wi-Fi as the dev PC.
  static const String aiWsUrlDev = 'ws://10.0.2.2:8000/ws';
  // ────────────────────────────────────────────────────────────────────────────

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String refreshToken = '$baseUrl/auth/token/refresh';

  // Account Endpoints
  /// PUT /account/update/password/{accountId}/{accountId}/ — change password.
  static String changePassword(int accountId) =>
      '$baseUrl/account/update/password/$accountId/$accountId/';
}