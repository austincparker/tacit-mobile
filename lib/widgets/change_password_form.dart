import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/model/api_response.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  String _errorMessage = '';
  Map<String, List<String>> _fieldErrors = {};
  bool _isSuccess = false;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _errorTextFor(String field) {
    final errors = _fieldErrors[field];
    if (errors == null || errors.isEmpty) return null;
    return errors.join('. ');
  }

  Future<void> _onSave() async {
    setState(() {
      _errorMessage = '';
      _fieldErrors = {};
      _isSuccess = false;
    });

    try {
      await AuthBloc().updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      setState(() {
        _isSuccess = true;
      });
      // Clear fields on success
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on ApiResponse catch (response) {
      final error = response.error;
      if (error == null) return;

      setState(() {
        if (error.statusCode == 422) {
          _fieldErrors = error.fieldErrors;
        } else {
          _errorMessage = error.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isSuccess)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: const Text(
                'Password changed successfully!',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _currentPasswordController,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Current Password',
            errorText: _errorTextFor('current_password'),
          ),
        ),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'New Password',
            errorText: _errorTextFor('password'),
          ),
        ),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            errorText: _errorTextFor('password_confirmation'),
          ),
          onSubmitted: (_) => _onSave(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text('Change Password'),
        ),
      ],
    ),
    );
  }
}
