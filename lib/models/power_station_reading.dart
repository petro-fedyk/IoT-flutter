class PowerStationReading {
  final double temperature;
  final double voltage;
  final double current;
  final double power;
  final int battery;
  final bool alarm;

  const PowerStationReading({
    required this.temperature,
    required this.voltage,
    required this.current,
    required this.power,
    required this.battery,
    required this.alarm,
  });

  factory PowerStationReading.fromJson(Map<String, dynamic> json) {
    return PowerStationReading(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      voltage: (json['voltage'] as num?)?.toDouble() ?? 0,
      current: (json['current'] as num?)?.toDouble() ?? 0,
      power: (json['power'] as num?)?.toDouble() ?? 0,
      battery: (json['battery'] as num?)?.toInt() ?? 0,
      alarm: json['alarm'] as bool? ?? false,
    );
  }
}
