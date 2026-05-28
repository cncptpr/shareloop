import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/token_storage.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

final authStatusNotifier = ValueNotifier(AuthStatus.initial);

final authProvider = FutureProvider<User?>((ref) async {
  ref.onDispose(() => _refreshCompleter = null);
  final user = await _fetchUser();
  authStatusNotifier.value =
      user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  return user;
});

Completer<void>? _refreshCompleter;

/// If an API call fails with 401, automatically refresh the token and retry.
/// Any API call that requires Authentication should be wrapped in this.
/// ```dart
/// final items = await withRetryOnAuthError(
///   () => AppConfig.apiClient.getFeaturedItems(latLng: location),
/// );
///
/// ```
Future<T> withRetryOnAuthError<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on ApiException catch (e) {
    if (e.code != 401) rethrow;
  }

  await _doRefresh();
  return await fn();
}

Future<void> _doRefresh() async {
  if (_refreshCompleter != null) {
    await _refreshCompleter!.future;
    return;
  }

  _refreshCompleter = Completer<void>();
  try {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw UnauthorizedException.refreshFailed;
    }

    final result = await AppConfig.apiClient.refresh(
      RefreshRequest(refreshToken: refreshToken),
    );
    if (result == null) {
      throw UnauthorizedException.refreshFailed;
    }

    await saveTokens(access: result.accessToken, refresh: result.refreshToken);
    AppConfig.bearerAuth.accessToken = result.accessToken;
    _refreshCompleter!.complete();
  } catch (e) {
    _refreshCompleter!.completeError(e);
    _refreshCompleter = null;
    rethrow;
  }
  _refreshCompleter = null;
}

Future<User?> _fetchUser() async {
  if (!await hasTokens()) return null;

  AppConfig.bearerAuth.accessToken = await getAccessToken();

  try {
    return await withRetryOnAuthError(() => AppConfig.apiClient.verify());
  } on ApiException {
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

enum UnauthorizedException {
  missingTokens(message: "Missing Tokens."),
  verifyFailed(message: "Verify Failed."),
  refreshFailed(message: "Refresh Failed."),
  loginFailed(message: "Login Failed.");

  final String? message;

  const UnauthorizedException({this.message});
}
