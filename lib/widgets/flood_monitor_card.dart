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
    final statusColor = AetherFormatters.getFloodStatusColor(floodStatus);
    final statusBgColor = AetherFormatters.getFloodStatusBgColor(floodStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isFloodWarning ? const Color(0xFFFFF1F2) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFloodWarning
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFE2E8F0),
          width: isFloodWarning ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isFloodWarning
                ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.waves_rounded,
                      color: AetherConstants.primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HC-SR04 • KETINGGIAN AIR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              // Status Badge (Aman, Waspada, Siaga, Bahaya Banjir)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
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

          const SizedBox(height: 18),

          // Primary Value: Ketinggian Air
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                waterLevelCm.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: isFloodWarning
                      ? const Color(0xFFDC2626)
                      : AetherConstants.textPrimary,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'cm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isFloodWarning
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Secondary Value: Jarak Pantulan Sensor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jarak Pantulan Ultrasonik:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '${waterDistanceCm.toStringAsFixed(1)} cm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
