import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:tt_aveds/src/core/constant/application_config.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_data_source.dart';
import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final Client _client;

  AuthDataSourceImpl(Client client) : _client = client;

  String get baseUrl => const ApplicationConfig().baseUrl;

  @override
  Future<Token> confirmCode(
      {required String email, required String code}) async {
    final confirmCode = int.tryParse(code);
    if (confirmCode == null) {
      throw FormatException('Invalid code');
    }

    final response = await _client.post(Uri.parse('${baseUrl}confirm_code'),
        headers: {'Content-Type': 'application/json'}, // Важно!

        body: jsonEncode({
          'email': email,
          'code': code,
        }));

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    // Check if response is an error
    if (body case {'error': final String message}) {
      throw UnknownAuthenticationException(
        code: response.statusCode,
        error: message,
      );
    }

    // Check if response contains access_token and refresh_token
    if (body
        case {
          'jwt': final String accessToken,
          'refresh_token': final String refreshToken,
        }) {
      return Token(accessToken, refreshToken);
    }

    // If we can't understand the response, throw a format exception
    throw FormatException(
      'Returned response is not understood by the application',
      body,
    );
  }

  @override
  Future<void> login(String email) async {
    final response = await _client.post(
      Uri.parse('${baseUrl}login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      return;
    } else {
      throw UnknownAuthenticationException(
        code: response.statusCode,
        error: response.body,
      );
    }
  }

  @override
  Future<String> getUserId() async {
    final response = await _client.get(
      Uri.parse('${baseUrl}auth'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body['user_id'] as String;
    } else {
      throw UnknownAuthenticationException(
        code: response.statusCode,
        error: response.body,
      );
    }
  }
}

/// Exception thrown when the authentication fails
base class AuthenticationException implements Exception {
  /// Create a [AuthenticationException]
  const AuthenticationException();
}

/// Unknown authentication exception
final class UnknownAuthenticationException implements AuthenticationException {
  /// System error code, that is not understood
  final int? code;

  /// Error message
  final Object error;

  /// Create a [UnknownAuthenticationException]
  const UnknownAuthenticationException({
    required this.error,
    this.code,
  });
}
