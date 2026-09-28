import 'dart:ui';
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isGasPolluted
                ? const Color(0x33EF4444)
                : const Color(0x35141E33),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isGasPolluted
                  ? const Color(0x88EF4444)
                  : Colors.white.withOpacity(0.1),
              width: isGasPolluted ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isGasPolluted
                    ? const Color(0x33EF4444)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
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
                              ? const Color(0x33EF4444)
                              : const Color(0x2538BDF8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.air_rounded,
                          color: isGasPolluted
                              ? const Color(0xFFF87171)
                              : AetherConstants.cyanAccent,
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
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  // Badge Bahaya / Normal
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGasPolluted
                          ? const Color(0x44EF4444)
                          : const Color(0x3310B981),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isGasPolluted
                            ? const Color(0x88EF4444)
                            : const Color(0x5510B981),
                      ),
                    ),
                    child: Text(
                      isGasPolluted ? 'BAHAYA GAS' : 'NORMAL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isGasPolluted
                            ? const Color(0xFFF87171)
                            : const Color(0xFF34D399),
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
                      ? const Color(0xFFF87171)
                      : Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.white.withOpacity(0.08)),
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
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),
                  Text(
                    'ADC Raw: $mq135Raw',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
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
