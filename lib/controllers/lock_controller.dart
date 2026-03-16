import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lab1/models/lock_event.dart';

class LockController extends ChangeNotifier {
  final String apiUrl;

  LockController({required this.apiUrl});

  bool _isLocked = true;
  bool _isSending = false;
  bool _isLoadingHistory = false;
  List<LockEvent> _history = [];

  bool get isLocked => _isLocked;
  bool get isSending => _isSending;
  bool get isLoadingHistory => _isLoadingHistory;
  List<LockEvent> get history => List.unmodifiable(_history);

  Future<void> toggleLock(String? userEmail) async {
    _isLocked = !_isLocked;
    notifyListeners();
    final payload = _buildPayload(userEmail);
    await _sendPayload(payload);
  }

  Future<void> fetchHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API error: ${response.statusCode}');
      }
      final data = jsonDecode(response.body) as List<dynamic>;
      _history = data
          .whereType<Map<String, dynamic>>()
          .map(_mapToLockEvent)
          .toList();
    } catch (e) {
      debugPrint('History failed: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildPayload(String? userEmail) {
    return {
      'time': _formatApiTime(DateTime.now()),
      'unlockMethod': 'modile app',
      'isSuccess': true,
      'user': userEmail ?? 'petro',
    };
  }

  Future<void> _sendPayload(Map<String, dynamic> payload) async {
    _isSending = true;
    notifyListeners();
    try {
      await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (e) {
      debugPrint('Lock request failed: $e');
    } finally {
      _isSending = false;
      notifyListeners();
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
