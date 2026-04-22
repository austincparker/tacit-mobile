import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/screens/base_screen.dart';
import 'package:flutter_app_base/widgets/edit_profile_form.dart';

class EditProfileScreen extends BaseScreen {
  const EditProfileScreen({
    super.key,
    super.title = 'Edit Profile',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends BaseScreenState<EditProfileScreen> {
  @override
  Widget build(BuildContext context, [_]) {
    final user = AuthBloc().currentUser;
    if (user == null) {
      return super.build(context, const Center(child: Text('Not logged in')));
    }

    return super.build(
      context,
      SingleChildScrollView(
        child: EditProfileForm(user: user),
      ),
    );
  }
}
