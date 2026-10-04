import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageService {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();
}

class FlutterSecureStorageService implements SecureStorageService {
  FlutterSecureStorageService(this._storage);
  static const _tokenKey = 'arquitech.jwt';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
