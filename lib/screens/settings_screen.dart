import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/screens/change_password_screen.dart';
import 'package:flutter_app_base/screens/edit_profile_screen.dart';
import 'package:flutter_app_base/screens/login_screen.dart';

class SettingsScreen extends BaseScreen {
  const SettingsScreen({
    super.key,
    super.title = 'Settings',
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseScreenState<SettingsScreen> {
  late final StreamSubscription<User?> _currentUserSubscription;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = AuthBloc().currentUser;
    _currentUserSubscription = AuthBloc().currentUserStream.listen((user) {
      if (user == null) {
        // User logged out or deleted, navigate to login
        popAllAndPush(const LoginScreen());
        return;
      }
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    _currentUserSubscription.cancel();
    super.dispose();
  }

  Future<void> _onLogout() async {
    await AuthBloc().logout();
  }

  Future<void> _onDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AuthBloc().deleteAccount();
    } on ApiResponse catch (response) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Text(response.error?.message ?? 'Failed to delete account'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          Semantics(
            header: true,
            child: const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(_currentUser?.email ?? ''),
          ),
          if (_currentUser?.subscribed ?? false)
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Subscription'),
              subtitle: Text(
                _currentUser?.subscribedUntil != null
                    ? 'Active until ${_currentUser!.subscribedUntil!.toLocal().toString().split(' ')[0]}'
                    : 'Active',
              ),
            ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => pushScreen(const EditProfileScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => pushScreen(const ChangePasswordScreen()),
          ),
          const Divider(),

          // Actions Section
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: _onLogout,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _onDeleteAccount,
          ),
        ],
      ),
    );
  }
}
