import 'package:flutter/material.dart';
import 'package:lab1/models/device.dart';

class DeviceTile extends StatefulWidget {
  final DeviceModel device;

  const DeviceTile({required this.device, super.key});

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  late bool _isOn;
  int _brightness = 100;
  double _temperature = 22;
  late String _name;

  @override
  void initState() {
    super.initState();
    _isOn = widget.device.isOn;
    _brightness = widget.device.brightness;
    _temperature = widget.device.temperature;
    _name = widget.device.name;
  }

  void _toggle() {
    setState(() => _isOn = !_isOn);
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: _name);
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
      setState(() => _name = res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _isOn ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

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
        default:
          return Icons.device_unknown;
      }
    }

    // Build a compact control widget depending on device type
    Widget controlWidget;
    if (widget.device.type == DeviceType.light ||
        widget.device.name.toLowerCase().contains('light') ||
        widget.device.name.toLowerCase().contains('lamp')) {
      controlWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Brightness: $_brightness%', style: textStyle),
          SizedBox(
            height: 25,
            child: Slider(
              max: 100,
              value: _brightness.toDouble(),
              onChanged: (v) => setState(() => _brightness = v.round()),
            ),
          ),
        ],
      );
    } else if (widget.device.type == DeviceType.thermostat ||
        widget.device.name.toLowerCase().contains('thermostat')) {
      controlWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Temp:'),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: TextFormField(
              initialValue: _temperature.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 6,
                ),
              ),
              onFieldSubmitted: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) setState(() => _temperature = parsed);
              },
            ),
          ),
          const Text('°C'),
        ],
      );
    } else if (widget.device.type == DeviceType.airConditioner ||
        widget.device.name.toLowerCase().contains('air')) {
      controlWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Temp:'),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: TextFormField(
              initialValue: _temperature.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 6,
                ),
              ),
              onFieldSubmitted: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) setState(() => _temperature = parsed);
              },
            ),
          ),
          const Text('°C'),
        ],
      );
    } else {
      controlWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(_isOn ? 'ON' : 'OFF', style: textStyle?.copyWith(color: color)),
        ],
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconForType(widget.device), size: 40, color: color),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _name,
                            style: textStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: _rename,
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
