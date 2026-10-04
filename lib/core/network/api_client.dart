import 'package:dio/dio.dart';

import '../errors/api_error.dart';

class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  Future<dynamic> get(String path) => _request(() => _dio.get<dynamic>(path));
  Future<dynamic> post(String path, {Object? data}) =>
      _request(() => _dio.post<dynamic>(path, data: data));
  Future<dynamic> put(String path, {Object? data}) =>
      _request(() => _dio.put<dynamic>(path, data: data));
  Future<void> delete(String path) async {
    await _request(() => _dio.delete<dynamic>(path));
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() action) async {
    try {
      return (await action()).data;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        throw ApiError.fromJson(data, statusCode: error.response?.statusCode);
      }
      if (data is Map) {
        throw ApiError.fromJson(
          Map<String, dynamic>.from(data),
          statusCode: error.response?.statusCode,
        );
      }
      throw ApiError(
        code: error.response?.statusCode == 403
            ? 'FORBIDDEN'
            : error.response?.statusCode == 401
            ? 'UNAUTHORIZED'
            : 'NETWORK_ERROR',
        message: error.message ?? 'Network error',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
