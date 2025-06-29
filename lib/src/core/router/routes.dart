import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tt_aveds/src/feature/auth/widget/confirm_code_screen.dart';
import 'package:tt_aveds/src/feature/auth/widget/login_screen.dart';
import 'package:tt_aveds/src/feature/home/widget/home_screen.dart';

import 'auth_guard.dart';
import 'redirect_builder.dart';

final _parentKey = GlobalKey<NavigatorState>();

/// Router of this application.
final $router = GoRouter(
  initialLocation: '/login',
  navigatorKey: _parentKey,
  redirect: RedirectBuilder({
    RedirectIfAuthenticatedGuard(),
    RedirectIfUnauthenticatedGuard(),
  }),
  routes: [
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: 'confirm_code',
      path: '/confirm_code',
      builder: (context, state) => ConfirmCodeScreen(
        email: state.uri.queryParameters['email'] as String,
      ),
    ),
    GoRoute(
      name: 'home',
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
