import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';

const secureStorage = FlutterSecureStorage();

final userProvider = FutureProvider<User?>((ref) async {
  return await _fetchUser();
});

enum UnauthorizedExeption {
  missingTokens(message: "Missing Tokens."),
  verifyFailed(message: "Verify Failed."),
  refreshFailed(message: "Refresh Failed."),
  loginFailed(message: "Login Failed.");

  final String? message;

  const UnauthorizedExeption({this.message});
}

Future<User> _fetchUser() async {
  if (await _hasTokens()) {
    // == Verify with tokens
    AppConfig.bearerAuth.accessToken = await _getToken();
    try {
      final user = await AppConfig.apiClient.verify();
      // user is null when response body is empty, which should never happen according to api contract
      if (user == null) throw UnauthorizedExeption.verifyFailed;
      return user;
    } catch (error) {
      print("Failed to verify: $error");
      if (error is! ApiException) rethrow;
    }

    // == Verify failed, try refresh
    final refreshToken = await _getRefreshToken();
    try {
      final refreshRespone = await AppConfig.apiClient.refresh(
        RefreshRequest(refreshToken: refreshToken!),
      );
      // refreshRespone is null when response body is empty, which should never happen according to api contract
      if (refreshRespone == null) throw UnauthorizedExeption.refreshFailed;
      unawaited(_saveTokens(
        access: refreshRespone.accessToken,
        refresh: refreshRespone.refreshToken,
      ));
      return refreshRespone.user;
    } catch (error) {
      print("Failed to refresh: $error");
      if (error is! ApiException) rethrow;
    }
  }

  // == Refresh Failed, login again
  final loginResult = await AppConfig.apiClient.login(LoginRequest(
    email: "dev@example.com",
    password: "dev",
  ));

  // loginResult is null when response body is empty, which should never happen according to api contract
  if (loginResult == null) throw UnauthorizedExeption.loginFailed;
  unawaited(_saveTokens(
    access: loginResult.accessToken,
    refresh: loginResult.refreshToken,
  ));
  return loginResult.user;
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

Future<void> _deleteTokens() async {
  await (
    secureStorage.delete(key: accessTokenKey),
    secureStorage.delete(key: refreshTokenKey)
  ).wait;
}
