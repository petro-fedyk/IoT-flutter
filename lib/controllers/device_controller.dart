import 'package:flutter/foundation.dart';
import 'package:lab1/models/device.dart';
import 'package:lab1/repositories/local_device_repository.dart';

class DeviceController extends ChangeNotifier {
  final LocalDeviceRepository _repo;
  List<DeviceModel> _devices = [];
  String? _userId;
  bool _isLoading = false;

  DeviceController({required LocalDeviceRepository repo}) : _repo = repo;

  List<DeviceModel> get devices => List.unmodifiable(_devices);
  bool get isLoading => _isLoading;

  Future<void> loadForUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    _userId = userId;
    final stored = await _repo.getDevicesForUser(userId);
    if (stored.isEmpty) {
      // Initialize defaults for new users
      _devices = [
        DeviceModel(
          id: 'light-1',
          name: 'Light',
          type: DeviceType.light,
          isOn: true,
          brightness: 80,
        ),
        DeviceModel(
          id: 'thermo-1',
          name: 'Thermostat',
          type: DeviceType.thermostat,
          isOn: true,
        ),
        DeviceModel(
          id: 'ac-1',
          name: 'Air Conditioner',
          type: DeviceType.airConditioner,
          temperature: 20,
        ),
        DeviceModel(
          id: 'door-1',
          name: 'Door Lock',
          type: DeviceType.lock,
          isOn: true,
        ),
        DeviceModel(id: 'cam-1', name: 'Camera', type: DeviceType.camera),
      ];
      await _repo.saveDevicesForUser(userId, _devices);
    } else {
      _devices = stored;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDevice(DeviceModel device) async {
    final idx = _devices.indexWhere((d) => d.id == device.id);
    if (idx == -1) return;
    _devices[idx] = device;
    // Copy to a local variable so Dart can promote it to non-nullable String.
    final userId = _userId;
    if (userId != null) {
      await _repo.saveDevicesForUser(userId, _devices);
    }
    notifyListeners();
  }

  Future<void> renameDevice(String deviceId, String newName) async {
    final idx = _devices.indexWhere((d) => d.id == deviceId);
    if (idx == -1) return;
    _devices[idx].name = newName;
    final userId = _userId;
    if (userId != null) {
      await _repo.saveDevicesForUser(userId, _devices);
    }
    notifyListeners();
  }

  Future<void> toggleDevice(String deviceId) async {
    final idx = _devices.indexWhere((d) => d.id == deviceId);
    if (idx == -1) return;
    _devices[idx].isOn = !_devices[idx].isOn;
    final userId = _userId;
    if (userId != null) {
      await _repo.saveDevicesForUser(userId, _devices);
    }
    notifyListeners();
  }
}
