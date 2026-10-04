import 'dart:convert';

import 'package:arquitech/core/storage/preferences_storage_service.dart';
import 'package:arquitech/core/storage/secure_storage_service.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:arquitech/features/auth/presentation/controllers/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/jwt_utils_test.dart' show tokenWithExpiry;

class FakeSecureStorage implements SecureStorageService {
  String? token;
  @override
  Future<void> clearToken() async => token = null;
  @override
  Future<String?> readToken() async => token;
  @override
  Future<void> writeToken(String value) async => token = value;
}

class FakePreferences implements PreferencesStorageService {
  final values = <String, String>{};
  @override
  String? getString(String key) => values[key];
  @override
  Future<void> remove(String key) async => values.remove(key);
  @override
  Future<void> setString(String key, String value) async => values[key] = value;
}

void main() {
  const user = User(
    id: 1,
    fullName: 'Supervisor',
    email: 'supervisor@arquitech.pe',
    role: UserRole.supervisor,
  );

  test('restores a persisted valid session', () async {
    final secure = FakeSecureStorage()
      ..token = tokenWithExpiry(
        DateTime.utc(2030).millisecondsSinceEpoch ~/ 1000,
      );
    final preferences = FakePreferences()
      ..values['arquitech.session.user'] = jsonEncode(user.toJson());
    final controller = SessionController(secure, preferences);

    await controller.restore();

    expect(controller.state.status, SessionStatus.authenticated);
    expect(controller.state.user?.id, 1);
  });

  test('clears an expired session', () async {
    final secure = FakeSecureStorage()
      ..token = tokenWithExpiry(
        DateTime.utc(2020).millisecondsSinceEpoch ~/ 1000,
      );
    final preferences = FakePreferences()
      ..values['arquitech.session.user'] = jsonEncode(user.toJson());
    final controller = SessionController(secure, preferences);

    await controller.restore();

    expect(controller.state.isAuthenticated, isFalse);
    expect(controller.state.expired, isTrue);
    expect(secure.token, isNull);
  });
}
