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
    final airStatus = json['air_quality_status']?.toString() ?? 'Normal';
    final gasPolluted = _parseBool(json['is_gas_polluted']);

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
      receivedAt: DateTime.now(),
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
    };
  }
}
