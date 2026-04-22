import 'package:shared_preferences/shared_preferences.dart';

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class ConfigRepository {
  Future<String?> getValueForKey(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> setValueForKey(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }
}
