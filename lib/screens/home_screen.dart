import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iot_torch_plugin/iot_torch_plugin.dart';
import 'package:lab1/controllers/connectivity_controller.dart';
import 'package:lab1/controllers/device_controller.dart';
import 'package:lab1/controllers/home_controller.dart';
import 'package:lab1/widgets/device_tile.dart';
import 'package:lab1/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = context.watch<HomeController>();
    final deviceCtrl = context.watch<DeviceController>();
    final connectivity = context.watch<ConnectivityController>();
    final user = homeCtrl.currentUser;
    if (user != null) {
      deviceCtrl.ensureLoaded(user.id);
    }
    final devices = deviceCtrl.devices;

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1000 ? 4 : (width >= 700 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          // Secret trigger: long-press on the title to toggle the torch.
          onLongPress: () async {
            // On non-Android platforms show a warning dialog.
            if (defaultTargetPlatform != TargetPlatform.android) {
              if (!context.mounted) return;
              await showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Torch not available'),
                    content: const Text(
                      'Flashlight control is not supported on this '
                      'platform.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              return;
            }

            final isOn = await IotTorchPlugin.toggleTorch();
            if (!context.mounted) return;

            final message = isOn ? 'Flashlight ON' : 'Flashlight OFF';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          child: const Text('Home'),
        ),
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
        child: ListView(
          children: [
            const Text('Smart Devices', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            if (!connectivity.hasInternet)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Offline: MQTT data may be unavailable',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            if (deviceCtrl.isLoading)
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final d = devices[index];
                  return DeviceTile(device: d);
                },
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
