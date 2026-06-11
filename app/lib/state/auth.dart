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
  if (!await hasTokens()) return null;

  AppConfig.bearerAuth.accessToken = await getAccessToken();

  try {
    return await AppConfig.apiClient.verify();
  } on ApiException {
    // Try refreshing tokens before giving up
    final refreshToken = await getRefreshToken();
    if (refreshToken != null) {
      try {
        final result = await AppConfig.apiClient.refresh(
          RefreshRequest(refreshToken: refreshToken),
        );
        if (result != null) {
          await saveTokens(
            access: result.accessToken,
            refresh: result.refreshToken,
          );
          AppConfig.bearerAuth.accessToken = result.accessToken;
          return await AppConfig.apiClient.verify();
        }
      } on ApiException {
        // Refresh also failed — proceed to logout
      }
    }
    await deleteTokens();
    authStatusNotifier.value = AuthStatus.unauthenticated;
    return null;
  }
}

Future<User> login(String email, String password) async {
  final result = await AppConfig.apiClient.login(
    LoginRequest(email: email, password: password),
  );
  if (result == null) throw UnauthorizedException.loginFailed;

  await saveTokens(access: result.accessToken, refresh: result.refreshToken);
  AppConfig.bearerAuth.accessToken = result.accessToken;
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


