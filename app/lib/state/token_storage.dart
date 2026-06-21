import 'package:flutter/foundation.dart';
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
  final a = await _secureStorage.containsKey(key: AppConfig.accessTokenKey);
  final r = await _secureStorage.containsKey(key: AppConfig.refreshTokenKey);
  debugPrint('[storage] hasTokens access=$a refresh=$r');
  return a && r;
}

Future<String?> getAccessToken() async {
  final val = await _secureStorage.read(key: AppConfig.accessTokenKey);
  debugPrint('[storage] getAccessToken=${val != null ? val.substring(0, val.length > 20 ? 20 : val.length) + "..." : "null"}');
  return val;
}

Future<String?> getRefreshToken() async {
  final val = await _secureStorage.read(key: AppConfig.refreshTokenKey);
  debugPrint('[storage] getRefreshToken=${val != null ? "present (length ${val.length})" : "null"}');
  return val;
}

Future<void> saveTokens({
  required String access,
  required String refresh,
}) async {
  debugPrint('[storage] saveTokens access.length=${access.length} refresh.length=${refresh.length}');
  await (
    _secureStorage.write(key: AppConfig.accessTokenKey, value: access),
    _secureStorage.write(key: AppConfig.refreshTokenKey, value: refresh),
  ).wait;
  debugPrint('[storage] saveTokens done');
}

Future<void> deleteTokens() async {
  debugPrint('[storage] deleteTokens');
  await (
    _secureStorage.delete(key: AppConfig.accessTokenKey),
    _secureStorage.delete(key: AppConfig.refreshTokenKey),
  ).wait;
  debugPrint('[storage] deleteTokens done');
}
