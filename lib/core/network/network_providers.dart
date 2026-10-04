import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/session_controller.dart';
import '../config/app_config.dart';
import '../providers/app_providers.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(
      readToken: ref.read(secureStorageProvider).readToken,
      onUnauthorized: ref
          .read(sessionControllerProvider.notifier)
          .expireSession,
    ),
  );
  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);
