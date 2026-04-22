import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureConfigRepository {
  final FlutterSecureStorage _storage;

  SecureConfigRepository([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<String?> getValueForKey(String key) => _storage.read(key: key);

  Future<void> setValueForKey(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> deleteValueForKey(String key) => _storage.delete(key: key);
}
