import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/storage/preferences_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/jwt_utils.dart';
import '../../domain/entities/user.dart';

enum SessionStatus { restoring, authenticated, unauthenticated }

class SessionState {
  const SessionState({required this.status, this.user, this.expired = false});
  const SessionState.restoring() : this(status: SessionStatus.restoring);
  const SessionState.unauthenticated({bool expired = false})
    : this(status: SessionStatus.unauthenticated, expired: expired);
  const SessionState.authenticated(User user)
    : this(status: SessionStatus.authenticated, user: user);

  final SessionStatus status;
  final User? user;
  final bool expired;
  bool get isAuthenticated => status == SessionStatus.authenticated;
}

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._secureStorage, this._preferences)
    : super(const SessionState.restoring());

  static const _userKey = 'arquitech.session.user';
  final SecureStorageService _secureStorage;
  final PreferencesStorageService _preferences;

  Future<void> restore() async {
    final token = await _secureStorage.readToken();
    final rawUser = _preferences.getString(_userKey);
    if (token == null || rawUser == null || JwtUtils.isExpired(token)) {
      await _clearPersisted();
      state = SessionState.unauthenticated(expired: token != null);
      return;
    }
    try {
      state = SessionState.authenticated(
        User.fromJson(jsonDecode(rawUser) as Map<String, dynamic>),
      );
    } on Object {
      await _clearPersisted();
      state = const SessionState.unauthenticated();
    }
  }

  Future<void> start({required User user, required String token}) async {
    await _secureStorage.writeToken(token);
    await _preferences.setString(_userKey, jsonEncode(user.toJson()));
    state = SessionState.authenticated(user);
  }

  Future<void> logout() async {
    await _clearPersisted();
    state = const SessionState.unauthenticated();
  }

  Future<void> expireSession() async {
    await _clearPersisted();
    state = const SessionState.unauthenticated(expired: true);
  }

  Future<void> _clearPersisted() async {
    await _secureStorage.clearToken();
    await _preferences.remove(_userKey);
    await _preferences.remove('arquitech.current-project');
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
      final controller = SessionController(
        ref.watch(secureStorageProvider),
        ref.watch(preferencesStorageProvider),
      );
      Future.microtask(controller.restore);
      return controller;
    });
