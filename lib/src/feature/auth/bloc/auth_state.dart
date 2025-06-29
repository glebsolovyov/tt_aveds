part of 'auth_bloc.dart';

/// States for [AuthBloc]
sealed class AuthState {
  const AuthState({required this.status, this.userId});

  /// Status of the authentication
  final AuthenticationStatus status;

  final String? userId;

  /// Idle state, state machine is doing nothing
  const factory AuthState.idle({
    required AuthenticationStatus status,
    String userId,
  }) = _AuthStateIdle;

  const factory AuthState.processing({
    required AuthenticationStatus status,
    String userId,
  }) = _AuthStateProcessing;

  const factory AuthState.success({
    required AuthenticationStatus status,
    String userId,
  }) = _AuthStateSuccess;

  const factory AuthState.error({
    required AuthenticationStatus status,
    String userId,
    required Object error,
  }) = _AuthStateError;

  /// Get error if state is error
  Object? get error => switch (this) {
        final _AuthStateError e => e.error,
        _ => null,
      };

  bool get isSuccess => this is _AuthStateSuccess;
  bool get isIdle => this is _AuthStateIdle;
  bool get isProcessing => this is _AuthStateProcessing;
}

final class _AuthStateIdle extends AuthState {
  const _AuthStateIdle({required super.status, super.userId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _AuthStateIdle && other.status == status;
  }

  @override
  int get hashCode => Object.hashAll([status]);

  @override
  String toString() => '_AuthStateIdle(status: $status)';
}

final class _AuthStateProcessing extends AuthState {
  const _AuthStateProcessing({required super.status, super.userId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _AuthStateProcessing && other.status == status;
  }

  @override
  int get hashCode => Object.hashAll([status]);

  @override
  String toString() => '_AuthStateProcessing(status: $status)';
}

final class _AuthStateSuccess extends AuthState {
  const _AuthStateSuccess({required super.status, super.userId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _AuthStateSuccess && other.status == status;
  }

  @override
  int get hashCode => Object.hashAll([status]);

  @override
  String toString() => '_AuthStateSuccess(status: $status)';
}

final class _AuthStateError extends AuthState {
  @override
  final Object error;

  const _AuthStateError(
      {required this.error, required super.status, super.userId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _AuthStateError &&
        other.status == status &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hashAll([status, error]);

  @override
  String toString() => '_AuthStateError(status: $status, message: $error)';
}
