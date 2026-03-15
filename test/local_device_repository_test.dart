import 'package:flutter_test/flutter_test.dart';
import 'package:lab1/models/device.dart';
import 'package:lab1/repositories/local_device_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalDeviceRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = LocalDeviceRepository();
    await repo.init();
  });

  test('save and load devices for user', () async {
    const userId = 'user-1';
    final devices = [
      DeviceModel(
        id: 'l1',
        name: 'Light',
        type: DeviceType.light,
        isOn: true,
        brightness: 50,
      ),
      DeviceModel(
        id: 't1',
        name: 'Thermo',
        type: DeviceType.thermostat,
        isOn: true,
        temperature: 21,
      ),
    ];

    await repo.saveDevicesForUser(userId, devices);

    final loaded = await repo.getDevicesForUser(userId);
    expect(loaded.length, devices.length);
    expect(loaded.first.id, 'l1');
    expect(loaded[1].type, DeviceType.thermostat);
    expect(loaded[1].temperature, 21.0);
  });
}
