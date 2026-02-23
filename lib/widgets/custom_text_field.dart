import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? errorText;

  const CustomTextField({
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
    );
  }
}
