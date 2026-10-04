import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);
  final ApiClient _client;

  Future<AuthResponseModel> signIn({
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      ApiEndpoints.signIn,
      data: {'email': email.trim(), 'password': password},
    );
    return AuthResponseModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
