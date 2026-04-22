import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tacit_mobile/bloc/config_bloc.dart';
import 'package:tacit_mobile/screens/base_screen.dart';
import 'package:tacit_mobile/screens/home_screen.dart';
import 'package:tacit_mobile/screens/server_setup_screen.dart';

class SplashScreen extends BaseScreen {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseScreenState<SplashScreen> {
  late final StreamSubscription<bool> _configSubscription;

  @override
  void initState() {
    super.initState();

    _configSubscription = ConfigBloc().isConfigured.listen((configured) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (configured) {
          popAllAndPush(const HomeScreen());
        } else {
          popAllAndPush(const ServerSetupScreen());
        }
      });
    });
  }

  @override
  void dispose() {
    _configSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, [_]) {
    super.build(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'Loading TACIT Mobile',
          liveRegion: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('TACIT Mobile'),
            ],
          ),
        ),
      ),
    );
  }
}
