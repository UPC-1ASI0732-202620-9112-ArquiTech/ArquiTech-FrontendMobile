abstract final class AppConfig {
  static const productionApiBaseUrl =
      'https://arquitech-backend-production.up.railway.app/api/v1';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: productionApiBaseUrl,
  );
  static Uri get apiUri => Uri.parse(apiBaseUrl);
}
