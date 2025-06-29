import 'package:flutter/material.dart';
import 'package:tt_aveds/src/core/router/routes.dart';

/// {@template material_context}
/// [MaterialContext] is an entry point to the material context.
///
/// This widget sets locales, themes and routing.
/// {@endtemplate}
class MaterialContext extends StatelessWidget {
  /// {@macro material_context}
  const MaterialContext({super.key});

  // This global key is needed for [MaterialApp]
  // to work properly when Widgets Inspector is enabled.
  static final _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    return MaterialApp.router(
      routerConfig: $router,
      builder: (context, child) => MediaQuery(
        key: _globalKey,
        data: mediaQueryData,
        child: child!,
      ),
    );
  }
}
