import 'package:tacit_mobile/repository/config_repository.dart';

/// Stores sensitive config values.
///
/// For this personal-use local-network app, we use SharedPreferences
/// (same as ConfigRepository). The API key is stored in the app sandbox
/// which is sufficient for a single-user device on a home network.
///
/// If the threat model changes (multi-user, public network), replace
/// this with flutter_secure_storage (Keychain/Keystore).
class SecureConfigRepository {
  final ConfigRepository _repository;

  SecureConfigRepository([ConfigRepository? repository])
      : _repository = repository ?? ConfigRepository();

  Future<String?> getValueForKey(String key) =>
      _repository.getValueForKey(key);

  Future<void> setValueForKey(String key, String value) =>
      _repository.setValueForKey(key, value);

  Future<void> deleteValueForKey(String key) =>
      _repository.setValueForKey(key, '');
}
