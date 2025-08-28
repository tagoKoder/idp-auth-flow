// lib/core/config/env.dart
class Env {
  // === OIDC (Authentik) ===
  static const issuer = 'http://localhost:9000/application/o/patient-app'; // sin slash final
  static const clientId = 'your_mobile_client_id';
  static const redirectUrl = 'com.clinic.patient:/oauthredirect';
  static const postLogoutRedirectUrl = 'com.clinic.patient:/signout';

  // === API Gateway ===
  static const apiBase = 'http://10.0.2.2:8085'; // Android emu; en iOS: http://localhost:8085
}
