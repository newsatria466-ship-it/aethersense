import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/monitoring_history_model.dart';
import '../models/telemetry_data.dart';

class MonitoringHistoryService extends ChangeNotifier {
  static final MonitoringHistoryService _instance = MonitoringHistoryService._internal();
  static MonitoringHistoryService get instance => _instance;

  MonitoringHistoryService._internal();

  static const String _storageKey = 'tegal_smart_monitoring_history_v1';
  static const int maxHourlyRecords = 168; // 7 hari x 24 jam

  final List<MonitoringHistoryRecord> _records = [];
  bool _isInitialized = false;

  List<MonitoringHistoryRecord> get records => List.unmodifiable(_records);
  bool get isInitialized => _isInitialized;

  /// Inisialisasi service: membaca dari SharedPreferences, atau isi sampel jika kosong
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        _records.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _records.add(MonitoringHistoryRecord.fromJson(item));
          }
        }
      }

      // Jika data masih kosong atau kurang dari 24 jam (misal baru pertama dipasang),
      // kita isi dengan data riwayat 7 hari terakhir yang realistis
      if (_records.isEmpty) {
        _seedRealistic7DaysHistory();
        await _persist();
      }
    } catch (e) {
      debugPrint('[HistoryService] Error loading history: $e');
      if (_records.isEmpty) {
        _seedRealistic7DaysHistory();
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Ambil data riwayat berdasarkan jumlah hari (1 s/d 7 hari kalender)
  List<MonitoringHistoryRecord> getRecordsForDays(int days) {
    if (_records.isEmpty) return [];
    final now = DateTime.now();
    // Awal hari dari rentang (00:00:00 pada days-1 hari yang lalu)
    final startOfRange = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    final filtered = _records.where((r) => !r.timestamp.isBefore(startOfRange)).toList();
    // Urutkan kronologis dari paling lampau ke paling baru
    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (filtered.isNotEmpty) {
      return filtered;
    }
    // Fallback
    final cutoff = now.subtract(Duration(days: days));
    final alt = _records.where((r) => r.timestamp.isAfter(cutoff)).toList();
    alt.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return alt.isNotEmpty ? alt : _records;
  }

  /// Rekam data live telemetri setiap jam baru
  Future<void> recordSnapshot(TelemetryData telemetry) async {
    final now = DateTime.now();

    final newRecord = MonitoringHistoryRecord(
      timestamp: now,
      waterLevelCm: telemetry.waterLevelCm,
      floodStatus: telemetry.floodStatus,
      temperatureC: telemetry.temperatureC,
      humidityPercent: telemetry.humidityPercent,
      mq135Raw: telemetry.mq135Raw,
      airQualityStatus: telemetry.airQualityStatus,
      isRaining: telemetry.isRaining,
    );

    if (_records.isNotEmpty) {
      final last = _records.last.timestamp;
      // Jika masih dalam jam dan hari yang sama, perbarui titik jam ini
      if (last.year == now.year &&
          last.month == now.month &&
          last.day == now.day &&
          last.hour == now.hour) {
        _records[_records.length - 1] = newRecord;
      } else {
        // Sudah ganti jam, tambahkan data jam baru
        _records.add(newRecord);
      }
    } else {
      _records.add(newRecord);
    }

    _pruneOldRecords();
    await _persist();
    notifyListeners();
  }

  /// Hapus data yang usianya lebih dari 7 hari atau melebihi 168 data (FIFO)
  void _pruneOldRecords() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    _records.removeWhere((r) => r.timestamp.isBefore(sevenDaysAgo));
    if (_records.length > maxHourlyRecords) {
      _records.removeRange(0, _records.length - maxHourlyRecords);
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_records.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('[HistoryService] Error saving history: $e');
    }
  }

  /// Mengisi data simulasi realistis 7 hari (168 titik jam)
  void _seedRealistic7DaysHistory() {
    _records.clear();
    final now = DateTime.now();
    final rng = Random(42); // seed konsisten

    // 168 jam ke belakang
    for (int i = 167; i >= 0; i--) {
      final time = now.subtract(Duration(hours: i));
      final hour = time.hour;

      // Suhu: lebih dingin malam/dini hari (25-27°C), lebih hangat siang (30-33°C)
      double baseTemp = 28.5 + (sin((hour - 9) * pi / 12) * 3.5);
      double temp = baseTemp + (rng.nextDouble() * 0.8 - 0.4);

      // Kelembaban: berbanding terbalik dengan suhu (60-88%)
      double baseHum = 75.0 - (sin((hour - 9) * pi / 12) * 12.0);
      double hum = (baseHum + (rng.nextDouble() * 2.0 - 1.0)).clamp(50.0, 95.0);

      // Ketinggian genangan air: umumnya normal 8-14 cm
      double water = 9.0 + (rng.nextDouble() * 4.0);
      bool raining = false;
      // Sesekali ada hujan ringan di sore/malam hari
      if ((hour >= 15 && hour <= 18) && (i % 24 < 12) && rng.nextDouble() > 0.6) {
        raining = true;
        water += 4.5 + rng.nextDouble() * 3.0; // kenaikan air saat hujan
      }

      String floodStatus;
      if (water < 20.0) {
        floodStatus = 'Aman';
      } else if (water < 35.0) {
        floodStatus = 'Waspada';
      } else {
        floodStatus = 'Siaga';
      }

      // MQ-135 kualitas udara: 250 - 600
      int mqRaw = 300 + (rng.nextInt(250)) + (hour >= 7 && hour <= 17 ? 120 : 0);
      String airStatus;
      if (mqRaw < 350) {
        airStatus = 'Sangat Bersih';
      } else if (mqRaw < 1500) {
        airStatus = 'Normal / Baik';
      } else {
        airStatus = 'Polusi Ringan';
      }

      _records.add(MonitoringHistoryRecord(
        timestamp: time,
        waterLevelCm: double.parse(water.toStringAsFixed(1)),
        floodStatus: floodStatus,
        temperatureC: double.parse(temp.toStringAsFixed(1)),
        humidityPercent: double.parse(hum.toStringAsFixed(1)),
        mq135Raw: mqRaw,
        airQualityStatus: airStatus,
        isRaining: raining,
      ));
    }
  }

  /// Reset dan perbarui sampel histori data
  Future<void> resetToSampleData() async {
    _seedRealistic7DaysHistory();
    await _persist();
    notifyListeners();
  }
}
