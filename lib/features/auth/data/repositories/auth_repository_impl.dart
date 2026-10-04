import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);
  final AuthRemoteDataSource _remote;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _remote.signIn(email: email, password: password);
    if (response.token.isEmpty) {
      throw const FormatException('Authentication response without token');
    }
    return AuthSession(user: response.user, token: response.token);
  }
}
