import 'package:flutter/material.dart';

/// {@template app_button}
/// AppButton widget.
/// {@endtemplate}
class AppButton extends StatelessWidget {
  /// {@macro app_button}
  const AppButton({
    super.key,
    required this.opacity,
    this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  final double opacity;
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isLoading) {
      child = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    } else {
      child = Text(
        text,
        style: TextStyle(color: Colors.white),
      );
    }
    return Opacity(
      opacity: opacity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
