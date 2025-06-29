import 'package:flutter/material.dart';

import 'package:tt_aveds/src/feature/auth/widget/auth_scope.dart';

/// {@template home_screen}
/// HomeScreen is a simple screen that displays user Id;
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthScope.of(context)
        ..getUserId((msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
            ),
          );
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _auth = AuthScope.of(context);
    return Scaffold(
      body: Center(
        child: _auth.userId != null
            ? Text(
                'User id: ${_auth.userId}',
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
