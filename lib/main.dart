import 'package:flutter/material.dart';
import 'package:lab1/screens/home_screen.dart';
import 'package:lab1/screens/login_screen.dart';
import 'package:lab1/screens/profile_screen.dart';
import 'package:lab1/screens/register_screen.dart';
import 'package:lab1/screens/welcome_screen.dart';
import 'package:lab1/theme/theme_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Home',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7FBFF),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeController.mode,
          initialRoute: '/welcome',
          routes: {
            '/welcome': (_) => const WelcomeScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/home': (_) => const HomeScreen(),
            '/profile': (_) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
