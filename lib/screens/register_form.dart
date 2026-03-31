import 'package:flutter/material.dart';
import 'package:lab1/controllers/registration_controller.dart';
import 'package:lab1/screens/register_fields.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
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

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _phoneError = 'Required');
    } else if (!phone.startsWith('+380')) {
      setState(() => _phoneError = 'Must start with +380');
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

    final success = await regCtrl.register(
      firstName: _firstController.text.trim(),
      lastName: _lastController.text.trim(),
      email: email,
      phone: phone,
      password: _passwordController.text,
      age: 18,
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
    return Consumer<RegistrationController>(
      builder: (context, regCtrl, _) => RegisterFields(
        firstController: _firstController,
        lastController: _lastController,
        emailController: _emailController,
        phoneController: _phoneController,
        passwordController: _passwordController,
        firstError: _firstError,
        lastError: _lastError,
        emailError: _emailError,
        phoneError: _phoneError,
        passwordError: _passwordError,
        gender: _gender,
        onGenderChanged: (v) => setState(() => _gender = v),
        submitLabel: regCtrl.state == RegistrationState.loading
            ? 'Submitting...'
            : 'Submit',
        onSubmit: regCtrl.state == RegistrationState.loading ? null : _submit,
        onBack: () => Navigator.pop(context),
      ),
    );
  }
}
