import 'package:flutter/material.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/screens/login_screen.dart';
import 'package:flutter_app_base/widgets/forgot_password_form.dart';

class ForgotPasswordScreen extends BaseScreen {
  const ForgotPasswordScreen({
    super.key,
    super.title = 'Forgot Password',
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends BaseScreenState<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ForgotPasswordForm(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Remember your password?'),
              TextButton(
                onPressed: () => popAllAndPush(const LoginScreen()),
                child: const Text('Log in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
