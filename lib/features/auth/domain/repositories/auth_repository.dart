import '../entities/user.dart';

class AuthSession {
  const AuthSession({required this.user, required this.token});
  final User user;
  final String token;
}

abstract class AuthRepository {
  Future<AuthSession> signIn({required String email, required String password});
}
