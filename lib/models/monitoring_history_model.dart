/// Model data untuk satu snapshot rekap per jam Smart Monitoring
class MonitoringHistoryRecord {
  final DateTime timestamp;
  final double waterLevelCm;
  final String floodStatus;
  final double temperatureC;
  final double humidityPercent;
  final int mq135Raw;
  final String airQualityStatus;
  final bool isRaining;

  MonitoringHistoryRecord({
    required this.timestamp,
    required this.waterLevelCm,
    required this.floodStatus,
    required this.temperatureC,
    required this.humidityPercent,
    required this.mq135Raw,
    required this.airQualityStatus,
    required this.isRaining,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'water_level_cm': waterLevelCm,
        'flood_status': floodStatus,
        'temperature_c': temperatureC,
        'humidity_percent': humidityPercent,
        'mq135_raw': mq135Raw,
        'air_quality_status': airQualityStatus,
        'is_raining': isRaining,
      };

  factory MonitoringHistoryRecord.fromJson(Map<String, dynamic> json) {
    return MonitoringHistoryRecord(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      waterLevelCm: (json['water_level_cm'] as num?)?.toDouble() ?? 0.0,
      floodStatus: json['flood_status']?.toString() ?? 'Aman',
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 28.0,
      humidityPercent: (json['humidity_percent'] as num?)?.toDouble() ?? 70.0,
      mq135Raw: (json['mq135_raw'] as num?)?.toInt() ?? 300,
      airQualityStatus: json['air_quality_status']?.toString() ?? 'Normal',
      isRaining: json['is_raining'] == true,
    );
  }
}
