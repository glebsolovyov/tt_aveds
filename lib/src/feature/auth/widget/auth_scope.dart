import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/src/core/utils/extensions/context_extension.dart';
import '/src/feature/auth/bloc/auth_bloc.dart';
import '/src/feature/auth/logic/auth_interceptor.dart';
import '/src/feature/initialization/widget/dependencies_scope.dart';

/// Auth controller
abstract interface class AuthController {
  /// Authentication status
  AuthenticationStatus get status;

  /// User ID
  String? get userId;

  /// Error message
  String? get error;

  /// Login
  void login(
    final String email,
    final void Function(String) onError,
  );

  /// Confirm code
  void confirmCode({
    required final String email,
    required final String code,
    required final void Function(String) onError,
  });

  void getUserId(
    final void Function(String) onError,
  );
}

/// Scope that controls the authentication state
class AuthScope extends StatefulWidget {
  /// Create an [AuthScope]
  const AuthScope({required this.child, super.key});

  /// The child widget
  final Widget child;

  /// Get the [AuthController] from the [BuildContext]
  static AuthController of(BuildContext context, {bool listen = true}) =>
      context.inhOf<_AuthInherited>(listen: listen).controller;

  static AuthBloc blocOf(BuildContext context, {bool listen = true}) =>
      context.inhOf<_AuthInherited>(listen: listen).bloc;

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<AuthScope> implements AuthController {
  late final AuthBloc _authBloc;
  late AuthState _state;

  @override
  void initState() {
    super.initState();
    _authBloc = DependenciesScope.of(context).authBloc;
    _state = _authBloc.state;
  }

  @override
  AuthenticationStatus get status => _state.status;

  @override
  void login(
    final String email,
    final void Function(String) onError,
  ) {
    return _authBloc.add(AuthEvent.login(email: email, onError: onError));
  }

  @override
  void confirmCode({
    required final String email,
    required final String code,
    required final void Function(String) onError,
  }) {
    return _authBloc
        .add(AuthEvent.confirmCode(email: email, code: code, onError: onError));
  }

  @override
  void getUserId(void Function(String msg) onError) {
    return _authBloc.add(AuthEvent.getUserId(onError: onError));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        bloc: _authBloc,
        builder: (context, state) {
          _state = state;

          return _AuthInherited(
            controller: this,
            state: _authBloc.state,
            child: widget.child,
            bloc: _authBloc,
          );
        },
      );

  @override
  String? get error => _authBloc.state.error.toString();

  @override
  String? get userId => _state.userId;
}

final class _AuthInherited extends InheritedWidget {
  final AuthController controller;
  final AuthState state;
  final AuthBloc bloc;

  const _AuthInherited({
    required super.child,
    required this.controller,
    required this.state,
    required this.bloc,
  });

  @override
  bool updateShouldNotify(covariant _AuthInherited oldWidget) =>
      state != oldWidget.state;
}
