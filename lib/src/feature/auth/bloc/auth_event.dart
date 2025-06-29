part of 'auth_bloc.dart';

/// Events for [AuthBloc]
sealed class AuthEvent {
  const AuthEvent();

  /// Event to sign in with Email and Password
  const factory AuthEvent.login({
    required final String email,
    required final void Function(String) onError,
  }) = _Login;

  /// Event to sign out
  const factory AuthEvent.confirmCode({
    required final String email,
    required final String code,
    required final void Function(String) onError,
  }) = _ConfirmCode;

  const factory AuthEvent.getUserId({
    required final void Function(String) onError,
  }) = _GetUserId;
}

final class _Login extends AuthEvent {
  final String email;
  final void Function(String) onError;

  const _Login({
    required this.email,
    required this.onError,
  });
}

final class _ConfirmCode extends AuthEvent {
  final String email;
  final String code;
  final void Function(String) onError;

  const _ConfirmCode({
    required this.email,
    required this.code,
    required this.onError,
  });
}

final class _GetUserId extends AuthEvent {
  final void Function(String) onError;

  const _GetUserId({
    required this.onError,
  });
}
