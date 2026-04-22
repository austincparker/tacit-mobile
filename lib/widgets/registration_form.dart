import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/model/api_response.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  String _errorMessage = '';
  Map<String, List<String>> _fieldErrors = {};
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  /// Returns error text for a field, or null if no errors
  String? _errorTextFor(String field) {
    final errors = _fieldErrors[field];
    if (errors == null || errors.isEmpty) return null;
    return errors.join('. ');
  }

  Future<void> _onRegister() async {
    _clearErrors();

    try {
      await AuthBloc().register(
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      );
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

  void _clearErrors() {
    setState(() {
      _errorMessage = '';
      _fieldErrors = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Semantics(
              header: true,
              child: const Text('Create Account'),
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
            controller: _emailController,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _errorTextFor('email'),
            ),
          ),
          TextField(
            controller: _passwordController,
            autofillHints: const [AutofillHints.newPassword],
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _errorTextFor('password'),
            ),
          ),
          TextField(
            controller: _passwordConfirmationController,
            autofillHints: const [AutofillHints.newPassword],
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              errorText: _errorTextFor('password_confirmation'),
            ),
            onSubmitted: (_) => _onRegister(),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _onRegister,
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
