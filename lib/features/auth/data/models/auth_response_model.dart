import '../../domain/entities/user.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.user, required this.token});
  final User user;
  final String token;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: User.fromJson(json),
      token: json['token']?.toString() ?? '',
    );
  }
}
