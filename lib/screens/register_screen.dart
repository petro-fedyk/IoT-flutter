import 'package:flutter/material.dart';
import 'package:lab1/widgets/custom_button.dart';
import 'package:lab1/widgets/custom_text_field.dart';
import 'package:lab1/widgets/app_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _firstError;
  String? _lastError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  String? _gender;

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _firstError = null;
      _lastError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;

      if (_firstController.text.trim().isEmpty) {
        _firstError = 'Required';
      }
      if (_lastController.text.trim().isEmpty) {
        _lastError = 'Required';
      }
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        _emailError = 'Enter a valid email';
      }
      if (_phoneController.text.trim().isEmpty) {
        _phoneError = 'Required';
      }
      if (_passwordController.text.length < 6) {
        _passwordError = 'Min 6 chars';
      }

      if (_gender == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select gender')));
      }

      final hasError =
          _firstError != null ||
          _lastError != null ||
          _emailError != null ||
          _phoneError != null ||
          _passwordError != null ||
          _gender == null;

      if (!hasError) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Create an account', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          CustomTextField(
            hint: 'First name',
            controller: _firstController,
            errorText: _firstError,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'Last name',
            controller: _lastController,
            errorText: _lastError,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'Phone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            errorText: _phoneError,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _gender = v),
            hint: const Text('Gender'),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'Password',
            isPassword: true,
            controller: _passwordController,
            errorText: _passwordError,
          ),
          const SizedBox(height: 16),
          CustomButton(title: 'Submit', onPressed: _submit),
          const SizedBox(height: 8),
          CustomButton(
            title: 'Back to Login',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
