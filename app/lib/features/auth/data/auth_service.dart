import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/env.dart';
import '../../../core/storage/token_storage.dart';

final flutterAppAuth = FlutterAppAuth();

class AuthService {
  final TokenStorage storage;
  AuthService(this.storage);

  Future<bool> signIn() async {
    final discoveryUrl = '${Env.issuer}/.well-known/openid-configuration';

    final result = await flutterAppAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        Env.clientId,
        Env.redirectUrl,
        discoveryUrl: discoveryUrl,
        promptValues: ['login'],
        scopes: ['openid', 'email', 'profile', 'offline_access'],
        // NOTE: se usa PKCE por defecto
      ),
    );

    if (result == null) return false;

    await storage.save(
      access: result.accessToken,
      id: result.idToken,
      refresh: result.refreshToken,
    );
    return true;
  }

  Future<void> signOut() async {
    try {
      final discoveryUrl = '${Env.issuer}/.well-known/openid-configuration';
      await flutterAppAuth.endSession(EndSessionRequest(
        idTokenHint: await storage.id,
        postLogoutRedirectUrl: Env.postLogoutRedirectUrl,
        discoveryUrl: discoveryUrl,
      ));
    } catch (_) {}
    await storage.clear();
  }

  Future<String?> get accessToken async => storage.access;
  Future<String?> get idToken async => storage.id;
}
