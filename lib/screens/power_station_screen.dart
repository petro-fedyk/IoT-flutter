import 'package:flutter/material.dart';
import 'package:lab1/controllers/connectivity_controller.dart';
import 'package:lab1/controllers/power_station_controller.dart';
import 'package:lab1/screens/power_station_widgets.dart';
import 'package:provider/provider.dart';

class PowerStationScreen extends StatelessWidget {
  const PowerStationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityController>();
    final ctrl = context.watch<PowerStationController>();
    final reading = ctrl.lastReading;
    ctrl.ensureConnected(connectivity.hasInternet);

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
                          ReadingTile(
                            label: 'Temperature',
                            value: '${reading.temperature} °C',
                          ),
                          ReadingTile(
                            label: 'Voltage',
                            value: '${reading.voltage} V',
                          ),
                          ReadingTile(
                            label: 'Current',
                            value: '${reading.current} A',
                          ),
                          ReadingTile(
                            label: 'Power',
                            value: '${reading.power} W',
                          ),
                          BatteryCard(battery: reading.battery),
                          ReadingTile(
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
