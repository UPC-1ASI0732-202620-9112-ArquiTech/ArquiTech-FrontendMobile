import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesStorageService {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class SharedPreferencesStorageService implements PreferencesStorageService {
  SharedPreferencesStorageService(this._preferences);
  final SharedPreferences _preferences;

  @override
  String? getString(String key) => _preferences.getString(key);
  @override
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}
