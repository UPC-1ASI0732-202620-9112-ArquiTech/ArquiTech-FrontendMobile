import 'dart:convert';

import '../../../../core/storage/preferences_storage_service.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource(this.storage);
  final PreferencesStorageService storage;
  Map<String, dynamic>? read(String key) {
    try {
      final raw = storage.getString(key);
      return raw == null
          ? null
          : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String key, Map<String, dynamic> value) =>
      storage.setString(key, jsonEncode(value));
}
