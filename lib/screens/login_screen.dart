import 'package:flutter/material.dart';
import 'package:lab1/controllers/login_controller.dart';
import 'package:lab1/widgets/app_scaffold.dart';
import 'package:lab1/widgets/custom_button.dart';
import 'package:lab1/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

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

  Future<void> _signIn() async {
    // Use LoginController to perform authentication
    final loginCtrl = context.read<LoginController>();

    // Local quick validations
    setState(() {
      _userError = null;
      _passwordError = null;
      if (_userController.text.trim().isEmpty) {
        _userError = 'Please enter username or email';
      }
      if (_passwordController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }
    });

    if (_userError != null || _passwordError != null) return;

    // Call controller login
    final emailOrUser = _userController.text.trim();
    final pass = _passwordController.text;

    // Show loading via controller; await result
    final success = await loginCtrl.login(email: emailOrUser, password: pass);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final msg = loginCtrl.errorMessage.isNotEmpty
          ? loginCtrl.errorMessage
          : 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginCtrl = context.watch<LoginController>();

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
          CustomButton(
            title: loginCtrl.state == LoginState.loading
                ? 'Signing in...'
                : 'Sign In',
            onPressed: loginCtrl.state == LoginState.loading ? () {} : _signIn,
          ),
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
