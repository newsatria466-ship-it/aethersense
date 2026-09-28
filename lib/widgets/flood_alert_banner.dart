import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloodAlertBanner extends StatefulWidget {
  final bool isFloodWarning;
  final String floodStatus;
  final double waterLevelCm;

  const FloodAlertBanner({
    super.key,
    required this.isFloodWarning,
    required this.floodStatus,
    required this.waterLevelCm,
  });

  @override
  State<FloodAlertBanner> createState() => _FloodAlertBannerState();
}

class _FloodAlertBannerState extends State<FloodAlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.01).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFloodWarning) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0x35EF4444),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Warning Icon Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Emergency Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'PERINGATAN BANJIR',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: const Color(0xFFFCA5A5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.floodStatus.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            text: 'Ketinggian Air Saat Ini: ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFFFECACA),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: '${widget.waterLevelCm.toStringAsFixed(1)} cm',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Normal Safe Condition Banner (Dark Glassmorphic)
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0x2510B981),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0x4410B981),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x3310B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF34D399),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kondisi Lingkungan Aman',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Semua parameter ketinggian air & sensor berada di batas aman.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
