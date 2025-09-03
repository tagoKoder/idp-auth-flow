// lib/core/config/env.dart
class Env {
  // === OIDC (Authentik) ===
  static const issuer = 'https://idp.santiago-tumbaco.lat/application/o/patient-app'; // sin slash final
  static const clientId = 'BN400QZ9jBBmz29phwHNUhknhGG8Mo8AbHJkOwsh';
  static const redirectUrl = 'com.clinic.patient://oauthredirect';
  static const postLogoutRedirectUrl = 'com.clinic.patient://signout';
  static const enrollmentRedirectUrl = 'https://idp.santiago-tumbaco.lat/if/flow/clinic-patient-enrollment/';

  // === API Gateway ===
  //static const apiBase = 'http://10.0.2.2:8085'; // for emulator
  static const apiBase = 'http://192.168.1.12:8085'; // for my cellphone
}
