class TelemetryData {
  final String deviceId;
  final int sequence;
  final int timestamp;
  final int uptimeSeconds;
  final double temperatureC;
  final double humidityPercent;
  final int mq135Raw;
  final int mq135AdcMv;
  final double mq135SensorMv;
  final String airQualityStatus;
  final bool isGasPolluted;
  final int rainRaw;
  final String rainStatus;
  final bool isRaining;
  final double waterDistanceCm;
  final double waterLevelCm;
  final String floodStatus;
  final bool isFloodWarning;
  final int wifiRssiDbm;
  final bool relay1;
  final bool relay2;
  final bool relay3;
  final bool relay4;
  final DateTime receivedAt;

  TelemetryData({
    required this.deviceId,
    required this.sequence,
    required this.timestamp,
    required this.uptimeSeconds,
    required this.temperatureC,
    required this.humidityPercent,
    required this.mq135Raw,
    required this.mq135AdcMv,
    required this.mq135SensorMv,
    required this.airQualityStatus,
    required this.isGasPolluted,
    required this.rainRaw,
    required this.rainStatus,
    required this.isRaining,
    required this.waterDistanceCm,
    required this.waterLevelCm,
    required this.floodStatus,
    required this.isFloodWarning,
    required this.wifiRssiDbm,
    this.relay1 = false,
    this.relay2 = false,
    this.relay3 = false,
    this.relay4 = false,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  /// Parse double safely from num, String, or null
  static double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) {
      final parsed = double.tryParse(val);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  /// Parse int safely from num, String, or null
  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) {
      final parsed = int.tryParse(val);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  /// Parse bool safely from bool, num, String, or null
  static bool _parseBool(dynamic val, [bool fallback = false]) {
    if (val == null) return fallback;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.toLowerCase().trim();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return fallback;
  }

  /// Safe JSON parser resilient to missing fields, nulls, and type mismatches
  factory TelemetryData.fromJson(Map<String, dynamic> json, {String? defaultDeviceId}) {
    final devId = json['device_id']?.toString() ??
        json['deviceId']?.toString() ??
        defaultDeviceId ??
        'ESP32-UNKNOWN';

    final temp = _parseDouble(json['temperature_c'] ?? json['temperature']);
    final hum = _parseDouble(json['humidity_percent'] ?? json['humidity']);

    final mqRaw = _parseInt(json['mq135_raw']);
    final mqAdc = _parseInt(json['mq135_adc_mv']);
    final mqSensor = _parseDouble(json['mq135_sensor_mv']);

    // Kalibrasi cerdas ambang batas kualitas udara MQ-135:
    // Standar ambang batas:
    // < 800 (atau sensor < 1000 mV) : Normal / Baik (is_gas_polluted: false)
    // 800 - 1500                    : Udara Sedang  (is_gas_polluted: false)
    // > 1500 (atau sensor > 1800 mV): Tercemar / Bahaya Gas (is_gas_polluted: true)
    String airStatus = json['air_quality_status']?.toString() ?? 'Normal / Baik';
    bool gasPolluted = _parseBool(json['is_gas_polluted']);

    if (mqRaw > 0 || mqSensor > 0) {
      if (mqRaw > 1500 || mqSensor > 1800.0) {
        airStatus = 'Tercemar / Bahaya';
        gasPolluted = true;
      } else if (mqRaw >= 800 || mqSensor >= 1000.0) {
        airStatus = 'Udara Sedang';
        gasPolluted = false;
      } else {
        airStatus = 'Normal / Baik';
        gasPolluted = false;
      }
    }

    final rainRawVal = _parseInt(json['rain_raw']);
    final rainStat = json['rain_status']?.toString() ?? 'Tidak Hujan';
    final raining = _parseBool(json['is_raining']);

    // Water distance / level
    final waterDist = _parseDouble(json['water_distance_cm'] ?? json['distance_cm'] ?? json['jarak']);
    final waterLvl = _parseDouble(json['water_level_cm'] ?? json['water_level']);
    final floodStat = json['flood_status']?.toString() ?? 'Aman';
    final floodWarn = _parseBool(json['is_flood_warning']);

    final seq = _parseInt(json['sequence']);
    final ts = _parseInt(json['timestamp']);
    final uptime = _parseInt(json['uptime_s'] ?? json['uptime']);
    final rssi = _parseInt(json['wifi_rssi_dbm'] ?? json['rssi'], -70);

    // Parse Live Relay Status (ESP32 Smart Lamp Control)
    bool r1 = false;
    bool r2 = false;
    bool r3 = false;
    bool r4 = false;

    if (json.containsKey('relay1') || json.containsKey('relay_1') || json.containsKey('r1')) {
      r1 = _parseBool(json['relay1'] ?? json['relay_1'] ?? json['r1']);
    }
    if (json.containsKey('relay2') || json.containsKey('relay_2') || json.containsKey('r2')) {
      r2 = _parseBool(json['relay2'] ?? json['relay_2'] ?? json['r2']);
    }
    if (json.containsKey('relay3') || json.containsKey('relay_3') || json.containsKey('r3')) {
      r3 = _parseBool(json['relay3'] ?? json['relay_3'] ?? json['r3']);
    }
    if (json.containsKey('relay4') || json.containsKey('relay_4') || json.containsKey('r4')) {
      r4 = _parseBool(json['relay4'] ?? json['relay_4'] ?? json['r4']);
    }

    if (json['relays'] is Map) {
      final rm = json['relays'] as Map;
      if (rm.containsKey('1') || rm.containsKey(1) || rm.containsKey('relay1')) {
        r1 = _parseBool(rm['1'] ?? rm[1] ?? rm['relay1']);
      }
      if (rm.containsKey('2') || rm.containsKey(2) || rm.containsKey('relay2')) {
        r2 = _parseBool(rm['2'] ?? rm[2] ?? rm['relay2']);
      }
      if (rm.containsKey('3') || rm.containsKey(3) || rm.containsKey('relay3')) {
        r3 = _parseBool(rm['3'] ?? rm[3] ?? rm['relay3']);
      }
      if (rm.containsKey('4') || rm.containsKey(4) || rm.containsKey('relay4')) {
        r4 = _parseBool(rm['4'] ?? rm[4] ?? rm['relay4']);
      }
    } else if (json['relays'] is List) {
      final rl = json['relays'] as List;
      if (rl.isNotEmpty) r1 = _parseBool(rl[0]);
      if (rl.length > 1) r2 = _parseBool(rl[1]);
      if (rl.length > 2) r3 = _parseBool(rl[2]);
      if (rl.length > 3) r4 = _parseBool(rl[3]);
    }

    return TelemetryData(
      deviceId: devId,
      sequence: seq,
      timestamp: ts,
      uptimeSeconds: uptime,
      temperatureC: temp,
      humidityPercent: hum,
      mq135Raw: mqRaw,
      mq135AdcMv: mqAdc,
      mq135SensorMv: mqSensor,
      airQualityStatus: airStatus,
      isGasPolluted: gasPolluted,
      rainRaw: rainRawVal,
      rainStatus: rainStat,
      isRaining: raining,
      waterDistanceCm: waterDist,
      waterLevelCm: waterLvl,
      floodStatus: floodStat,
      isFloodWarning: floodWarn,
      wifiRssiDbm: rssi,
      relay1: r1,
      relay2: r2,
      relay3: r3,
      relay4: r4,
      receivedAt: DateTime.now(),
    );
  }

  TelemetryData copyWith({
    String? deviceId,
    int? sequence,
    int? timestamp,
    int? uptimeSeconds,
    double? temperatureC,
    double? humidityPercent,
    int? mq135Raw,
    int? mq135AdcMv,
    double? mq135SensorMv,
    String? airQualityStatus,
    bool? isGasPolluted,
    int? rainRaw,
    String? rainStatus,
    bool? isRaining,
    double? waterDistanceCm,
    double? waterLevelCm,
    String? floodStatus,
    bool? isFloodWarning,
    int? wifiRssiDbm,
    bool? relay1,
    bool? relay2,
    bool? relay3,
    bool? relay4,
    DateTime? receivedAt,
  }) {
    return TelemetryData(
      deviceId: deviceId ?? this.deviceId,
      sequence: sequence ?? this.sequence,
      timestamp: timestamp ?? this.timestamp,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
      temperatureC: temperatureC ?? this.temperatureC,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      mq135Raw: mq135Raw ?? this.mq135Raw,
      mq135AdcMv: mq135AdcMv ?? this.mq135AdcMv,
      mq135SensorMv: mq135SensorMv ?? this.mq135SensorMv,
      airQualityStatus: airQualityStatus ?? this.airQualityStatus,
      isGasPolluted: isGasPolluted ?? this.isGasPolluted,
      rainRaw: rainRaw ?? this.rainRaw,
      rainStatus: rainStatus ?? this.rainStatus,
      isRaining: isRaining ?? this.isRaining,
      waterDistanceCm: waterDistanceCm ?? this.waterDistanceCm,
      waterLevelCm: waterLevelCm ?? this.waterLevelCm,
      floodStatus: floodStatus ?? this.floodStatus,
      isFloodWarning: isFloodWarning ?? this.isFloodWarning,
      wifiRssiDbm: wifiRssiDbm ?? this.wifiRssiDbm,
      relay1: relay1 ?? this.relay1,
      relay2: relay2 ?? this.relay2,
      relay3: relay3 ?? this.relay3,
      relay4: relay4 ?? this.relay4,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'sequence': sequence,
      'timestamp': timestamp,
      'uptime_s': uptimeSeconds,
      'temperature_c': temperatureC,
      'humidity_percent': humidityPercent,
      'mq135_raw': mq135Raw,
      'mq135_adc_mv': mq135AdcMv,
      'mq135_sensor_mv': mq135SensorMv,
      'air_quality_status': airQualityStatus,
      'is_gas_polluted': isGasPolluted,
      'rain_raw': rainRaw,
      'rain_status': rainStatus,
      'is_raining': isRaining,
      'water_distance_cm': waterDistanceCm,
      'water_level_cm': waterLevelCm,
      'flood_status': floodStatus,
      'is_flood_warning': isFloodWarning,
      'wifi_rssi_dbm': wifiRssiDbm,
      'relay1': relay1,
      'relay2': relay2,
      'relay3': relay3,
      'relay4': relay4,
    };
  }
}
