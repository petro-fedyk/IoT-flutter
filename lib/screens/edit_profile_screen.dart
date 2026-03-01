import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lab1/controllers/home_controller.dart';
import 'package:lab1/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  String _gender = 'other';

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final home = context.read<HomeController>();
    final user = home.currentUser;
    if (user != null) {
      _first.text = user.firstName;
      _last.text = user.lastName;
      _phone.text = user.phone;
      _gender = user.gender;
    }
  }

  Future<void> _save() async {
    final home = context.read<HomeController>();
    final success = await home.updateProfile(
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      phone: _phone.text.trim(),
      age: home.currentUser?.age ?? 18,
      gender: _gender,
    );
    if (!mounted) return;
    if (success)
      Navigator.pop(context);
    else
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(home.errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _first,
              decoration: const InputDecoration(labelText: 'First name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _last,
              decoration: const InputDecoration(labelText: 'Last name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _gender,
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v ?? 'other'),
            ),
            const SizedBox(height: 16),
            Consumer<HomeController>(
              builder: (context, home, _) => CustomButton(
                title: home.isLoading ? 'Saving...' : 'Save',
                onPressed: home.isLoading ? () {} : _save,
              ),
            ),
            const SizedBox(height: 8),
            CustomButton(
              title: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
