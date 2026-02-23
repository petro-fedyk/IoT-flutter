import 'package:flutter/material.dart';
import 'package:lab1/widgets/custom_button.dart';
import 'package:lab1/widgets/theme_toggle_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [ThemeToggleButton()]),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 96, height: 96),
                const SizedBox(height: 20),
                Text(
                  'Smart Home',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  title: 'Sign In',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  title: 'Register',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
