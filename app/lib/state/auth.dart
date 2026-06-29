import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/token_storage.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

final authStatusNotifier = ValueNotifier(AuthStatus.initial);

final authProvider = FutureProvider<User?>((ref) async {
  final user = await _fetchUser();
  authStatusNotifier.value =
      user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  return user;
});

Future<User?> _fetchUser() async {
  debugPrint('[auth] _fetchUser start');
  final has = await hasTokens();
  debugPrint('[auth] hasTokens=$has');
  if (!has) {
    debugPrint('[auth] no tokens, returning null');
    return null;
  }

  final token = await getAccessToken();
  debugPrint('[auth] accessToken=${token != null ? token.substring(0, token.length > 20 ? 20 : token.length) : "null"}...');
  AppConfig.bearerAuth.accessToken = token;

  try {
    debugPrint('[auth] calling verify...');
    final user = await AppConfig.apiClient.verify();
    debugPrint('[auth] verify succeeded: $user');
    return user;
  } on ApiException catch (e) {
    debugPrint('[auth] verify failed: ${e.code} ${e.message}');
    // Try refreshing tokens before giving up
    final refreshToken = await getRefreshToken();
    debugPrint('[auth] refreshToken=${refreshToken != null ? refreshToken.substring(0, refreshToken.length > 20 ? 20 : refreshToken.length) : "null"}...');
    if (refreshToken != null) {
      try {
        debugPrint('[auth] calling refresh...');
        final result = await AppConfig.apiClient.refresh(
          RefreshRequest(refreshToken: refreshToken),
        );
        debugPrint('[auth] refresh result=${result != null}');
        if (result != null) {
          await saveTokens(
            access: result.accessToken,
            refresh: result.refreshToken,
          );
          AppConfig.bearerAuth.accessToken = result.accessToken;
          debugPrint('[auth] calling verify after refresh...');
          return await AppConfig.apiClient.verify();
        }
      } on ApiException catch (e2) {
        debugPrint('[auth] refresh also failed: ${e2.code} ${e2.message}');
      }
    }
    debugPrint('[auth] deleting tokens and returning null');
    await deleteTokens();
    authStatusNotifier.value = AuthStatus.unauthenticated;
    return null;
  }
}

Future<User> login(String email, String password) async {
  debugPrint('[auth] login start email=$email');
  final result = await AppConfig.apiClient.login(
    LoginRequest(email: email, password: password),
  );
  if (result == null) throw UnauthorizedException.loginFailed;

  debugPrint('[auth] login succeeded, saving tokens');
  await saveTokens(access: result.accessToken, refresh: result.refreshToken);
  AppConfig.bearerAuth.accessToken = result.accessToken;
  debugPrint('[auth] tokens saved, setting authenticated');
  authStatusNotifier.value = AuthStatus.authenticated;

  return result.user;
}

Future<void> logout() async {
  try {
    await AppConfig.apiClient.logout();
  } on ApiException {
    // ignore server errors — still clear local state
  }
  await deleteTokens();
  AppConfig.bearerAuth.accessToken = '';
  authStatusNotifier.value = AuthStatus.unauthenticated;
}


