import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tt_aveds/src/core/theme/app_colors.dart';
import 'package:tt_aveds/src/core/utils/widget/app_button.dart';
import 'package:tt_aveds/src/feature/auth/bloc/auth_bloc.dart';
import 'package:tt_aveds/src/feature/auth/widget/auth_scope.dart';

/// {@template login_screen}
/// LoginScreen widget.
/// {@endtemplate}
class LoginScreen extends StatefulWidget {
  /// {@macro login_screen}
  const LoginScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  void _validateAndLogin(AuthController auth) {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isValid = isValid;
    });

    if (isValid) {
      auth.login(
          _emailController.text,
          (msg) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка: неверный код'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              ));
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: AuthScope.blocOf(context),
      listener: (context, state) {
        if (state.isSuccess) {
          context.goNamed(
            'confirm_code',
            queryParameters: {'email': _emailController.text},
          );
        }
      },
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome back, Rohit thakur',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Image.asset('assets/images/auth.png'),
                  const SizedBox(height: 24),
                  const Text(
                    'Enter your email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Enter email',
                      errorText: _isValid
                          ? null
                          : _validateEmail(_emailController.text),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) {
                      if (!_isValid) {
                        setState(() {
                          _isValid = true;
                        });
                      }
                    },
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 24, left: 24, right: 24),
          child: AppButton(
            opacity: _isValid ? 1 : 0.4,
            text: 'Login',
            isLoading: state.isProcessing,
            onPressed:
                state.isProcessing ? null : () => _validateAndLogin(auth),
          ),
        ),
      ),
    );
  }
}
