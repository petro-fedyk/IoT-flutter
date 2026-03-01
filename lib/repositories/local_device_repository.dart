import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:lab1/models/device.dart';

/// Simple device repository stored per-user in SharedPreferences.
class LocalDeviceRepository {
  late final SharedPreferences _prefs;

  static const String _devicesPrefix = 'devices_';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<DeviceModel> _readDevices(String userId) {
    final key = '$_devicesPrefix$userId';
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _writeDevices(String userId, List<DeviceModel> devices) async {
    final key = '$_devicesPrefix$userId';
    final json = jsonEncode(devices.map((d) => d.toJson()).toList());
    await _prefs.setString(key, json);
  }

  Future<List<DeviceModel>> getDevicesForUser(String userId) async {
    return _readDevices(userId);
  }

  Future<void> saveDevicesForUser(
    String userId,
    List<DeviceModel> devices,
  ) async {
    await _writeDevices(userId, devices);
  }
}
