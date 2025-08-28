import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _sec = const FlutterSecureStorage();
  static const _kAccess = 'access_token';
  static const _kId = 'id_token';
  static const _kRefresh = 'refresh_token';

  Future<void> save({String? access, String? id, String? refresh}) async {
    if (access != null) await _sec.write(key: _kAccess, value: access);
    if (id != null) await _sec.write(key: _kId, value: id);
    if (refresh != null) await _sec.write(key: _kRefresh, value: refresh);
  }

  Future<String?> get access async => _sec.read(key: _kAccess);
  Future<String?> get id async => _sec.read(key: _kId);
  Future<String?> get refresh async => _sec.read(key: _kRefresh);

  Future<void> clear() async => _sec.deleteAll();
}
