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
  static const Color background = Color(0xFF0A0F1D); // Deep dark smart city
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceGlass = Color(0x551E293B);
  static const Color border = Color(0xFF1E293B);
  static const Color glassBorder = Color(0x3538BDF8);
  static const Color textPrimary = Color(0xFFF8FAFC); // Crisp white
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  // Brand Accents & Neon
  static const Color cyanAccent = Color(0xFF38BDF8); // Electric sky cyan
  static const Color neonTeal = Color(0xFF06B6D4);
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Blue
  static const Color primaryIndigo = Color(0xFF4F46E5);

  // Status Colors
  static const Color statusGreen = Color(0xFF10B981);
  static const Color statusGreenBg = Color(0xFF064E3B);
  static const Color statusGreenText = Color(0xFF34D399);

  static const Color statusYellow = Color(0xFFF59E0B);
  static const Color statusYellowBg = Color(0xFF78350F);
  static const Color statusYellowText = Color(0xFFFBBF24);

  static const Color statusOrange = Color(0xFFF97316);
  static const Color statusOrangeBg = Color(0xFF7C2D12);
  static const Color statusOrangeText = Color(0xFFFB923C);

  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusRedBg = Color(0xFF7F1D1D);
  static const Color statusRedText = Color(0xFFF87171);
}
