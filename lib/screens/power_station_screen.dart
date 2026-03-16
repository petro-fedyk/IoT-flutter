import 'package:flutter/material.dart';
import 'package:lab1/controllers/connectivity_controller.dart';
import 'package:lab1/controllers/power_station_controller.dart';
import 'package:provider/provider.dart';

class PowerStationScreen extends StatefulWidget {
  const PowerStationScreen({super.key});

  @override
  State<PowerStationScreen> createState() => _PowerStationScreenState();
}

class _PowerStationScreenState extends State<PowerStationScreen> {
  bool? _wasOnline;

  @override
  void initState() {
    super.initState();
    // Connect after first frame so Provider is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectivity = context.read<ConnectivityController>();
      final ctrl = context.read<PowerStationController>();
      ctrl.setOnline(connectivity.hasInternet);
      ctrl.connect();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final connectivity = context.watch<ConnectivityController>();
    if (_wasOnline != connectivity.hasInternet) {
      _wasOnline = connectivity.hasInternet;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PowerStationController>().setOnline(_wasOnline ?? true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityController>();
    final ctrl = context.watch<PowerStationController>();
    final reading = ctrl.lastReading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Station'),
        actions: [
          IconButton(
            tooltip: 'Reconnect',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!connectivity.hasInternet) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No internet: MQTT disabled')),
                );
                return;
              }
              ctrl.connect();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!connectivity.hasInternet)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Offline: MQTT disabled',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    key: ValueKey<bool>(ctrl.isConnected),
                    ctrl.isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: ctrl.isConnected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(ctrl.status, key: ValueKey<String>(ctrl.status)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: reading == null
                    ? const Text('No data received yet.')
                    : ListView(
                        children: [
                          _ReadingTile(
                            label: 'Temperature',
                            value: '${reading.temperature} °C',
                          ),
                          _ReadingTile(
                            label: 'Voltage',
                            value: '${reading.voltage} V',
                          ),
                          _ReadingTile(
                            label: 'Current',
                            value: '${reading.current} A',
                          ),
                          _ReadingTile(
                            label: 'Power',
                            value: '${reading.power} W',
                          ),
                          _BatteryCard(battery: reading.battery),
                          _ReadingTile(
                            label: 'Alarm',
                            value: reading.alarm ? 'ON' : 'OFF',
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final String label;
  final String value;

  const _ReadingTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        title: Text(label),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _BatteryCard extends StatelessWidget {
  final int battery;

  const _BatteryCard({required this.battery});

  @override
  Widget build(BuildContext context) {
    final normalized = (battery.clamp(0, 100)) / 100;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Battery'),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween<double>(begin: 0, end: normalized),
              builder: (context, value, _) =>
                  LinearProgressIndicator(value: value, minHeight: 8),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                '$battery %',
                key: ValueKey<int>(battery),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
