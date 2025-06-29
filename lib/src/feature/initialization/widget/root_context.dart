import 'package:flutter/material.dart';
import 'package:tt_aveds/src/core/utils/layout/window_size.dart';
import 'package:tt_aveds/src/feature/auth/widget/auth_scope.dart';
import 'package:tt_aveds/src/feature/initialization/logic/composition_root.dart';
import 'package:tt_aveds/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tt_aveds/src/feature/initialization/widget/material_context.dart';

/// {@template app}
/// [RootContext] is an entry point to the application.
///
/// If a scope doesn't depend on any inherited widget returned by
/// [MaterialApp] or [WidgetsApp], like [Directionality] or [Theme],
/// and it should be available in the whole application, it can be
/// placed here.
/// {@endtemplate}
class RootContext extends StatelessWidget {
  /// {@macro app}
  const RootContext({required this.compositionResult, super.key});

  /// The result from the [CompositionRoot], required to launch the application.
  final CompositionResult compositionResult;

  @override
  Widget build(BuildContext context) => DependenciesScope(
        dependencies: compositionResult.dependencies,
        child: WindowSizeScope(
          child: AuthScope(child: MaterialContext()),
        ),
      );
}
