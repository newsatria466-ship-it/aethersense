import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class AirQualityCard extends StatelessWidget {
  final String airQualityStatus;
  final double mq135SensorMv;
  final int mq135Raw;
  final bool isGasPolluted;

  const AirQualityCard({
    super.key,
    required this.airQualityStatus,
    required this.mq135SensorMv,
    required this.mq135Raw,
    required this.isGasPolluted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isGasPolluted
        ? (isDark ? const Color(0x35EF4444) : const Color(0xFFFEF2F2))
        : (isDark ? AetherConstants.surfaceDark : Colors.white);

    final borderColor = isGasPolluted
        ? (isDark ? const Color(0x88EF4444) : const Color(0xFFFCA5A5))
        : (isDark ? AetherConstants.borderDark : AetherConstants.borderLight);

    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isGasPolluted ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isGasPolluted
                ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Hazard Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isGasPolluted
                          ? const Color(0xFFFEE2E2)
                          : (isDark ? const Color(0x2538BDF8) : const Color(0xFFE0F2FE)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.air_rounded,
                      color: isGasPolluted
                          ? const Color(0xFFDC2626)
                          : (isDark ? AetherConstants.cyanAccent : const Color(0xFF0284C7)),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MQ-135 • KUALITAS UDARA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              // Badge Bahaya / Normal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGasPolluted
                      ? const Color(0xFFEF4444)
                      : (isDark ? const Color(0x3010B981) : const Color(0xFFDCFCE7)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isGasPolluted ? 'BAHAYA GAS' : 'NORMAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isGasPolluted
                        ? Colors.white
                        : (isDark ? const Color(0xFF34D399) : const Color(0xFF15803D)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Status
          Text(
            airQualityStatus,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isGasPolluted
                  ? const Color(0xFFDC2626)
                  : textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // Technical sub-metrics: Sensor Voltage & Raw Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sensor: ${mq135SensorMv.toStringAsFixed(1)} mV',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
              Text(
                'ADC Raw: $mq135Raw',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
