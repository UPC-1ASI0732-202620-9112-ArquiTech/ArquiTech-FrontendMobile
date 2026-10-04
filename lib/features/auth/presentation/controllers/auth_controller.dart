import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'session_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDataSource(ref.watch(apiClientProvider)));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository, this._session)
    : super(const AsyncValue.data(null));

  final AuthRepository _repository;
  final SessionController _session;

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.signIn(email: email, password: password);
      await _session.start(user: result.user, token: result.token);
      state = const AsyncValue.data(null);
      return true;
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AsyncValue<void>>((ref) {
      return AuthController(
        ref.watch(authRepositoryProvider),
        ref.read(sessionControllerProvider.notifier),
      );
    });
