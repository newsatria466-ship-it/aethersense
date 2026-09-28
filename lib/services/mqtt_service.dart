import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../utils/constants.dart';

enum MqttConnectionStateStatus {
  connecting,
  connected,
  disconnected,
  reconnecting,
  error,
}

class MqttService {
  MqttServerClient? _client;
  MqttConnectionStateStatus _state = MqttConnectionStateStatus.disconnected;
  String? _lastError;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  bool _isExplicitlyDisconnected = false;

  // Stream Controllers
  final _connectionStateController =
      StreamController<MqttConnectionStateStatus>.broadcast();
  final _telemetryPayloadController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _deviceStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<MqttConnectionStateStatus> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<Map<String, dynamic>> get telemetryPayloadStream =>
      _telemetryPayloadController.stream;
  Stream<Map<String, dynamic>> get deviceStatusStream =>
      _deviceStatusController.stream;

  MqttConnectionStateStatus get state => _state;
  String? get lastError => _lastError;

  MqttService({bool autoConnect = true}) {
    if (autoConnect) {
      _initAndConnect();
    }
  }

  /// Generate unique client ID: AetherApp-XXXXXX
  static String _generateClientId() {
    final random = Random();
    const chars = '0123456789ABCDEF';
    final hex = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    return 'AetherApp-$hex';
  }

  Future<void> _initAndConnect() async {
    if (_isDisposed) return;
    if (_state == MqttConnectionStateStatus.connecting ||
        _state == MqttConnectionStateStatus.connected) {
      return;
    }

    _updateState(MqttConnectionStateStatus.connecting);
    _lastError = null;

    final clientId = _generateClientId();
    if (kDebugMode) {
      print('[AetherSense][MQTT] Initializing client: $clientId');
      print('[AetherSense][MQTT] Broker: ${AetherConstants.brokerHost}:${AetherConstants.brokerPort}');
    }

    // Try WebSocket WSS first as it is 100% immune to mobile carrier ISP firewall blocking on Android
    // HiveMQ automatically bridges TCP 1883 and WSS 8884 on identical topics
    _client = MqttServerClient.withPort(
      AetherConstants.wsUrl,
      clientId,
      AetherConstants.brokerWsPort,
    );

    _client!.useWebSocket = true;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;

    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onAutoReconnect = _onAutoReconnect;
    _client!.onAutoReconnected = _onAutoReconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    _client!.connectionMessage = connMessage;

    try {
      if (kDebugMode) {
        print('[AetherSense][MQTT] Connecting...');
      }
      final status = await _client!.connect();
      if (status?.state == MqttConnectionState.connected) {
        _onConnected();
      } else {
        _handleConnectionFailure('Connect status: ${status?.state}');
      }
    } on SocketException catch (e) {
      _handleConnectionFailure('Socket exception: $e');
    } catch (e) {
      _handleConnectionFailure('Connection error: $e');
    }
  }

  void _onConnected() {
    if (_isDisposed) return;
    if (kDebugMode) {
      print('[AetherSense][MQTT] Connected');
    }
    _reconnectTimer?.cancel();
    _updateState(MqttConnectionStateStatus.connected);

    // Subscribe with wildcard: aethersense/+/telemetry and aethersense/+/status
    _subscribeTopics();
  }

