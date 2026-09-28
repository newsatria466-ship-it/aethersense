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

  // Light Mode Colors (Clean, bright, modern)
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Backward-compatible aliases
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;

  // Dark Mode Colors (Clean dark slate, readable)
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Brand Accent
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Blue
  static const Color cyanAccent = Color(0xFF0284C7); // Clean Sky Blue
  static const Color accentIndigo = Color(0xFF4F46E5);

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

  // Dynamic getters
  static Color getBackground(bool isDark) => isDark ? bgDark : bgLight;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color getBorder(bool isDark) => isDark ? borderDark : borderLight;
  static Color getTextPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color getTextSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
}
