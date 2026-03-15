import 'package:flutter/material.dart';
import 'package:lab1/controllers/registration_controller.dart';
import 'package:lab1/widgets/app_scaffold.dart';
import 'package:lab1/widgets/custom_button.dart';
import 'package:lab1/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

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

  Future<void> _submit() async {
    final regCtrl = context.read<RegistrationController>();

    setState(() {
      _firstError = null;
      _lastError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
    });

    if (_firstController.text.trim().isEmpty) {
      setState(() => _firstError = 'Required');
    }
    if (_lastController.text.trim().isEmpty) {
      setState(() => _lastError = 'Required');
    }
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Enter a valid email');
    }
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _phoneError = 'Required');
    } else if (!_phoneController.text.trim().startsWith('+380')) {
      setState(
        () => _phoneError = 'This format not available, must de start +380',
      );
    }
    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Min 6 chars');
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

    if (hasError) return;

    // Call registration controller to persist the user
    final success = await regCtrl.register(
      firstName: _firstController.text.trim(),
      lastName: _lastController.text.trim(),
      email: email,
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      age: 18, // default age (no age input in UI yet)
      gender: _gender ?? 'other',
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final msg = regCtrl.errorMessage.isNotEmpty
          ? regCtrl.errorMessage
          : 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
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
          Consumer<RegistrationController>(
            builder: (context, regCtrl, _) => CustomButton(
              title: regCtrl.state == RegistrationState.loading
                  ? 'Submitting...'
                  : 'Submit',
              onPressed: regCtrl.state == RegistrationState.loading
                  ? () {}
                  : _submit,
            ),
          ),
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
