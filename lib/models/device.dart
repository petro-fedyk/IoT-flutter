enum DeviceType { light, thermostat, airConditioner, lock, camera, other }

class DeviceModel {
  final String id;
  String name;
  final DeviceType type;
  bool isOn;
  int brightness; // 0-100 for lights
  double temperature; // for thermostat / AC

  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.brightness = 100,
    this.temperature = 22.0,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: DeviceType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => DeviceType.other,
      ),
      isOn: json['isOn'] as bool? ?? false,
      brightness: json['brightness'] as int? ?? 100,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 22.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.toString(),
    'isOn': isOn,
    'brightness': brightness,
    'temperature': temperature,
  };
}
