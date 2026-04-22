import 'package:flutter/material.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/widgets/change_password_form.dart';

class ChangePasswordScreen extends BaseScreen {
  const ChangePasswordScreen({
    super.key,
    super.title = 'Change Password',
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends BaseScreenState<ChangePasswordScreen> {
  @override
  Widget build(BuildContext context, [_]) {
    return super.build(
      context,
      const SingleChildScrollView(
        child: ChangePasswordForm(),
      ),
    );
  }
}
