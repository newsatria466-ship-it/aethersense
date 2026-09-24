import 'package:flutter/material.dart';

class AetherConstants {
  // MQTT Config
  static const String brokerHost = 'broker.hivemq.com';
  static const int brokerPort = 1883;
  static const int brokerWsPort = 8884;
  static const String wsUrl = 'wss://broker.hivemq.com/mqtt';
  
  // Wildcard Topics
  static const String telemetryTopic = 'aethersense/+/telemetry';
  static const String statusTopic = 'aethersense/+/status';

  // App Theme Colors (Apple / Linear / Modern IoT SaaS)
  static const Color background = Color(0xFFF8FAFC); // Very light slate
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A); // Almost black
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Brand Accents
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Blue
  static const Color primaryIndigo = Color(0xFF4F46E5);

  // Status Colors
  static const Color statusGreen = Color(0xFF10B981);
  static const Color statusGreenBg = Color(0xFFECFDF5);
  static const Color statusGreenText = Color(0xFF065F46);

  static const Color statusYellow = Color(0xFFF59E0B);
  static const Color statusYellowBg = Color(0xFFFFFBEB);
  static const Color statusYellowText = Color(0xFF92400E);

  static const Color statusOrange = Color(0xFFF97316);
  static const Color statusOrangeBg = Color(0xFFFFEDD5);
  static const Color statusOrangeText = Color(0xFF9A3412);

  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusRedBg = Color(0xFFFEF2F2);
  static const Color statusRedText = Color(0xFF991B1B);
}
