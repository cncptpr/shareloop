import 'package:openapi/api.dart';
import 'package:shareloop/state/retry_api_client.dart';

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

  /// Namespace for all persistent storage keys.
  /// Set via `--dart-define=STORAGE_NAMESPACE=dev2_` to run a second instance
  /// with isolated auth tokens and preferences.
  static const storageNamespace = String.fromEnvironment(
    'STORAGE_NAMESPACE',
    defaultValue: '',
  );

  static const accessTokenKey = '${storageNamespace}access_token';
  static const refreshTokenKey = '${storageNamespace}refresh_token';
  static const selectedLocationKey = '${storageNamespace}selected_location';
  static const storedLocationsKey = '${storageNamespace}stored_locations';

  static final HttpBearerAuth bearerAuth = HttpBearerAuth();

  static final DefaultApi apiClient = DefaultApi(
    RetryApiClient(basePath: apiBaseUrl, authentication: bearerAuth),
  );

  static String imageUrl(String uuid) => '$apiBaseUrl/images/$uuid';
}
