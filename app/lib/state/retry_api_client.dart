import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show Response;
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/token_storage.dart';

const _authErrorStatusCode = 401;
const _refreshUrl = '/auth/refresh';

class RetryApiClient extends ApiClient {
  RetryApiClient({super.basePath, super.authentication});

  Completer<void>? _refreshCompleter;

  @override
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType, {
    Future<void>? abortTrigger,
  }) async {
    debugPrint('[http] $method $path');
    final response = await super.invokeAPI(
      path,
      method,
      queryParams,
      body,
      headerParams,
      formParams,
      contentType,
      abortTrigger: abortTrigger,
    );
    debugPrint('[http] response $method $path -> ${response.statusCode}');

    final isAuthError = response.statusCode == _authErrorStatusCode;
    final isRefreshRequest = path.startsWith(_refreshUrl);
    if (isAuthError && !isRefreshRequest) {
      debugPrint('[http] 401 on $method $path, trying refresh...');
      try {
        await _refresh();
        debugPrint('[http] refresh succeeded, retrying $method $path');
        return await super.invokeAPI(
          path,
          method,
          queryParams,
          body,
          headerParams,
          formParams,
          contentType,
          abortTrigger: abortTrigger,
        );
      } catch (e) {
        debugPrint(
          '[http] refresh failed: $e, returning original 401 response',
        );
        return response;
      }
    }

    return response;
  }

  Future<void> _refresh() async {
    debugPrint('[http] _refresh start');
    if (_refreshCompleter != null) {
      debugPrint('[http] _refresh already in progress, waiting...');
      await _refreshCompleter!.future;
      return;
    }

    _refreshCompleter = Completer<void>();
    try {
      final refreshToken = await getRefreshToken();
      debugPrint('[http] _refresh got refreshToken=${refreshToken != null}');
      if (refreshToken == null) throw UnauthorizedException.refreshFailed;

      final result = await AppConfig.apiClient.refresh(
        RefreshRequest(refreshToken: refreshToken),
      );
      debugPrint('[http] _refresh result=${result != null}');
      if (result == null) throw UnauthorizedException.refreshFailed;

      await saveTokens(
        access: result.accessToken,
        refresh: result.refreshToken,
      );
      AppConfig.bearerAuth.accessToken = result.accessToken;
      debugPrint('[http] _refresh completed successfully');
      _refreshCompleter!.complete();
    } catch (e) {
      debugPrint('[http] _refresh error: $e');
      _refreshCompleter!.completeError(e);
      _refreshCompleter = null;
      rethrow;
    }
    _refreshCompleter = null;
  }
}
