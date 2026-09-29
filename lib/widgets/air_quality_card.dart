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
    final isPolusiRingan = airQualityStatus.toLowerCase().contains('polusi ringan');
    final isSangatBersih = airQualityStatus.toLowerCase().contains('sangat bersih');

    final cardBg = isGasPolluted
        ? (isDark ? const Color(0x35EF4444) : const Color(0xFFFEF2F2))
        : isPolusiRingan
            ? (isDark ? const Color(0x22F59E0B) : const Color(0xFFFFFBEB))
            : (isDark ? AetherConstants.surfaceDark : Colors.white);

    final borderColor = isGasPolluted
        ? (isDark ? const Color(0x88EF4444) : const Color(0xFFFCA5A5))
        : isPolusiRingan
            ? (isDark ? const Color(0x88F59E0B) : const Color(0xFFFDE68A))
            : (isDark ? AetherConstants.borderDark : AetherConstants.borderLight);

    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    final badgeText = isGasPolluted
        ? 'TERCEMAR'
        : isPolusiRingan
            ? 'POLUSI RINGAN'
            : isSangatBersih
                ? 'SANGAT BERSIH'
                : 'BAIK';

    final badgeBg = isGasPolluted
        ? const Color(0xFFEF4444)
        : isPolusiRingan
            ? (isDark ? const Color(0x30F59E0B) : const Color(0xFFFEF3C7))
            : isSangatBersih
                ? (isDark ? const Color(0x30059669) : const Color(0xFFD1FAE5))
                : (isDark ? const Color(0x3010B981) : const Color(0xFFDCFCE7));

    final badgeTextColor = isGasPolluted
        ? Colors.white
        : isPolusiRingan
            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
            : isSangatBersih
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
                : (isDark ? const Color(0xFF34D399) : const Color(0xFF15803D));

    final statusTextColor = isGasPolluted
        ? const Color(0xFFDC2626)
        : isPolusiRingan
            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
            : isSangatBersih
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                : textPrimary;

    final iconColor = isGasPolluted
        ? const Color(0xFFDC2626)
        : isPolusiRingan
            ? const Color(0xFFF59E0B)
            : isSangatBersih
                ? const Color(0xFF059669)
                : (isDark ? AetherConstants.cyanAccent : const Color(0xFF0284C7));

    final iconBg = isGasPolluted
        ? const Color(0xFFFEE2E2)
        : isPolusiRingan
            ? const Color(0xFFFEF3C7)
            : (isDark ? const Color(0x2538BDF8) : const Color(0xFFE0F2FE));

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
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.air_rounded,
                      color: iconColor,
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
              // Badge Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
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
              color: statusTextColor,
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
