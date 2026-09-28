import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ClimateCard extends StatelessWidget {
  final double temperatureC;
  final double humidityPercent;

  const ClimateCard({
    super.key,
    required this.temperatureC,
    required this.humidityPercent,
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
            color: const Color(0x35141E33),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0x25F97316),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.thermostat_rounded,
                      color: Color(0xFFFB923C),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DHT22 • IKLIM & SUHU',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Two Column Metrics (Temp & Humidity)
              Row(
                children: [
                  // Temperature
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suhu Udara',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              temperatureC.toStringAsFixed(1),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '°C',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFB923C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 42,
                    color: Colors.white.withOpacity(0.08),
                  ),

                  const SizedBox(width: 16),

                  // Humidity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelembapan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              humidityPercent.toStringAsFixed(0),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AetherConstants.cyanAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
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