  void _subscribeTopics() {
    if (_client == null ||
        _client!.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    if (kDebugMode) {
      print('[AetherSense][MQTT] Subscribing to: ${AetherConstants.telemetryTopic}');
      print('[AetherSense][MQTT] Subscribing to: ${AetherConstants.statusTopic}');
    }

    _client!.subscribe(AetherConstants.telemetryTopic, MqttQos.atLeastOnce);
    _client!.subscribe(AetherConstants.statusTopic, MqttQos.atLeastOnce);

    _client!.updates?.listen(_onMqttMessageReceived, onError: (e) {
      if (kDebugMode) {
        print('[AetherSense][MQTT][ERROR] Message listener error: $e');
      }
    });
  }

  void _onMqttMessageReceived(List<MqttReceivedMessage<MqttMessage>>? messages) {
    if (messages == null || messages.isEmpty || _isDisposed) return;

    final recMess = messages[0].payload as MqttPublishMessage;
    final topic = messages[0].topic;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    if (kDebugMode) {
      print('[AetherSense][MQTT] Message received on topic: $topic');
    }

    _handleIncomingPayload(topic, payload);
  }

  void _handleIncomingPayload(String topic, String payload) {
    try {
      final dynamic decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        if (kDebugMode) {
          print('[AetherSense][JSON][ERROR] Payload is not a JSON object: $payload');
        }
        return;
      }

      // Extract device_id from topic if not present in JSON
      // Topic structure: aethersense/{deviceId}/telemetry
      String? topicDeviceId;
      final segments = topic.split('/');
      if (segments.length >= 2) {
        topicDeviceId = segments[1];
      }

      final Map<String, dynamic> enrichedData = Map.from(decoded);
      if (!enrichedData.containsKey('device_id') && topicDeviceId != null) {
        enrichedData['device_id'] = topicDeviceId;
      }

      if (topic.endsWith('/telemetry')) {
        _telemetryPayloadController.add(enrichedData);
      } else if (topic.endsWith('/status')) {
        _deviceStatusController.add(enrichedData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AetherSense][JSON][ERROR] Failed to parse payload: $e');
      }
    }
  }

  void _onDisconnected() {
    if (_isDisposed) return;
    if (_isExplicitlyDisconnected) return;
    if (kDebugMode) {
      print('[AetherSense][MQTT] Disconnected from broker');
    }
    _handleConnectionFailure('Disconnected from broker');
  }

  void _onAutoReconnect() {
    if (_isDisposed) return;
    if (kDebugMode) {
      print('[AetherSense][MQTT] Auto-reconnecting in progress...');
    }
    _updateState(MqttConnectionStateStatus.reconnecting);
  }

  void _onAutoReconnected() {
    if (_isDisposed) return;
    if (kDebugMode) {
      print('[AetherSense][MQTT] Auto-reconnect successful!');
    }
    _updateState(MqttConnectionStateStatus.connected);
    _subscribeTopics();
  }

  void _handleConnectionFailure(String reason) {
    _lastError = reason;
    if (kDebugMode) {
      print('[AetherSense][MQTT][ERROR] $reason');
    }
    _updateState(MqttConnectionStateStatus.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed || _isExplicitlyDisconnected) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (!_isDisposed &&
          _state != MqttConnectionStateStatus.connected &&
          !_isExplicitlyDisconnected) {
        if (kDebugMode) {
          print('[AetherSense][MQTT] Attempting scheduled reconnect...');
        }
        _initAndConnect();
      }
    });
  }

  void _updateState(MqttConnectionStateStatus newState) {
    if (_state == newState) return;
    _state = newState;
    _connectionStateController.add(newState);
  }

  /// Publish a payload string to an MQTT topic
  bool publish(
    String topic,
    String payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    if (_client == null || _state != MqttConnectionStateStatus.connected) {
      if (kDebugMode) {
        print('[AetherSense][MQTT][WARN] Cannot publish, client not connected (State: $_state).');
      }
      return false;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
      if (kDebugMode) {
        print('[AetherSense][MQTT] Published to [$topic]: $payload');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[AetherSense][MQTT][ERROR] Publish failed: $e');
      }
      return false;
    }
  }

  /// Manual reconnect trigger from UI
  Future<void> reconnect() async {
    _isExplicitlyDisconnected = false;
    _reconnectTimer?.cancel();
    _client?.disconnect();
    await _initAndConnect();
  }

  void disconnect() {
    _isExplicitlyDisconnected = true;
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _updateState(MqttConnectionStateStatus.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _connectionStateController.close();
    _telemetryPayloadController.close();
    _deviceStatusController.close();
  }
}
