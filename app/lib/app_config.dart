import 'package:openapi/api.dart';

class AppConfig {
  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:4000/api',
  );

  static final DefaultApi apiClient = DefaultApi(
    ApiClient(basePath: _apiBaseUrl),
  );
}
