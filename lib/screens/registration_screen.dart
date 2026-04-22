import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/screens/login_screen.dart';
import 'package:flutter_app_base/screens/main_screen.dart';
import 'package:flutter_app_base/widgets/registration_form.dart';

class RegistrationScreen extends BaseScreen {
  const RegistrationScreen({
    super.key,
    super.title = 'Sign Up',
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends BaseScreenState<RegistrationScreen> {
  late final StreamSubscription<User?> _currentUserSubscription;

  @override
  void initState() {
    super.initState();
    _currentUserSubscription = AuthBloc().currentUserStream.listen((user) {
      if (user == null) return;

      Future.delayed(
        const Duration(seconds: 2),
        () => popAllAndPush(const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _currentUserSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RegistrationForm(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
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
