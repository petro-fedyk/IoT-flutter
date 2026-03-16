import 'package:flutter/material.dart';
import 'package:lab1/controllers/home_controller.dart';
import 'package:lab1/controllers/lock_controller.dart';
import 'package:lab1/widgets/lock_tile.dart';
import 'package:provider/provider.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeController, LockController>(
      builder: (context, homeCtrl, lockCtrl, _) {
        final userEmail = homeCtrl.currentUser?.email;
        return Scaffold(
          appBar: AppBar(title: const Text('Shafa Lock')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      lockCtrl.isLocked ? Icons.lock : Icons.lock_open,
                      color: lockCtrl.isLocked
                          ? Colors.redAccent
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lockCtrl.isLocked ? 'Locked' : 'Unlocked',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: lockCtrl.isSending
                          ? null
                          : () => lockCtrl.toggleLock(userEmail),
                      icon: Icon(
                        lockCtrl.isLocked ? Icons.lock_open : Icons.lock,
                      ),
                      label: Text(lockCtrl.isLocked ? 'Unlock' : 'Lock'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: lockCtrl.isLoadingHistory
                        ? null
                        : lockCtrl.fetchHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('View History'),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      if (lockCtrl.isLoadingHistory)
                        const Center(child: CircularProgressIndicator())
                      else if (lockCtrl.history.isEmpty)
                        const Text('No history loaded yet.')
                      else
                        for (final event in lockCtrl.history) ...[
                          LockTile(event: event),
                          const SizedBox(height: 10),
                        ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
