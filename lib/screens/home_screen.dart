import 'package:flutter/material.dart';
import 'package:lab1/controllers/device_controller.dart';
import 'package:lab1/controllers/home_controller.dart';
import 'package:lab1/widgets/device_tile.dart';
import 'package:lab1/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final homeCtrl = context.read<HomeController>();
      final deviceCtrl = context.read<DeviceController>();
      final user = homeCtrl.currentUser;
      if (user != null) {
        // Schedule loading after the first frame to avoid calling notifyListeners
        // during the widget build phase which causes "setState() called during build".
        WidgetsBinding.instance.addPostFrameCallback((_) {
          deviceCtrl.loadForUser(user.id);
        });
      }
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceCtrl = context.watch<DeviceController>();
    final devices = deviceCtrl.devices;

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
            if (deviceCtrl.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final d = devices[index];
                    return DeviceTile(device: d);
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
