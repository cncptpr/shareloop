import 'package:openapi/api.dart';
import 'package:shareloop/state/retry_api_client.dart';
import 'package:uuid/uuid.dart';

class AppConfig {
  /// The Url under which the app can reach the server.
  /// Configure this my setting `API_BASE_URL` via the `--dart-define` flag
  /// for any build command.
  /// Example:
  /// `$ flutter run --dart-define=API_BASE_URL=http://production.example.com/api`
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:4000/api',
  );

  static final HttpBearerAuth bearerAuth = HttpBearerAuth();

  static final DefaultApi apiClient = DefaultApi(
    RetryApiClient(basePath: apiBaseUrl, authentication: bearerAuth),
  );

  static String imageUrl(UuidValue uuid) => '$apiBaseUrl/images/$uuid';
}
