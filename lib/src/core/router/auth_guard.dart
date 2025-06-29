import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '/src/core/router/redirect_builder.dart';
import '/src/feature/auth/logic/auth_interceptor.dart';
import '/src/feature/auth/widget/auth_scope.dart';

/// Guard that navigates user from unauthorized routes to dashboard
/// if the user is authenticated.
final class RedirectIfAuthenticatedGuard extends Guard {
  // matches login and signup routes
  @override
  Pattern get matchPattern => RegExp(r'^/(login)$');

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final auth = AuthScope.of(context);

    if (auth.status == AuthenticationStatus.authenticated) {
      return '/home';
    }

    return null;
  }
}

/// Guard that navigates user from authorized routes to login
/// when their authentication status is unauthenticated.
final class RedirectIfUnauthenticatedGuard extends Guard {
  // matches dashboard and settings routes
  @override
  Pattern get matchPattern => RegExp(r'^/(login)$');

  @override
  bool get invertRedirect => true;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final auth = AuthScope.of(context);
    final authState = AuthScope.blocOf(context).state;

    if (auth.status == AuthenticationStatus.unauthenticated &&
        authState.isIdle) {
      return '/login';
    }

    return null;
  }
}
