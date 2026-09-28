import 'dart:ui';
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isFloodWarning
                ? const Color(0x33EF4444)
                : const Color(0x35141E33),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isFloodWarning
                  ? const Color(0x88EF4444)
                  : Colors.white.withOpacity(0.1),
              width: isFloodWarning ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isFloodWarning
                    ? const Color(0x33EF4444)
                    : Colors.black.withOpacity(0.25),
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
                          color: const Color(0x2538BDF8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.waves_rounded,
                          color: AetherConstants.cyanAccent,
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
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  // Status Badge (Aman, Waspada, Siaga, Bahaya Banjir)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFloodWarning
                          ? const Color(0x44EF4444)
                          : const Color(0x3310B981),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.5),
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
                      fontWeight: FontWeight.w900,
                      color: isFloodWarning
                          ? const Color(0xFFF87171)
                          : Colors.white,
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
                          ? const Color(0xFFF87171)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.white.withOpacity(0.08)),
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
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    '${waterDistanceCm.toStringAsFixed(1)} cm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AetherConstants.cyanAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
