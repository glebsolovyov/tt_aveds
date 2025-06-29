import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_data_source_impl.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late AuthDataSourceImpl dataSource;

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = AuthDataSourceImpl(mockClient);

    // Required for mocktail
    registerFallbackValue(Uri());
    registerFallbackValue(<String, String>{});
  });

  group('login', () {
    test('successful login (200)', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 200));

      await expectLater(dataSource.login('test@example.com'), completes);
    });

    test('login error (400)', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Bad Request', 400));

      expect(
        () => dataSource.login('test@example.com'),
        throwsA(isA<UnknownAuthenticationException>()),
      );
    });
  });

  group('confirmCode', () {
    const email = 'user@example.com';

    test('invalid code throws FormatException', () async {
      expect(
        () => dataSource.confirmCode(email: email, code: 'abc'),
        throwsA(isA<FormatException>()),
      );
    });

    test('success: returns Token', () async {
      final responseJson = jsonEncode({
        'jwt': 'access_token_value',
        'refresh_token': 'refresh_token_value',
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseJson, 200));

      final result = await dataSource.confirmCode(email: email, code: '123456');

      expect(result.accessToken, 'access_token_value');
      expect(result.refreshToken, 'refresh_token_value');
    });

    test('error response with {"error": "..."}', () async {
      final responseJson = jsonEncode({'error': 'Invalid code'});

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseJson, 400));

      expect(
        () => dataSource.confirmCode(email: email, code: '123456'),
        throwsA(isA<UnknownAuthenticationException>()),
      );
    });

    test('unexpected response throws FormatException', () async {
      final responseJson = jsonEncode({'unexpected': 'data'});

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseJson, 200));

      expect(
        () => dataSource.confirmCode(email: email, code: '123456'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('getUserId', () {
    test('successfully returns user_id', () async {
      final responseJson = jsonEncode({'user_id': 'abc123'});

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseJson, 200));

      final userId = await dataSource.getUserId();
      expect(userId, 'abc123');
    });

    test('error: returns UnknownAuthenticationException', () async {
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        () => dataSource.getUserId(),
        throwsA(isA<UnknownAuthenticationException>()),
      );
    });
  });
}
