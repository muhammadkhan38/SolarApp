import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the Sanctum bearer token securely (Keychain on iOS,
/// EncryptedSharedPreferences on Android).
class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );
  static const _key = 'prince_driver_token';

  Future<void> save(String token) => _storage.write(key: _key, value: token);
  Future<String?> read() => _storage.read(key: _key);
  Future<void> clear() => _storage.delete(key: _key);
}
