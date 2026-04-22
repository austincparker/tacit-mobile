import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/model/api_response.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  String _errorMessage = '';
  bool _isSuccess = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() {
      _errorMessage = '';
      _isSuccess = false;
    });

    try {
      await AuthBloc().requestPasswordReset(_emailController.text);
      setState(() {
        _isSuccess = true;
      });
    } on ApiResponse catch (response) {
      setState(() {
        _errorMessage = response.error?.message ?? 'An error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Success',
            child: const Icon(Icons.mark_email_read, size: 64, color: Colors.green),
          ),
          const SizedBox(height: 16),
          Text(
            'Check your email',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent password reset instructions to your email address.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return AutofillGroup(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Semantics(
              header: true,
              child: const Text('Forgot Password'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your email and we\'ll send you instructions to reset your password.',
            textAlign: TextAlign.center,
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
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            onSubmitted: (_) => _onSubmit(),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _onSubmit,
            child: const Text('Send Reset Instructions'),
          ),
        ],
      ),
    );
  }
}
