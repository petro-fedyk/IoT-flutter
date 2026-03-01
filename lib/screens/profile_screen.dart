import 'package:flutter/material.dart';
import 'package:lab1/controllers/home_controller.dart';
import 'package:lab1/widgets/custom_button.dart';
import 'package:lab1/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final homeCtrl = context.watch<HomeController>();
    final user = homeCtrl.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [ThemeToggleButton()],
      ),
      body: Center(
        child: user == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No user logged in'),
                  const SizedBox(height: 12),
                  CustomButton(
                    title: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    child: Icon(Icons.person, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text('${user.firstName} ${user.lastName}'),
                  const SizedBox(height: 8),
                  Text(user.email),
                  const SizedBox(height: 8),
                  Text(user.phone),
                  const SizedBox(height: 12),
                  CustomButton(
                    title: 'Edit',
                    onPressed: homeCtrl.isLoading
                        ? () {}
                        : () => Navigator.pushNamed(context, '/profile/edit'),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    title: homeCtrl.isLoading
                        ? 'Deleting...'
                        : 'Delete account',
                    onPressed: homeCtrl.isLoading
                        ? () {}
                        : () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Delete account'),
                                content: const Text(
                                  'Are you sure you want to delete your account?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              final success = await homeCtrl.deleteAccount(
                                user.id,
                              );
                              if (!mounted) return;
                              if (success) {
                                navigator.pushReplacementNamed('/login');
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(homeCtrl.errorMessage),
                                  ),
                                );
                              }
                            }
                          },
                  ),
                ],
              ),
      ),
    );
  }
}
