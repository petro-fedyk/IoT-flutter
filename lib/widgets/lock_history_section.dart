import 'package:flutter/material.dart';
import 'package:lab1/models/lock_event.dart';
import 'package:lab1/widgets/lock_tile.dart';

class LockHistorySection extends StatelessWidget {
  final List<LockEvent> events;

  const LockHistorySection({required this.events, super.key});

  factory LockHistorySection.sample({Key? key}) {
    return LockHistorySection(
      key: key,
      events: [
        LockEvent(
          id: 1,
          time: DateTime(2025, 5, 2, 18),
          unlockMethod: 'Keypad',
          isSuccess: true,
          user: 'admin',
        ),
        LockEvent(
          id: 2,
          time: DateTime(2025, 5, 2, 19, 10),
          unlockMethod: 'Keypad',
          isSuccess: true,
          user: 'admin1',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shafa Lock', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        for (final event in events) ...[
          LockTile(event: event),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
