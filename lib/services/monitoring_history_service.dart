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

  static const String _storageKey = 'tegal_smart_monitoring_history_v2';
  static const int maxHourlyRecords = 192; // 8 hari (Hari Ini + 7 hari lalu) x 24 jam

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

      // Jika data masih kosong atau kurang dari 24 jam, isi data riwayat terstruktur
      if (_records.length < 24) {
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

  /// Ambil 24 titik data riwayat untuk 1 hari tertentu
  /// dayOffset: 0 = Hari Ini, 1 = Kemarin, 2 = 2 Hari Lalu, ..., 7 = 7 Hari Lalu
  List<MonitoringHistoryRecord> getRecordsForDayOffset(int dayOffset) {
    if (_records.isEmpty) return [];
    final now = DateTime.now();
    final targetDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: dayOffset));

    final filtered = _records.where((r) {
      return r.timestamp.year == targetDate.year &&
             r.timestamp.month == targetDate.month &&
             r.timestamp.day == targetDate.day;
    }).toList();

    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (filtered.isNotEmpty) {
      return filtered;
    }

    // Fallback: jika tanggal exact belum ada, ambil jendela 24 data sesuai offset
    final startIdx = max(0, _records.length - ((dayOffset + 1) * 24));
    final endIdx = min(_records.length, startIdx + 24);
    if (startIdx < endIdx) {
      final sub = _records.sublist(startIdx, endIdx);
      sub.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return sub;
    }
    return _records.length <= 24 ? _records : _records.sublist(_records.length - 24);
  }

  /// Ambil data riwayat berdasarkan rentang hari (untuk backwards compatibility)
  List<MonitoringHistoryRecord> getRecordsForDays(int days) {
    return getRecordsForDayOffset(days <= 1 ? 0 : days - 1);
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

  /// Hapus data yang usianya lebih dari 8 hari atau melebihi 192 data (FIFO)
  void _pruneOldRecords() {
    final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
    _records.removeWhere((r) => r.timestamp.isBefore(eightDaysAgo));
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

  /// Mengisi data simulasi realistis untuk 8 hari (Hari Ini + 7 hari ke belakang, masing-masing 24 jam)
  void _seedRealistic7DaysHistory() {
    _records.clear();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final rng = Random(42);

    for (int dayOffset = 7; dayOffset >= 0; dayOffset--) {
      final dayDate = todayStart.subtract(Duration(days: dayOffset));
      for (int hour = 0; hour < 24; hour++) {
        final time = DateTime(dayDate.year, dayDate.month, dayDate.day, hour);

        // Suhu: 25-27°C malam, 30-33°C siang
        double baseTemp = 28.5 + (sin((hour - 9) * pi / 12) * 3.5);
        double temp = baseTemp + (rng.nextDouble() * 0.8 - 0.4);

        // Kelembaban: 60-88%
        double baseHum = 75.0 - (sin((hour - 9) * pi / 12) * 12.0);
        double hum = (baseHum + (rng.nextDouble() * 2.0 - 1.0)).clamp(50.0, 95.0);

        // Ketinggian genangan air: 8-14 cm
        double water = 9.0 + (rng.nextDouble() * 4.0);
        bool raining = false;
        // Hujan di sore hari pada hari-hari tertentu
        if ((hour >= 15 && hour <= 18) && ((dayOffset + hour) % 3 == 0) && rng.nextDouble() > 0.35) {
          raining = true;
          water += 4.5 + rng.nextDouble() * 3.5;
        }

        String floodStatus;
        if (water < 20.0) {
          floodStatus = 'Aman';
        } else if (water < 35.0) {
          floodStatus = 'Waspada';
        } else {
          floodStatus = 'Siaga';
        }

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
  }

  /// Reset dan perbarui sampel histori data
  Future<void> resetToSampleData() async {
    _seedRealistic7DaysHistory();
    await _persist();
    notifyListeners();
  }
}
