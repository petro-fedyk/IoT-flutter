import 'package:flutter/material.dart';
import 'package:lab1/widgets/device_tile.dart';
import 'package:lab1/widgets/theme_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Device> _devices = [
    Device(name: 'Light', icon: Icons.lightbulb, initiallyOn: true),
    Device(name: 'Thermostat', icon: Icons.thermostat),
    Device(name: 'Door Lock', icon: Icons.lock, initiallyOn: true),
    Device(name: 'Camera', icon: Icons.camera_alt),
    Device(name: 'Air Conditioner', icon: Icons.ac_unit),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1000 ? 4 : (width >= 700 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Smart Devices', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return DeviceTile(device: _devices[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add device not implemented')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
