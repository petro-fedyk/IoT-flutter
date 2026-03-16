import 'package:flutter/material.dart';
import 'package:lab1/controllers/device_controller.dart';
import 'package:lab1/models/device.dart';
import 'package:lab1/widgets/device_control_widget.dart';
import 'package:provider/provider.dart';

class DeviceTile extends StatelessWidget {
  final DeviceModel device;

  const DeviceTile({required this.device, super.key});

  Future<void> _rename(BuildContext context) async {
    final controller = TextEditingController(text: device.name);
    final res = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename device'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (res != null && res.isNotEmpty) {
      context.read<DeviceController>().renameDevice(device.id, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = device.isOn
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final deviceCtrl = context.read<DeviceController>();

    IconData iconForType(DeviceModel d) {
      switch (d.type) {
        case DeviceType.light:
          return Icons.lightbulb;
        case DeviceType.thermostat:
          return Icons.thermostat;
        case DeviceType.airConditioner:
          return Icons.ac_unit;
        case DeviceType.lock:
          return Icons.lock;
        case DeviceType.camera:
          return Icons.camera_alt;
        case DeviceType.powerStation:
          return Icons.battery_charging_full;
        default:
          return Icons.device_unknown;
      }
    }

    final controlWidget = DeviceControlWidget(
      device: device,
      textStyle: textStyle,
      statusColor: color,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (device.type == DeviceType.powerStation) {
            Navigator.pushNamed(context, '/power-station');
          } else if (device.type == DeviceType.lock) {
            Navigator.pushNamed(context, '/lock');
          } else {
            deviceCtrl.toggleDevice(device.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconForType(device), size: 40, color: color),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            device.name,
                            style: textStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: () => _rename(context),
                          tooltip: 'Rename',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 55),
                    child: controlWidget,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
