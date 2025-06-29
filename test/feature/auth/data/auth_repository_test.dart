import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_repository_impl.dart';
import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';

import '../../../mocks.dart';

void main() {
  late MockAuthDataSource mockDataSource;
  late MockTokenStorage mockTokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthDataSource();
    mockTokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(mockDataSource, mockTokenStorage);
  });

  group('confirmCode', () {
    const email = 'user@example.com';
    const code = '123456';
    final token = Token('accessToken123', 'refreshToken123');

    test('should call confirmCode on dataSource and save the token', () async {
      when(() => mockDataSource.confirmCode(email: email, code: code))
          .thenAnswer((_) async => token);
      when(() => mockTokenStorage.save(token)).thenAnswer((_) async {});

      final result = await repository.confirmCode(email: email, code: code);

      expect(result, token);
      verify(() => mockDataSource.confirmCode(email: email, code: code))
          .called(1);
      verify(() => mockTokenStorage.save(token)).called(1);
    });
  });

  group('login', () {
    const email = 'user@example.com';

    test('should call login on dataSource', () async {
      when(() => mockDataSource.login(email)).thenAnswer((_) async => null);

      await repository.login(email);

      verify(() => mockDataSource.login(email)).called(1);
    });
  });

  group('getUserId', () {
    test('should return userId from dataSource', () async {
      when(() => mockDataSource.getUserId()).thenAnswer((_) async => 'user123');

      final result = await repository.getUserId();

      expect(result, 'user123');
      verify(() => mockDataSource.getUserId()).called(1);
    });
  });

  group('authStatus', () {
    test('should emit authenticated when token is present', () async {
      final controller = StreamController<Token?>();

      when(() => mockTokenStorage.getStream())
          .thenAnswer((_) => controller.stream);

      expectLater(
        repository.authStatus,
        emitsInOrder([
          AuthenticationStatus.authenticated,
        ]),
      );

      controller.add(Token('token', 'refresh'));
      await controller.close();
    });

    test('should emit unauthenticated when token is null', () async {
      final controller = StreamController<Token?>();

      when(() => mockTokenStorage.getStream())
          .thenAnswer((_) => controller.stream);

      expectLater(
        repository.authStatus,
        emitsInOrder([
          AuthenticationStatus.unauthenticated,
        ]),
      );

      controller.add(null);
      await controller.close();
    });
  });
}
