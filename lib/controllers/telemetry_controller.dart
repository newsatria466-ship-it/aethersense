import 'dart:async';
import 'dart:convert';
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

  // Smart Lamp Relay & LDR States
  bool _relay1 = false;
  bool _relay2 = false;
  bool _relay3 = false;
  bool _relay4 = false;
  String _lightingMode = 'auto'; // 'auto' (LDR) or 'manual' (Operator)
  bool _isPendingModeChange = false;
  final Set<dynamic> _pendingRelays = {};

  // Getters
  MqttConnectionStateStatus get connectionStatus => _connectionStatus;
  TelemetryData? get telemetry => _latestTelemetry;
  Map<String, TelemetryData> get devices => Map.unmodifiable(_devices);
  String? get activeDeviceId => _activeDeviceId ?? _latestTelemetry?.deviceId;
  bool get hasData => _latestTelemetry != null;
  String? get parseWarning => _parseWarning;

  // Relay Getters
  bool get relay1 => _latestTelemetry?.relay1 ?? _relay1;
  bool get relay2 => _latestTelemetry?.relay2 ?? _relay2;
  bool get relay3 => _latestTelemetry?.relay3 ?? _relay3;
  bool get relay4 => _latestTelemetry?.relay4 ?? _relay4;

  bool isRelayPending(dynamic relay) =>
      _pendingRelays.contains(relay) || _pendingRelays.contains('all');

  int get activeRelayCount {
    int count = 0;
    if (relay1) count++;
    if (relay2) count++;
    if (relay3) count++;
    if (relay4) count++;
    return count;
  }

  // LDR & Lighting Mode Getters
  String get lightingMode => _latestTelemetry?.lightingMode ?? _lightingMode;
  bool get isAutoMode => lightingMode == 'auto';
  int get ldrRaw => _latestTelemetry?.ldrRaw ?? 0;
  String get ambientLight => _latestTelemetry?.ambientLight ?? 'Terang';
  bool get isDark => _latestTelemetry?.isDark ?? false;
  bool get isPendingModeChange => _isPendingModeChange;

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
      // Sync relay states and lighting mode from telemetry
      _relay1 = telemetryData.relay1;
      _relay2 = telemetryData.relay2;
      _relay3 = telemetryData.relay3;
      _relay4 = telemetryData.relay4;
      _lightingMode = telemetryData.lightingMode;
      _pendingRelays.clear();
      _isPendingModeChange = false;

      if (kDebugMode) {
        print('[AetherSense][MQTT] Device: ${telemetryData.deviceId}');
        print('[AetherSense][MQTT] Telemetry updated. Seq: #${telemetryData.sequence}, Flood: ${telemetryData.floodStatus}, Water: ${telemetryData.waterLevelCm}cm');
        print('[AetherSense][MQTT] Relays -> R1: ${telemetryData.relay1}, R2: ${telemetryData.relay2}, R3: ${telemetryData.relay3}, R4: ${telemetryData.relay4}');
        print('[AetherSense][MQTT] LDR -> Raw: ${telemetryData.ldrRaw}, Ambient: ${telemetryData.ambientLight}, Mode: ${telemetryData.lightingMode}');
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

  /// Change lighting mode on ESP32:
  /// 'auto' (Otomatis LDR) vs 'manual' (Manual Operator)
  /// JSON: {"type": "lighting_mode", "mode": "auto" | "manual"}
  Future<bool> setLightingMode(String mode) async {
    if (_connectionStatus != MqttConnectionStateStatus.connected) {
      if (kDebugMode) {
        print('[AetherSense][CMD] Cannot change lighting mode, MQTT broker disconnected.');
      }
      return false;
    }

    final targetMode = mode.toLowerCase().trim() == 'manual' ? 'manual' : 'auto';
    _isPendingModeChange = true;
    _lightingMode = targetMode;
    if (_latestTelemetry != null) {
      _latestTelemetry = _latestTelemetry!.copyWith(lightingMode: targetMode);
    }
    notifyListeners();

    final payloadMap = {
      'type': 'lighting_mode',
      'mode': targetMode,
    };
    final payloadJson = jsonEncode(payloadMap);

    final devId = activeDeviceId;
    bool success = false;
    if (devId != null && devId.isNotEmpty && !devId.contains('UNKNOWN')) {
      final topic = 'aethersense/$devId/command';
      success = _mqttService.publish(topic, payloadJson);
      _mqttService.publish('aethersense/command', payloadJson);
    } else {
      success = _mqttService.publish('aethersense/command', payloadJson);
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_isPendingModeChange) {
        _isPendingModeChange = false;
        notifyListeners();
      }
    });

    return success;
  }

  /// Send relay command to ESP32:
  /// relay: 1, 2, 3, 4, or 'all'
  /// state: true (ON) or false (OFF)
  Future<bool> sendRelayCommand({
    required dynamic relay,
    required bool state,
  }) async {
    if (_connectionStatus != MqttConnectionStateStatus.connected) {
      if (kDebugMode) {
        print('[AetherSense][CMD] Cannot send command, MQTT broker disconnected.');
      }
      return false;
    }

    _pendingRelays.add(relay);

    // Manual action switches lighting mode to 'manual' on ESP32
    _lightingMode = 'manual';

    // Optimistic state update for instant UI feedback
    if (relay == 'all') {
      _relay1 = state;
      _relay2 = state;
      _relay3 = state;
      _relay4 = state;
      if (_latestTelemetry != null) {
        _latestTelemetry = _latestTelemetry!.copyWith(
          relay1: state,
          relay2: state,
          relay3: state,
          relay4: state,
          lightingMode: 'manual',
        );
      }
    } else if (relay == 1) {
      _relay1 = state;
      if (_latestTelemetry != null) {
        _latestTelemetry = _latestTelemetry!.copyWith(relay1: state, lightingMode: 'manual');
      }
    } else if (relay == 2) {
      _relay2 = state;
      if (_latestTelemetry != null) {
        _latestTelemetry = _latestTelemetry!.copyWith(relay2: state, lightingMode: 'manual');
      }
    } else if (relay == 3) {
      _relay3 = state;
      if (_latestTelemetry != null) {
        _latestTelemetry = _latestTelemetry!.copyWith(relay3: state, lightingMode: 'manual');
      }
    } else if (relay == 4) {
      _relay4 = state;
      if (_latestTelemetry != null) {
        _latestTelemetry = _latestTelemetry!.copyWith(relay4: state, lightingMode: 'manual');
      }
    }
    notifyListeners();

    // Prepare JSON payload: {"relay": 1, "state": true} or {"relay": "all", "state": true}
    final payloadMap = {
      'relay': relay,
      'state': state,
    };
    final payloadJson = jsonEncode(payloadMap);

    final devId = activeDeviceId;
    bool success = false;
    if (devId != null && devId.isNotEmpty && !devId.contains('UNKNOWN')) {
      final topic = 'aethersense/$devId/command';
      success = _mqttService.publish(topic, payloadJson);
      // Fallback broadcast
      _mqttService.publish('aethersense/command', payloadJson);
    } else {
      success = _mqttService.publish('aethersense/command', payloadJson);
    }

    // Auto-clear pending state after 1.5 seconds if telemetry hasn't arrived
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_pendingRelays.remove(relay)) {
        notifyListeners();
      }
    });

    return success;
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
