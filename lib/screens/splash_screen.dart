import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/screens/login_screen.dart';
import 'package:flutter_app_base/screens/main_screen.dart';

class SplashScreen extends BaseScreen {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseScreenState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    AuthBloc().fetchCurrentUser().then((user) {
      Future.delayed(
        const Duration(seconds: 2),
        () => popAllAndPush(const MainScreen()),
      );
    }).catchError((error) {
      Future.delayed(
        const Duration(seconds: 2),
        () => popAllAndPush(const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context, [_]) {
    super.build(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'Loading application',
          liveRegion: true,
          child: const Text('Splash Screen'),
        ),
      ),
    );
  }
}
