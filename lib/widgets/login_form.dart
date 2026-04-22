import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/model/api_response.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String errorMessage = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _onLogin() async {
    _clearErrorMessage();

    try {
      await AuthBloc().login(_emailController.text, _passwordController.text);
    } on ApiResponse catch (error) {
      setState(() {
        errorMessage = error.error?.message ?? 'An error occurred';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearErrorMessage() {
    setState(() {
      errorMessage = '';
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
              child: const Text('Login Form'),
            ),
          ),
          if (errorMessage.isNotEmpty)
            MergeSemantics(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  errorMessage,
                  semanticsLabel: 'Error message',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          MergeSemantics(
            child: Semantics(
              label: 'Email address',
              child: TextField(
                controller: _emailController,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
          ),
          MergeSemantics(
            child: Semantics(
              label: 'Password',
              child: TextField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                onSubmitted: (_) => _onLogin(),
              ),
            ),
          ),
          TextButton(
            onPressed: _onLogin,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
