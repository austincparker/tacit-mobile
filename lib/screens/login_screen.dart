import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/flavors.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/screens/forgot_password_screen.dart';
import 'package:flutter_app_base/screens/main_screen.dart';
import 'package:flutter_app_base/screens/registration_screen.dart';
import 'package:flutter_app_base/widgets/login_form.dart';

class LoginScreen extends BaseScreen {
  const LoginScreen({
    super.key,
    super.title = 'Login',
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreenState<LoginScreen> {
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
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: F.appFlavor == Flavor.staging //
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: F.appFlavor == Flavor.staging //
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            child: Text(
              'Flavor: ${F.name}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: F.appFlavor == Flavor.staging //
                    ? Colors.orange.shade900
                    : Colors.green.shade900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Semantics(
              label: 'Nashville skyline image',
              image: true,
              child: CachedNetworkImage(
                imageUrl: 'https://twinsunsolutions.com/assets/images/home/nashville-skyline.jpg',
                placeholder: (_, _) => Image.asset(
                  'assets/loading.png',
                  semanticLabel: 'Loading image',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const LoginForm(),
          TextButton(
            onPressed: () => popAllAndPush(const ForgotPasswordScreen()),
            child: const Text('Forgot password?'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () => popAllAndPush(const RegistrationScreen()),
                child: const Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
