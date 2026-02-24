import 'package:flutter/material.dart';
import 'package:lab1/widgets/app_scaffold.dart';
import 'package:lab1/widgets/custom_button.dart';
import 'package:lab1/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _userError;
  String? _passwordError;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    setState(() {
      _userError = null;
      _passwordError = null;
      final user = _userController.text.trim();
      final pass = _passwordController.text;

      if (user.isEmpty) {
        _userError = 'Please enter username or email';
      }

      if (pass.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }

      if (_userError == null && _passwordError == null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      scrollable: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Welcome back', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          CustomTextField(
            hint: 'Email or username',
            controller: _userController,
            keyboardType: TextInputType.emailAddress,
            errorText: _userError,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            hint: 'Password',
            isPassword: true,
            controller: _passwordController,
            errorText: _passwordError,
          ),
          const SizedBox(height: 16),
          CustomButton(title: 'Sign In', onPressed: _signIn),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
