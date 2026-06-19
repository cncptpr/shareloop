import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shareloop/app_config.dart';

enum UnauthorizedException {
  missingTokens(message: "Missing Tokens."),
  verifyFailed(message: "Verify Failed."),
  refreshFailed(message: "Refresh Failed."),
  loginFailed(message: "Login Failed.");

  final String? message;

  const UnauthorizedException({this.message});
}

const _secureStorage = FlutterSecureStorage();

Future<bool> hasTokens() async {
  final (a, r) = await (
    _secureStorage.containsKey(key: AppConfig.accessTokenKey),
    _secureStorage.containsKey(key: AppConfig.refreshTokenKey),
  ).wait;
  return a && r;
}

Future<String?> getAccessToken() async {
  return await _secureStorage.read(key: AppConfig.accessTokenKey);
}

Future<String?> getRefreshToken() async {
  return await _secureStorage.read(key: AppConfig.refreshTokenKey);
}

Future<void> saveTokens({
  required String access,
  required String refresh,
}) async {
  await (
    _secureStorage.write(key: AppConfig.accessTokenKey, value: access),
    _secureStorage.write(key: AppConfig.refreshTokenKey, value: refresh),
  ).wait;
}

Future<void> deleteTokens() async {
  await (
    _secureStorage.delete(key: AppConfig.accessTokenKey),
    _secureStorage.delete(key: AppConfig.refreshTokenKey),
  ).wait;
}
