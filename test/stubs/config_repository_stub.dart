import 'package:flutter_app_base/repository/config_repository.dart';

class ConfigRepositoryStub implements ConfigRepository {
  final Map<String, String> _store = {};

  @override
  Future<String?> getValueForKey(String key) async {
    return _store[key];
  }

  @override
  Future<void> setValueForKey(String key, String value) async {
    _store[key] = value;
  }
}
