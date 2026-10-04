import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.readToken, required this.onUnauthorized});

  final Future<String?> Function() readToken;
  final Future<void> Function() onUnauthorized;

  bool _isSignIn(RequestOptions options) =>
      options.path.endsWith(ApiEndpoints.signIn);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isSignIn(options)) {
      final token = await readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isSignIn(err.requestOptions)) {
      await onUnauthorized();
    }
    handler.next(err);
  }
}
