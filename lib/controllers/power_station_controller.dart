import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lab1/models/power_station_reading.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class PowerStationController extends ChangeNotifier {
  PowerStationController({
    required String brokerHost,
    required String topic,
    String clientId = 'flutter_power_station',
  }) : _brokerHost = brokerHost,
       _topic = topic,
       _clientId = clientId {
    _client = MqttServerClient(_brokerHost, _clientId);
  }
  final String _brokerHost;
  final String _topic;
  final String _clientId;
  late final MqttServerClient _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _sub;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _status = 'Disconnected';
  PowerStationReading? _lastReading;
  bool _isOnline = true;
  bool _initialized = false;
  bool? _lastOnline;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String get status => _status;
  PowerStationReading? get lastReading => _lastReading;
  bool get isOnline => _isOnline;
  void ensureConnected(bool isOnline) {
    if (!_initialized) {
      _initialized = true;
      _lastOnline = isOnline;
      setOnline(isOnline);
      connect();
      return;
    }
    if (_lastOnline != isOnline) {
      _lastOnline = isOnline;
      setOnline(isOnline);
    }
  }

  void setOnline(bool isOnline) {
    if (_isOnline == isOnline) return;
    _isOnline = isOnline;
    if (!isOnline) {
      disconnect();
      _status = 'Offline (MQTT disabled)';
      notifyListeners();
    } else {
      _status = _isConnected ? 'Connected' : 'Disconnected';
      notifyListeners();
    }
  }

  Future<void> connect() async {
    if (!_isOnline) {
      _status = 'Offline (MQTT disabled)';
      notifyListeners();
      return;
    }
    if (_isConnecting || _isConnected) return;
    _isConnecting = true;
    _status = 'Connecting...';
    notifyListeners();
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.logging(on: false);
    _client.onConnected = _handleConnected;
    _client.onDisconnected = _handleDisconnected;
    final message = MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = message;
    try {
      await _client.connect();
    } catch (e) {
      _status = 'Connection failed: $e';
      _isConnecting = false;
      notifyListeners();
      _client.disconnect();
      return;
    }
    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      _status = 'Failed to connect';
      _isConnecting = false;
      notifyListeners();
      _client.disconnect();
      return;
    }
    _client.subscribe(_topic, MqttQos.atMostOnce);
    _sub = _client.updates?.listen(_handleMessage);
    _isConnecting = false;
    _isConnected = true;
    _status = 'Connected';
    notifyListeners();
  }

  void disconnect() {
    _sub?.cancel();
    _sub = null;
    _client.disconnect();
    _isConnected = false;
    _isConnecting = false;
    _status = 'Disconnected';
    notifyListeners();
  }

  void _handleConnected() {
    _isConnected = true;
    _status = 'Connected';
    notifyListeners();
  }

  void _handleDisconnected() {
    _isConnected = false;
    _isConnecting = false;
    _status = 'Disconnected';
    notifyListeners();
  }

  void _handleMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    if (messages.isEmpty) return;
    final rec = messages.first.payload;
    if (rec is! MqttPublishMessage) return;
    final payload = MqttPublishPayload.bytesToStringAsString(
      rec.payload.message,
    );
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      _lastReading = PowerStationReading.fromJson(json);
      notifyListeners();
    } catch (_) {
      _status = 'Invalid payload';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _client.disconnect();
    super.dispose();
  }
}
