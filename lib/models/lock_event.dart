class LockEvent {
  final int id;
  final DateTime time;
  final String unlockMethod;
  final bool isSuccess;
  final String user;

  const LockEvent({
    required this.id,
    required this.time,
    required this.unlockMethod,
    required this.isSuccess,
    required this.user,
  });

  factory LockEvent.fromJson(Map<String, dynamic> json) {
    return LockEvent(
      id: json['id'] as int,
      time: DateTime.parse(json['time'] as String),
      unlockMethod: json['unlockMethod'] as String,
      isSuccess: json['isSuccess'] as bool,
      user: json['user'] as String,
    );
  }
}
