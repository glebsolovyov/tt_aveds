import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tt_aveds/src/core/theme/app_colors.dart';
import 'package:tt_aveds/src/core/utils/widget/app_button.dart';
import 'package:tt_aveds/src/feature/auth/bloc/auth_bloc.dart';
import 'package:tt_aveds/src/feature/auth/logic/auth_interceptor.dart';
import 'package:tt_aveds/src/feature/auth/widget/auth_scope.dart';

class ConfirmCodeScreen extends StatefulWidget {
  const ConfirmCodeScreen({super.key, required this.email});

  final String email;

  @override
  State<ConfirmCodeScreen> createState() => ConfirmCodeScreenState();
}

class ConfirmCodeScreenState extends State<ConfirmCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isFilled = false;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_onOtpChanged);
    }
  }

  void _onOtpChanged() {
    final isFilled = _controllers.every((c) => c.text.trim().isNotEmpty);
    setState(() {
      _isFilled = isFilled;
    });
  }

  void _onOtpSubmit(AuthController auth) {
    final otp = _controllers.map((c) => c.text.trim()).join();
    if (otp.length == 6) {
      auth.confirmCode(
        email: widget.email,
        code: otp,
        onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: неверный код'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        ),
      );
    }
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 55,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < _focusNodes.length - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocConsumer<AuthBloc, AuthState>(
        bloc: AuthScope.blocOf(context),
        listener: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            context.goNamed('home');
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Spacer(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter OTP',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'We’ve sent a 6-digit code to your mobile',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          List.generate(6, (index) => _buildOtpField(index)),
                    ),
                    const SizedBox(height: 24),
                    Spacer(),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: AppButton(
                opacity: _isFilled ? 1 : 0.4,
                onPressed: _isFilled ? () => _onOtpSubmit(auth) : null,
                text: 'Verify',
                isLoading: state.isProcessing,
              ),
            ),
          );
        },
      ),
    );
  }
}
