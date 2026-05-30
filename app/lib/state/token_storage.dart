import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum UnauthorizedException {
  missingTokens(message: "Missing Tokens."),
  verifyFailed(message: "Verify Failed."),
  refreshFailed(message: "Refresh Failed."),
  loginFailed(message: "Login Failed.");

  final String? message;

  const UnauthorizedException({this.message});
}

const _secureStorage = FlutterSecureStorage();

const accessTokenKey = 'access_token';
const refreshTokenKey = 'refresh_token';

Future<bool> hasTokens() async {
  final (a, r) = await (
    _secureStorage.containsKey(key: accessTokenKey),
    _secureStorage.containsKey(key: refreshTokenKey),
  ).wait;
  return a && r;
}

Future<String?> getAccessToken() async {
  return await _secureStorage.read(key: accessTokenKey);
}

Future<String?> getRefreshToken() async {
  return await _secureStorage.read(key: refreshTokenKey);
}

Future<void> saveTokens({
  required String access,
  required String refresh,
}) async {
  await (
    _secureStorage.write(key: accessTokenKey, value: access),
    _secureStorage.write(key: refreshTokenKey, value: refresh),
  ).wait;
}

Future<void> deleteTokens() async {
  await (
    _secureStorage.delete(key: accessTokenKey),
    _secureStorage.delete(key: refreshTokenKey),
  ).wait;
}
