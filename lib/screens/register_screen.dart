import 'package:flutter/material.dart';
import 'package:lab1/screens/register_form.dart';
import 'package:lab1/widgets/app_scaffold.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register',
      scrollable: true,
      child: const RegisterForm(),
    );
  }
}
