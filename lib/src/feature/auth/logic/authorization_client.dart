import 'dart:async';
import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart';
import 'package:tt_aveds/src/core/constant/application_config.dart';
import 'package:tt_aveds/src/core/interceptor/authorization_client.dart';
import '/src/feature/auth/logic/auth_interceptor.dart';

/// Example client that can be used for JWT tokens
///
/// It is not used in this guide, but serves as an example.
final class JWTAuthorizationClient implements AuthorizationClient<Token> {
  /// {@macro authorization_client}
  const JWTAuthorizationClient(this._client);

  final Client _client;

  String get baseUrl => const ApplicationConfig().baseUrl;

  @override
  Future<bool> isRefreshTokenValid(Token token) async {
    final jwt = JWT.decode(token.refreshToken);

    // Check if JWT token is expired
    if (jwt.payload case {'exp': final int exp}) {
      return DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(exp),
      );
    }

    return false;
  }

  @override
  Future<bool> isAccessTokenValid(Token token) async {
    final jwt = JWT.decode(token.accessToken);

    // Check if JWT token is expired
    if (jwt.payload case {'exp': final int exp}) {
      return DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(exp),
      );
    }

    return false;
  }

  @override
  Future<Token> refresh(Token token) async {
    final response = await _client.post(
      Uri.parse('${baseUrl}refresh_token'),
      headers: {
        'Authorization': 'Bearer ${token.accessToken}',
      },
      body: {
        'refresh': token.refreshToken,
      },
    );

    final json = jsonDecode(response.body);

    if (json
        case {
          'access': final String aToken,
        }) {
      return Token(aToken, token.refreshToken);
    }

    throw const RevokeTokenException('Invalid token');
  }
}
