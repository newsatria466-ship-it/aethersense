import 'package:flutter/material.dart';
import 'constants.dart';

class AetherFormatters {
  /// Format seconds into readable uptime: "1h 24m 31s", "42s", or "5h 12m"
  static String formatUptime(int seconds) {
    if (seconds <= 0) return '0s';
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Categorize Wi-Fi RSSI without changing the original dBm value
  /// Excellent: >= -50, Good: -51 to -65, Fair: -66 to -80, Weak: < -80
  static String getRssiQuality(int rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -65) return 'Good';
    if (rssi >= -80) return 'Fair';
    return 'Weak';
  }

  /// Get status color for Wi-Fi RSSI
  static Color getRssiColor(int rssi) {
    if (rssi >= -65) return AetherConstants.statusGreen;
    if (rssi >= -80) return AetherConstants.statusYellow;
    return AetherConstants.statusRed;
  }

  /// Map flood status string to color
  /// Aman → Hijau, Waspada → Kuning, Siaga → Oranye, Bahaya Banjir → Merah
  static Color getFloodStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('bahaya') || s.contains('danger') || s.contains('kritis')) {
      return AetherConstants.statusRed;
    }
    if (s.contains('siaga') || s.contains('alert') || s.contains('awas')) {
      return AetherConstants.statusOrange;
    }
    if (s.contains('waspada') || s.contains('warning') || s.contains('hati')) {
      return AetherConstants.statusYellow;
    }
    return AetherConstants.statusGreen;
  }

  /// Map flood status to background badge color
  static Color getFloodStatusBgColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('bahaya') || s.contains('danger') || s.contains('kritis')) {
      return AetherConstants.statusRedBg;
    }
    if (s.contains('siaga') || s.contains('alert') || s.contains('awas')) {
      return AetherConstants.statusOrangeBg;
    }
    if (s.contains('waspada') || s.contains('warning') || s.contains('hati')) {
      return AetherConstants.statusYellowBg;
    }
    return AetherConstants.statusGreenBg;
  }

  /// Format data freshness: "Just now", "X seconds ago", "Telemetry delayed"
  static String formatFreshness(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Waiting for data';
    final diff = DateTime.now().difference(lastUpdated);

    if (diff.inSeconds < 5) {
      return 'Just now';
    } else if (diff.inSeconds < 60) {
      return '${diff.inSeconds} seconds ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Telemetry delayed';
    }
  }

  /// Check if telemetry is considered delayed (> 20 seconds)
  static bool isDelayed(DateTime? lastUpdated) {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated).inSeconds > 20;
  }
}
