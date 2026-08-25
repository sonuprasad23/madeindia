import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for sensitive local data:
/// admin demo session tokens, identity-document references.
///
/// This is still a DEMO boundary — in production this would back onto
/// platform keystore-backed storage with server-issued short-lived tokens,
/// never long-lived secrets.
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();
}

class SecureStorageKeys {
  const SecureStorageKeys._();

  static const String adminAuthToken = 'admin_auth_token';
}
