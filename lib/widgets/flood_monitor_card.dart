import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class FloodMonitorCard extends StatelessWidget {
  final double waterLevelCm;
  final double waterDistanceCm;
  final String floodStatus;
  final bool isFloodWarning;

  const FloodMonitorCard({
    super.key,
    required this.waterLevelCm,
    required this.waterDistanceCm,
    required this.floodStatus,
    required this.isFloodWarning,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AetherFormatters.getFloodStatusColor(floodStatus);
    final statusBg = AetherFormatters.getFloodStatusBgColor(floodStatus);

    final cardBg = isFloodWarning
        ? (isDark ? const Color(0x35EF4444) : const Color(0xFFFFF1F2))
        : (isDark ? AetherConstants.surfaceDark : Colors.white);

    final borderColor = isFloodWarning
        ? (isDark ? const Color(0x88EF4444) : const Color(0xFFFCA5A5))
        : (isDark ? AetherConstants.borderDark : AetherConstants.borderLight);

    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isFloodWarning ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isFloodWarning
                ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Sensor Tag + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x2538BDF8) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.waves_rounded,
                      color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KETINGGIAN AIR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? statusColor.withValues(alpha: 0.2) : statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      floodStatus,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Primary Value: Ketinggian Air
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                waterLevelCm.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: isFloodWarning
                      ? const Color(0xFFDC2626)
                      : textPrimary,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'cm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isFloodWarning
                      ? const Color(0xFFDC2626)
                      : textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // Secondary Value: Jarak Pantulan Sensor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jarak Pantulan Ultrasonik:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              Text(
                '${waterDistanceCm.toStringAsFixed(1)} cm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AetherConstants.cyanAccent : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
