import 'package:flutter/material.dart';

class ReadingTile extends StatelessWidget {
  final String label;
  final String value;

  const ReadingTile({required this.label, required this.value, super.key});

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

class BatteryCard extends StatelessWidget {
  final int battery;

  const BatteryCard({required this.battery, super.key});

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
