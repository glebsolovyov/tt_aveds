import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tt_aveds/src/feature/auth/bloc/auth_bloc.dart';
import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';

import '../../../mocks.dart';

void main() {
  late AuthBloc bloc;
  late MockAuthRepository mockRepository;

  const email = 'user@example.com';
  const code = '123456';
  const userId = 'user-id-xyz';

  setUp(() {
    mockRepository = MockAuthRepository();
    when(() => mockRepository.authStatus)
        .thenAnswer((_) => const Stream.empty());
    bloc = AuthBloc(
      const AuthState.idle(status: AuthenticationStatus.unauthenticated),
      authRepository: mockRepository,
    );
  });

  group('AuthBloc', () {
    test('initial state is idle unauthenticated', () {
      expect(
        bloc.state,
        const AuthState.idle(status: AuthenticationStatus.unauthenticated),
      );
    });

    blocTest<AuthBloc, AuthState>(
      'emits [processing, success] on successful login',
      build: () {
        when(() => mockRepository.login(email))
            .thenAnswer((_) async => Future.value());
        return bloc;
      },
      act: (bloc) {
        bloc.add(AuthEvent.login(
          email: email,
          onError: (_) {},
        ));
      },
      expect: () => [
        const AuthState.processing(
            status: AuthenticationStatus.unauthenticated),
        const AuthState.success(status: AuthenticationStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [processing, error] on failed login',
      build: () {
        when(() => mockRepository.login(email))
            .thenThrow(Exception('Login failed'));
        return bloc;
      },
      act: (bloc) {
        bloc.add(AuthEvent.login(
          email: email,
          onError: (_) {},
        ));
      },
      expect: () => [
        const AuthState.processing(
            status: AuthenticationStatus.unauthenticated),
        isA<AuthState>()
            .having(
                (s) => s.status, 'status', AuthenticationStatus.unauthenticated)
            .having((s) => s.error, 'error', isA<Exception>()),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [processing, idle(authenticated)] on successful confirmCode',
      build: () {
        when(() => mockRepository.confirmCode(email: email, code: code))
            .thenAnswer((_) async => Token('access', 'refresh'));
        return bloc;
      },
      act: (bloc) {
        bloc.add(AuthEvent.confirmCode(
          email: email,
          code: code,
          onError: (_) {},
        ));
      },
      expect: () => [
        const AuthState.processing(
            status: AuthenticationStatus.unauthenticated),
        const AuthState.idle(status: AuthenticationStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [processing, error] on failed confirmCode',
      build: () {
        when(() => mockRepository.confirmCode(email: email, code: code))
            .thenThrow(Exception('Confirm failed'));
        return bloc;
      },
      act: (bloc) {
        bloc.add(AuthEvent.confirmCode(
          email: email,
          code: code,
          onError: (_) {},
        ));
      },
      expect: () => [
        isA<AuthState>()
            .having(
                (s) => s.status, 'status', AuthenticationStatus.unauthenticated)
            .having((s) => s, 'is processing', isA<AuthState>()),
        isA<AuthState>()
            .having(
                (s) => s.status, 'status', AuthenticationStatus.unauthenticated)
            .having((s) => s.error, 'error', isA<Exception>()),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [processing, idle with userId] on successful getUserId',
      build: () {
        when(() => mockRepository.getUserId()).thenAnswer((_) async => userId);
        return bloc;
      },
      seed: () =>
          const AuthState.idle(status: AuthenticationStatus.authenticated),
      act: (bloc) => bloc.add(AuthEvent.getUserId(onError: (_) {})),
      expect: () => [
        const AuthState.processing(status: AuthenticationStatus.authenticated),
        const AuthState.idle(
          status: AuthenticationStatus.authenticated,
          userId: userId,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [processing, error] on failed getUserId',
      build: () {
        when(() => mockRepository.getUserId())
            .thenThrow(Exception('Failed to get user id'));
        return bloc;
      },
      seed: () =>
          const AuthState.idle(status: AuthenticationStatus.authenticated),
      act: (bloc) => bloc.add(AuthEvent.getUserId(onError: (_) {})),
      expect: () => [
        const AuthState.processing(status: AuthenticationStatus.authenticated),
        isA<AuthState>()
            .having(
                (s) => s.status, 'status', AuthenticationStatus.authenticated)
            .having((s) => s.error, 'error', isA<Exception>()),
      ],
    );
  });
}
