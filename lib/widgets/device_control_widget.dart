import 'package:flutter/material.dart';
import 'package:lab1/controllers/device_controller.dart';
import 'package:lab1/models/device.dart';
import 'package:provider/provider.dart';

class DeviceControlWidget extends StatelessWidget {
  final DeviceModel device;
  final TextStyle? textStyle;
  final Color statusColor;

  const DeviceControlWidget({
    required this.device,
    required this.textStyle,
    required this.statusColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final deviceCtrl = context.read<DeviceController>();

    if (device.type == DeviceType.powerStation) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tap to view', style: textStyle),
          const SizedBox(height: 6),
          const Icon(Icons.open_in_new, size: 16),
        ],
      );
    }

    if (device.type == DeviceType.light ||
        device.name.toLowerCase().contains('light') ||
        device.name.toLowerCase().contains('lamp')) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Brightness: ${device.brightness}%', style: textStyle),
          SizedBox(
            height: 25,
            child: Slider(
              max: 100,
              value: device.brightness.toDouble(),
              onChanged: (v) => deviceCtrl.updateDevice(
                device.copyWith(brightness: v.round()),
              ),
            ),
          ),
        ],
      );
    }

    if (device.type == DeviceType.thermostat ||
        device.name.toLowerCase().contains('thermostat')) {
      return _TempControl(
        device: device,
        deviceCtrl: deviceCtrl,
        label: 'Temp:',
      );
    }

    if (device.type == DeviceType.airConditioner ||
        device.name.toLowerCase().contains('air')) {
      return _TempControl(
        device: device,
        deviceCtrl: deviceCtrl,
        label: 'Temp:',
      );
    }

    if (device.type == DeviceType.lock) {
      final statusText = device.isOn ? 'Locked' : 'Unlocked';
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(statusText, style: textStyle)],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          device.isOn ? 'ON' : 'OFF',
          style: textStyle?.copyWith(color: statusColor),
        ),
      ],
    );
  }
}

class _TempControl extends StatelessWidget {
  final DeviceModel device;
  final DeviceController deviceCtrl;
  final String label;

  const _TempControl({
    required this.device,
    required this.deviceCtrl,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: TextFormField(
            initialValue: device.temperature.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            ),
            onFieldSubmitted: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) {
                deviceCtrl.updateDevice(device.copyWith(temperature: parsed));
              }
            },
          ),
        ),
        const Text('°C'),
      ],
    );
  }
}
