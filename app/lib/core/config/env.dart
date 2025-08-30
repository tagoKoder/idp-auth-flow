// lib/core/config/env.dart
class Env {
  // === OIDC (Authentik) ===
  static const issuer = 'https://idp.santiago-tumbaco.lat/application/o/patient-app'; // sin slash final
  static const clientId = 'BN400QZ9jBBmz29phwHNUhknhGG8Mo8AbHJkOwsh';
  static const redirectUrl = 'com.clinic.patient://oauthredirect';
  static const postLogoutRedirectUrl = 'com.clinic.patient://signout';

  // === API Gateway ===
  static const apiBase = 'http://192.168.1.69:8085'; // Android emu; en iOS: http://localhost:8085
}
