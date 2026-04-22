import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/firebase_options.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/screens/settings_screen.dart';

class MainScreen extends BaseScreen {
  const MainScreen({
    super.key,
    super.title = 'Main Screen',
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends BaseScreenState<MainScreen> {
  late final StreamSubscription<User?> _currentUserSubscription;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUserSubscription = AuthBloc().currentUserStream.listen(_onCurrentUserChanged);
  }

  @override
  void dispose() {
    _currentUserSubscription.cancel();
    super.dispose();
  }

  void _onCurrentUserChanged(User? user) {
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              semanticsLabel: _currentUser?.email != null //
                  ? 'Current user: ${_currentUser!.email}'
                  : 'No user logged in',
              _currentUser?.email ?? 'No user',
            ),
            TextButton.icon(
              onPressed: () => pushScreen(const SettingsScreen()),
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
            ),
            if (DefaultFirebaseOptions.isConfigured) ...[
              MergeSemantics(
                child: Semantics(
                  label: 'Crash application',
                  hint: 'Warning: This will crash the app for testing purposes',
                  child: TextButton(
                    onPressed: FirebaseCrashlytics.instance.crash,
                    child: const Text('Crash'),
                  ),
                ),
              ),
              MergeSemantics(
                child: Semantics(
                  label: 'Submit non-fatal Firebase error report',
                  child: TextButton(
                    onPressed: () => FirebaseCrashlytics.instance.recordError('Test Report', null),
                    child: const Text('Non-fatal Firebase Report'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
