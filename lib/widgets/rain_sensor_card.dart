import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class RainSensorCard extends StatelessWidget {
  final String rainStatus;
  final int rainRaw;
  final bool isRaining;

  const RainSensorCard({
    super.key,
    required this.rainStatus,
    required this.rainRaw,
    required this.isRaining,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isRaining
        ? (isDark ? const Color(0x3010B981) : const Color(0xFFF0FDF4))
        : (isDark ? AetherConstants.surfaceDark : Colors.white);

    final borderColor = isRaining
        ? (isDark ? const Color(0x6610B981) : const Color(0xFF86EFAC))
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
          width: isRaining ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isRaining
                ? const Color(0xFF10B981).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Dynamic Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isRaining
                          ? const Color(0xFFDCFCE7)
                          : (isDark ? const Color(0x2038BDF8) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isRaining
                          ? Icons.water_drop_rounded
                          : Icons.wb_sunny_outlined,
                      color: isRaining
                          ? const Color(0xFF059669)
                          : (isDark ? AetherConstants.cyanAccent : const Color(0xFF64748B)),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SENSOR HUJAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              // Rain Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isRaining
                      ? (isDark ? const Color(0x3010B981) : const Color(0xFFDCFCE7))
                      : (isDark ? const Color(0x20334155) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRaining ? 'TERDETEKSI HUJAN' : 'KERING / CERAH',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isRaining
                        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF15803D))
                        : textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Rain Status
          Text(
            rainStatus,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isRaining
                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
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

          // Analog Raw Reading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nilai Analog ADC:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              Text(
                '$rainRaw',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
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
