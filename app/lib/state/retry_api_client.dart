import 'dart:async';

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

    final isAuthError = response.statusCode == _authErrorStatusCode;
    final isRefreshRequest = path.startsWith(_refreshUrl);
    if (isAuthError && !isRefreshRequest) {
      try {
        await _refresh();
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
      } catch (_) {
        return response;
      }
    }

    return response;
  }

  Future<void> _refresh() async {
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return;
    }

    _refreshCompleter = Completer<void>();
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) throw UnauthorizedException.refreshFailed;

      final result = await AppConfig.apiClient.refresh(
        RefreshRequest(refreshToken: refreshToken),
      );
      if (result == null) throw UnauthorizedException.refreshFailed;

      await saveTokens(
        access: result.accessToken,
        refresh: result.refreshToken,
      );
      AppConfig.bearerAuth.accessToken = result.accessToken;
      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
      _refreshCompleter = null;
      rethrow;
    }
    _refreshCompleter = null;
  }
}
