import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';

const secureStorage = FlutterSecureStorage();

final userProvider = FutureProvider<User?>((ref) async {
  final login = await AppConfig.apiClient
      .login(LoginRequest(email: "dev@example.com", password: "dev"));
  return login?.user;
});

Future<User> _fetchUser() {
  if (_hasTokens()) {
    final user = await AppConfig.apiClient.verify()
  }
}

const accessTokenKey = 'access_token';
const refreshTokenKey = 'refresh_token';

Future<void> _saveTokens({
  required String access,
  required String refresh,
}) async {
  await (
    secureStorage.write(key: accessTokenKey, value: access),
    secureStorage.write(key: refreshTokenKey, value: refresh),
  ).wait;
}

Future<bool> _hasTokens() async {
  final (a, r) = await (
    secureStorage.containsKey(key: accessTokenKey),
    secureStorage.containsKey(key: refreshTokenKey)
  ).wait;

  return a && r;
}

Future<String?> _getToken() async {
  return await secureStorage.read(key: accessTokenKey);
}

Future<String?> _getRefreshToken() async {
  return await secureStorage.read(key: refreshTokenKey);
}
