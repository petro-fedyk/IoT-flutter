import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lab1/controllers/home_controller.dart';
import 'package:lab1/models/lock_event.dart';
import 'package:lab1/widgets/lock_tile.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isLocked = true;
  bool _isSending = false;
  static const _apiUrl = 'http://192.168.31.114:5000/api/shafa_data/';
  bool _isLoadingHistory = false;
  List<LockEvent> _history = [];

  @override
  Widget build(BuildContext context) {
    final userEmail = context.watch<HomeController>().currentUser?.email;
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
                  _isLocked ? Icons.lock : Icons.lock_open,
                  color: _isLocked ? Colors.redAccent : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLocked ? 'Locked' : 'Unlocked',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _isSending ? null : () => _toggleLock(userEmail),
                  icon: Icon(_isLocked ? Icons.lock_open : Icons.lock),
                  label: Text(_isLocked ? 'Unlock' : 'Lock'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingHistory ? null : _fetchHistory,
                icon: const Icon(Icons.history),
                label: const Text('View History'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (_isLoadingHistory)
                    const Center(child: CircularProgressIndicator())
                  else if (_history.isEmpty)
                    const Text('No history loaded yet.')
                  else
                    for (final event in _history) ...[
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
  }

  Future<void> _toggleLock(String? userEmail) async {
    setState(() => _isLocked = !_isLocked);
    final payload = _buildPayload(userEmail);
    await _sendPayload(payload);
  }

  Map<String, dynamic> _buildPayload(String? userEmail) {
    return {
      'time': _formatApiTime(DateTime.now()),
      'unlockMethod': 'modile app',
      'isSuccess': true,
      'user': userEmail ?? 'petro',
    };
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (!mounted) return;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API error: ${response.statusCode}')),
        );
        return;
      }
      final data = jsonDecode(response.body) as List<dynamic>;
      final parsed = data
          .whereType<Map<String, dynamic>>()
          .map(_mapToLockEvent)
          .toList();
      setState(() => _history = parsed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('History failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  LockEvent _mapToLockEvent(Map<String, dynamic> json) {
    final timeRaw = json['time']?.toString() ?? '';
    return LockEvent(
      id: (json['id'] as num?)?.toInt() ?? 0,
      time: _parseApiTime(timeRaw) ?? DateTime.now(),
      unlockMethod: json['unlockMethod']?.toString() ?? 'Unknown',
      isSuccess: json['isSuccess'] == true,
      user: json['user']?.toString() ?? 'unknown',
    );
  }

  Future<void> _sendPayload(Map<String, dynamic> payload) async {
    setState(() => _isSending = true);
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (!mounted) return;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _formatApiTime(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}.${two(time.month)}.${two(time.day)}.'
        '${two(time.hour)}:${two(time.minute)}';
  }

  DateTime? _parseApiTime(String raw) {
    final parts = raw.split('.');
    if (parts.length < 4) return DateTime.tryParse(raw);
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    final timeParts = parts[3].split(':');
    if (timeParts.length < 2) return DateTime.tryParse(raw);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if ([year, month, day, hour, minute].any((v) => v == null)) {
      return DateTime.tryParse(raw);
    }
    return DateTime(year!, month!, day!, hour!, minute!);
  }
}
