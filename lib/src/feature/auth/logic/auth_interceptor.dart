import 'dart:async';

import 'package:http/http.dart';
import 'package:intercepted_client/intercepted_client.dart';
import 'package:tt_aveds/src/core/interceptor/authorization_client.dart';
import 'package:tt_aveds/src/core/interceptor/token_storage.dart';
import '/src/core/utils/retry_request_mixin.dart';

/// Token is a simple class that holds the access and refresh token
class Token {
  /// Create a [Token]
  const Token(this.accessToken, this.refreshToken);

  /// Access token (used to authenticate the user)
  final String accessToken;

  /// Refresh token (used to refresh the access token)
  final String refreshToken;
}

/// Status of the authentication
enum AuthenticationStatus {
  /// Authenticated
  authenticated,

  /// Unauthenticated
  unauthenticated,
}

/// AuthInterceptor is used to add the Auth token to the request header
/// and refreshes or clears the token if the request fails with a 401
class AuthInterceptor extends SequentialHttpInterceptor with RetryRequestMixin {
  /// Create an Auth interceptor
  AuthInterceptor({
    required this.tokenStorage,
    required this.authorizationClient,
    Client? retryClient,
    Token? token,
  })  : retryClient = retryClient ?? Client(),
        _token = token {
    tokenStorage.getStream().listen((newToken) => _token = newToken);
  }

  /// [Client] to retry the request
  final Client retryClient;

  /// [TokenStorage] to store and retrieve the token
  final TokenStorage<Token> tokenStorage;

  /// [AuthorizationClient] to refresh the token
  final AuthorizationClient<Token> authorizationClient;
  Token? _token;

  Future<Token?> _loadToken() async => _token;

  Map<String, String> _buildHeaders(Token token) => {
        'Auth': 'Bearer ${token.accessToken}',
      };

  String? _extractTokenFromHeaders(Map<String, String> headers) {
    final authHeader = headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    return authHeader.substring(7);
  }

  // 1.0
  @override
  Future<void> interceptRequest(
    BaseRequest request,
    RequestHandler handler,
  ) async {
    // 1.1
    var token = await _loadToken();

    // 1.2
    // If token is valid, then the request is made with the token
    if (token != null && await authorizationClient.isAccessTokenValid(token)) {
      final headers = _buildHeaders(token);
      request.headers.addAll(headers);

      return handler.next(request);
    }

    // 1.3
    // If token is not valid and can be refreshed, then the token is refreshed
    if (token != null && await authorizationClient.isRefreshTokenValid(token)) {
      try {
        // 1.4
        // Even if refresh token seems to be valid from the client side,
        // it may be revoked / banned / deleted on the server side, so
        // the following method can throw the error.
        token = await authorizationClient.refresh(token);
        await tokenStorage.save(token);

        final headers = _buildHeaders(token);
        request.headers.addAll(headers);

        return handler.next(request);
        // If authorization client decides that the token is no longer
        // valid, it throws [RevokeTokenException] and user should be logged out
      } on RevokeTokenException catch (e) {
        // 1.5
        // If token cannot be refreshed, then user should be logged out
        await tokenStorage.clear();
        return handler.rejectRequest(e);
        // However, if another error occurs, like internet connection error,
        // then we should not log out the user, but just reject the request
      } on Object catch (e) {
        // 1.6
        return handler.rejectRequest(e);
      }
    }

    return handler.next(request);
  }

  // 2.0
  @override
  Future<void> interceptResponse(
    StreamedResponse response,
    ResponseHandler handler,
  ) async {
    // 2.1
    // If response is 401 (Unauthorized), then Access token is expired
    // and, if possible, should be refreshed
    if (response.statusCode != 401) {
      return handler.resolveResponse(response);
    }

    // 2.2
    var token = await _loadToken();

    final tokenFromHeaders = _extractTokenFromHeaders(
      response.request?.headers ?? const {},
    );

    // If request does not have the token, then return the response
    if (tokenFromHeaders == null) {
      return handler.resolveResponse(response);
    }

    // 2.3
    // If token is the same, refresh the token
    if (token != null && tokenFromHeaders == token.accessToken) {
      // 2.4
      if (await authorizationClient.isRefreshTokenValid(token)) {
        try {
          // 2.5
          // Even if refresh token seems to be valid from the client side,
          // it may be revoked / banned / deleted on the server side, so
          // the following method can throw the error.
          token = await authorizationClient.refresh(token);
          await tokenStorage.save(token);

          final headers = _buildHeaders(token);
          response.request?.headers.addAll(headers);
          // If authorization client decides that the token is no longer
          // valid, it throws [RevokeTokenException] and user should be logged
          // out
        } on RevokeTokenException catch (e) {
          // 2.6
          // If token cannot be refreshed, then user should be logged out
          await tokenStorage.clear();
          return handler.rejectResponse(e);
          // However, if another error occurs, like internet connection error,
          // then we should not log out the user, but just reject the response
        } on Object catch (e) {
          // 2.7
          return handler.rejectResponse(e);
        }
      } else {
        // 2.8
        // If token cannot be refreshed, then user should be logged out
        await tokenStorage.clear();
        return handler.rejectResponse(
          const RevokeTokenException(
            'Token is not valid and cannot be refreshed',
          ),
        );
      }
    }

    // 2.9
    // If token is different, then the token is already refreshed
    // and the request should be made again
    final newResponse = await retryRequest(response, retryClient);

    return handler.resolveResponse(newResponse);
  }
}
