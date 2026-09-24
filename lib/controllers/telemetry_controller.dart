import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/telemetry_data.dart';
import '../services/mqtt_service.dart';
import '../utils/formatters.dart';

class TelemetryController extends ChangeNotifier {
  final MqttService _mqttService;

  // Stream Subscriptions
  StreamSubscription<MqttConnectionStateStatus>? _connectionSub;
  StreamSubscription<Map<String, dynamic>>? _telemetrySub;
  StreamSubscription<Map<String, dynamic>>? _statusSub;

  // State
  MqttConnectionStateStatus _connectionStatus = MqttConnectionStateStatus.connecting;
  TelemetryData? _latestTelemetry;
  final Map<String, TelemetryData> _devices = {};
  String? _activeDeviceId;
  String? _parseWarning;
  Timer? _freshnessTimer;

  // Getters
  MqttConnectionStateStatus get connectionStatus => _connectionStatus;
  TelemetryData? get telemetry => _latestTelemetry;
  Map<String, TelemetryData> get devices => Map.unmodifiable(_devices);
  String? get activeDeviceId => _activeDeviceId ?? _latestTelemetry?.deviceId;
  bool get hasData => _latestTelemetry != null;
  String? get parseWarning => _parseWarning;

  // Freshness
  String get freshnessText => AetherFormatters.formatFreshness(_latestTelemetry?.receivedAt);
  bool get isTelemetryDelayed => AetherFormatters.isDelayed(_latestTelemetry?.receivedAt);

  TelemetryController({MqttService? mqttService})
      : _mqttService = mqttService ?? MqttService() {
    _initSubscriptions();
    _startFreshnessTimer();
  }

  void _initSubscriptions() {
    _connectionStatus = _mqttService.state;

    _connectionSub = _mqttService.connectionStateStream.listen((status) {
      _connectionStatus = status;
      notifyListeners();
    });

    _telemetrySub = _mqttService.telemetryPayloadStream.listen(_handleIncomingTelemetry);
    _statusSub = _mqttService.deviceStatusStream.listen(_handleIncomingDeviceStatus);
  }

  void _handleIncomingTelemetry(Map<String, dynamic> json) {
    try {
      final telemetryData = TelemetryData.fromJson(json);

      // Track by device_id
      _devices[telemetryData.deviceId] = telemetryData;

      // Update latest / active device
      if (_activeDeviceId == null || _activeDeviceId == telemetryData.deviceId) {
        _latestTelemetry = telemetryData;
        _activeDeviceId = telemetryData.deviceId;
      } else {
        // If a new device arrives, we still keep latestTelemetry updated if not explicitly locked
        _latestTelemetry = telemetryData;
        _activeDeviceId = telemetryData.deviceId;
      }

      _parseWarning = null;
      if (kDebugMode) {
        print('[AetherSense][MQTT] Device: ${telemetryData.deviceId}');
        print('[AetherSense][MQTT] Telemetry updated. Seq: #${telemetryData.sequence}, Flood: ${telemetryData.floodStatus}, Water: ${telemetryData.waterLevelCm}cm');
      }

      notifyListeners();
    } catch (e) {
      _parseWarning = 'Failed to parse incoming packet: $e';
      if (kDebugMode) {
        print('[AetherSense][JSON][ERROR] Invalid telemetry payload: $e. Last valid data retained.');
      }
      // Last valid telemetry data retained!
      notifyListeners();
    }
  }

  void _handleIncomingDeviceStatus(Map<String, dynamic> json) {
    // Optional status packet handler (online/offline heartbeat)
    final deviceId = json['device_id']?.toString();
    final status = json['status']?.toString();
    if (kDebugMode) {
      print('[AetherSense][MQTT] Device Status -> $deviceId : $status');
    }
    notifyListeners();
  }

  void _startFreshnessTimer() {
    _freshnessTimer?.cancel();
    _freshnessTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_latestTelemetry != null) {
        notifyListeners();
      }
    });
  }

  /// Switch active device view if multiple devices exist
  void selectDevice(String deviceId) {
    if (_devices.containsKey(deviceId)) {
      _activeDeviceId = deviceId;
      _latestTelemetry = _devices[deviceId];
      notifyListeners();
    }
  }

  /// Manually retry MQTT connection
  Future<void> retryConnection() async {
    await _mqttService.reconnect();
  }

  @override
  void dispose() {
    _freshnessTimer?.cancel();
    _connectionSub?.cancel();
    _telemetrySub?.cancel();
    _statusSub?.cancel();
    _mqttService.dispose();
    super.dispose();
  }
}
