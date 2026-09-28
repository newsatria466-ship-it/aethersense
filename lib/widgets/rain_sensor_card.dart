import 'dart:ui';
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isRaining
                ? const Color(0x3310B981)
                : const Color(0x35141E33),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isRaining
                  ? const Color(0x6610B981)
                  : Colors.white.withOpacity(0.1),
              width: isRaining ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isRaining
                    ? const Color(0x2510B981)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
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
                              ? const Color(0x3310B981)
                              : const Color(0x2038BDF8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isRaining
                              ? Icons.water_drop_rounded
                              : Icons.wb_sunny_outlined,
                          color: isRaining
                              ? const Color(0xFF34D399)
                              : AetherConstants.cyanAccent,
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
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  // Rain Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRaining
                          ? const Color(0x3310B981)
                          : const Color(0x221E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRaining
                            ? const Color(0x5510B981)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      isRaining ? 'TERDETEKSI HUJAN' : 'KERING / CERAH',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isRaining
                            ? const Color(0xFF34D399)
                            : const Color(0xFF94A3B8),
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
                      ? const Color(0xFF34D399)
                      : Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.white.withOpacity(0.08)),
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
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    '$rainRaw',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
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
