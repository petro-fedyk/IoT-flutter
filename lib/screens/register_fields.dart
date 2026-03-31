import 'package:flutter/material.dart';
import 'package:lab1/widgets/custom_button.dart';
import 'package:lab1/widgets/custom_text_field.dart';

class RegisterFields extends StatelessWidget {
  final TextEditingController firstController;
  final TextEditingController lastController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final String? firstError;
  final String? lastError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String? gender;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final VoidCallback onBack;

  const RegisterFields({
    required this.firstController,
    required this.lastController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.firstError,
    required this.lastError,
    required this.emailError,
    required this.phoneError,
    required this.passwordError,
    required this.gender,
    required this.onGenderChanged,
    required this.onSubmit,
    required this.submitLabel,
    required this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Create an account', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        CustomTextField(
          hint: 'First name',
          controller: firstController,
          errorText: firstError,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: 'Last name',
          controller: lastController,
          errorText: lastError,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: 'Email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: emailError,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: 'Phone',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          errorText: phoneError,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: gender,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: onGenderChanged,
          hint: const Text('Gender'),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: 'Password',
          isPassword: true,
          controller: passwordController,
          errorText: passwordError,
        ),
        const SizedBox(height: 16),
        CustomButton(title: submitLabel, onPressed: onSubmit ?? () {}),
        const SizedBox(height: 8),
        CustomButton(title: 'Back to Login', onPressed: onBack),
      ],
    );
  }
}
