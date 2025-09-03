// lib/features/auth/data/auth_service.dart
import 'dart:async';
import 'package:flutter_appauth/flutter_appauth.dart';
import '../../../core/config/env.dart';
import '../../../core/storage/token_storage.dart';

final flutterAppAuth = FlutterAppAuth();

class AuthService {
  final TokenStorage storage;
  AuthService(this.storage);

  // --- Evita llamar refresh simultáneo desde varias requests ---
  Future<String?>? _ongoingRefresh;
  final _refreshMutex = Object();

  Future<bool> signIn() async {
    final result = await flutterAppAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        Env.clientId,
        Env.redirectUrl,               // com.clinic.patient://oauthredirect
        issuer: Env.issuer,
        scopes: const ['openid','email','profile','offline_access'],
      ),
    );
    if (result == null) return false;

    await storage.save(
      access: result.accessToken,
      id: result.idToken,
      refresh: result.refreshToken,
      expiresAt: result.accessTokenExpirationDateTime,
    );
    return true;
  }

  /// Devuelve un access token válido. Si falta <60s para expirar, lo renueva.
  Future<String?> ensureValidAccessToken({bool? forceRefresh}) async {
    if (forceRefresh != true) {
      final token = await storage.access;
      if (token == null || token.isEmpty) return null;

      final exp = await storage.expiresAt;
      final now = DateTime.now().toUtc();

      if (exp != null && exp.isAfter(now.add(const Duration(seconds: 60)))) {
        return token; // aún es válido
      }
    }

    // Intenta refresh (una sola vez a la vez)
    return _refreshSafely();
  }


  Future<String?> _refreshSafely() async {
    // evita tormenta de refresh
    if (_ongoingRefresh != null) return _ongoingRefresh;

    // crea la tarea de refresh protegida
    final completer = Completer<String?>();
    _ongoingRefresh = completer.future;
    try {
      final newToken = await _refresh();
      completer.complete(newToken);
      return newToken;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _ongoingRefresh = null;
    }
  }

  Future<String?> _refresh() async {
    final rt = await storage.refresh;
    if (rt == null || rt.isEmpty) return await storage.access;

    final res = await flutterAppAuth.token(
      TokenRequest(
        Env.clientId,
        Env.redirectUrl,
        issuer: Env.issuer,
        refreshToken: rt,
        scopes: const ['openid','email','profile','offline_access'],
      ),
    );
    if (res == null) return await storage.access;

    // OJO: algunos IdP rotan el refresh; guarda el nuevo si vino
    await storage.save(
      access: res.accessToken,
      id: res.idToken ?? await storage.id,
      refresh: res.refreshToken ?? rt,
      expiresAt: res.accessTokenExpirationDateTime,
    );
    return res.accessToken;
  }

  Future<void> signOut() async {
    try {
      await flutterAppAuth.endSession(EndSessionRequest(
        idTokenHint: await storage.id,
        postLogoutRedirectUrl: Env.postLogoutRedirectUrl,
        issuer: Env.issuer,
      ));
    } catch (_) {}
    await storage.clear();
  }

  // getters existentes si los usas en otros lados
  Future<String?> get accessToken async => ensureValidAccessToken();
  Future<String?> get idToken async => storage.id;
}
