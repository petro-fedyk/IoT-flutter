import 'package:flutter/material.dart';

class Device {
  final String name;
  final IconData icon;
  final bool initiallyOn;

  const Device({
    required this.name,
    required this.icon,
    this.initiallyOn = false,
  });
}

class DeviceTile extends StatefulWidget {
  final Device device;

  const DeviceTile({required this.device, super.key});

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.device.initiallyOn;
  }

  void _toggle() {
    setState(() => _isOn = !_isOn);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _isOn ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.device.icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(widget.device.name, style: textStyle),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOn ? 'ON' : 'OFF',
                    style: textStyle?.copyWith(color: color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
