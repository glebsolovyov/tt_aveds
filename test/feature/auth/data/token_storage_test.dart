import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tt_aveds/src/core/utils/persisted_entry.dart';
import 'package:tt_aveds/src/feature/auth/data/token_storage_sp.dart';
import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';

import '../../../mocks.dart';

void main() {
  late MockStringPreferencesEntry mockAccessTokenEntry;
  late MockStringPreferencesEntry mockRefreshTokenEntry;

  late TokenStorageSP tokenStorage;

  setUp(() {
    mockAccessTokenEntry = MockStringPreferencesEntry();
    mockRefreshTokenEntry = MockStringPreferencesEntry();

    tokenStorage = TokenStorageSPWithMocks(
      accessTokenEntry: mockAccessTokenEntry,
      refreshTokenEntry: mockRefreshTokenEntry,
    );
  });

  group('TokenStorageSP', () {
    group('load', () {
      test('returns null if at least one token is null', () async {
        when(() => mockAccessTokenEntry.read()).thenAnswer((_) async => null);
        when(() => mockRefreshTokenEntry.read())
            .thenAnswer((_) async => 'refresh');

        final result = await tokenStorage.load();
        expect(result, isNull);

        when(() => mockAccessTokenEntry.read())
            .thenAnswer((_) async => 'access');
        when(() => mockRefreshTokenEntry.read()).thenAnswer((_) async => null);

        final result2 = await tokenStorage.load();
        expect(result2, isNull);
      });

      test('returns Token if both tokens are present', () async {
        when(() => mockAccessTokenEntry.read())
            .thenAnswer((_) async => 'accessToken');
        when(() => mockRefreshTokenEntry.read())
            .thenAnswer((_) async => 'refreshToken');

        final result = await tokenStorage.load();

        expect(result, isA<Token>());
        expect(result?.accessToken, 'accessToken');
        expect(result?.refreshToken, 'refreshToken');
      });
    });

    group('save', () {
      final token = Token('access', 'refresh');

      test('saves tokens and emits them in the stream', () async {
        when(() => mockAccessTokenEntry.set(token.accessToken))
            .thenAnswer((_) async => true);
        when(() => mockRefreshTokenEntry.set(token.refreshToken))
            .thenAnswer((_) async => true);

        final stream = tokenStorage.getStream();

        expectLater(
          stream,
          emits(token),
        );

        await tokenStorage.save(token);

        verify(() => mockAccessTokenEntry.set(token.accessToken)).called(1);
        verify(() => mockRefreshTokenEntry.set(token.refreshToken)).called(1);
      });
    });

    group('clear', () {
      test('removes tokens and emits null in the stream', () async {
        when(() => mockAccessTokenEntry.remove()).thenAnswer((_) async => true);
        when(() => mockRefreshTokenEntry.remove())
            .thenAnswer((_) async => true);

        final stream = tokenStorage.getStream();

        expectLater(stream, emits(null));

        await tokenStorage.clear();

        verify(() => mockAccessTokenEntry.remove()).called(1);
        verify(() => mockRefreshTokenEntry.remove()).called(1);
      });
    });

    group('getStream', () {
      test('returns a stream', () {
        expect(tokenStorage.getStream(), isA<Stream<Token?>>());
      });
    });

    group('close', () {
      test('close completes without errors', () async {
        await tokenStorage.close();
        expect(tokenStorage.close(), completes);
      });
    });
  });
}

class TokenStorageSPWithMocks extends TokenStorageSP {
  TokenStorageSPWithMocks({
    required StringPreferencesEntry accessTokenEntry,
    required StringPreferencesEntry refreshTokenEntry,
  }) : super(sharedPreferences: MockSharedPreferencesAsync()) {
    accessToken = accessTokenEntry;
    refreshToken = refreshTokenEntry;
  }
}
