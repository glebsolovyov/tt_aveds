import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tt_aveds/src/feature/auth/data/auth_repository.dart';
import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';

part 'auth_event.dart';
part 'auth_state.dart';

mixin SetStateMixin<S> on Emittable<S> {
  /// Change the state of the bloc
  void setState(S state) => emit(state);
}

final class AuthBloc extends Bloc<AuthEvent, AuthState> with SetStateMixin {
  final AuthRepository _authRepository;

  /// Create an [AuthBloc]
  ///
  /// This specializes required initialState as it should be preloaded.
  AuthBloc(
    super.initialState, {
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    on<AuthEvent>(
      (event, emit) => switch (event) {
        final _Login e => _login(e, emit),
        final _ConfirmCode e => _confirmCode(e, emit),
        final _GetUserId e => _getUserId(e, emit),
      },
    );

    // emit new state when the authentication status changes
    authRepository.authStatus
        .map(($status) => AuthState.idle(status: $status))
        .listen(($state) {
      if ($state != state) {
        setState($state);
      }
    });
  }

  Future<void> _login(
    _Login event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.processing(status: AuthenticationStatus.unauthenticated));

    try {
      await _authRepository.login(event.email);
      emit(AuthState.success(status: AuthenticationStatus.unauthenticated));
    } on Object catch (e) {
      event.onError(e.toString());
      emit(
        AuthState.error(status: AuthenticationStatus.unauthenticated, error: e),
      );
    }
  }

  Future<void> _confirmCode(
    _ConfirmCode event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.processing(status: state.status));
    try {
      await _authRepository.confirmCode(email: event.email, code: event.code);
      emit(AuthState.idle(status: AuthenticationStatus.authenticated));
    } on Object catch (e) {
      event.onError(e.toString());
      emit(AuthState.error(
          status: AuthenticationStatus.unauthenticated, error: e));
    }
  }

  Future<void> _getUserId(
    _GetUserId event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.processing(status: state.status));

    try {
      final userId = await _authRepository.getUserId();
      emit(AuthState.idle(status: state.status, userId: userId));
    } on Object catch (e) {
      emit(AuthState.error(status: state.status, error: e));
    }
  }
}
