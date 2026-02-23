import 'package:flutter/material.dart';
import 'package:lab1/theme/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return IconButton(
      tooltip: brightness == Brightness.dark ? 'Light theme' : 'Dark theme',
      icon: Icon(
        brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: themeController.toggle,
    );
  }
}
