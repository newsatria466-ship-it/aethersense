import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/telemetry_data.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class OverviewCarouselCard extends StatefulWidget {
  final TelemetryData? telemetry;
  final bool isDark;

  const OverviewCarouselCard({
    super.key,
    required this.telemetry,
    required this.isDark,
  });

  @override
  State<OverviewCarouselCard> createState() => _OverviewCarouselCardState();
}

class _OverviewCarouselCardState extends State<OverviewCarouselCard> {
  static const int _slideCount = 4;
  static const int _initialPage = 400; // Large number for seamless infinite forward sliding
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController(initialPage: _initialPage);
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _resetAutoSlideTimer() {
    _startAutoSlideTimer();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatUptimeShort(int seconds) {
    if (seconds <= 0) return 'Up: 0m';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return 'Up: ${hours}h ${minutes}m';
    } else {
      return 'Up: ${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final telemetry = widget.telemetry;

    final cardBg = isDark ? AetherConstants.surfaceDark : Colors.white;
    final borderColor = isDark ? AetherConstants.borderDark : AetherConstants.borderLight;
    final primaryColor = isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 172,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle background glow for ambient modern feel
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: isDark ? 0.08 : 0.04),
                  ),
                ),
              ),

              // Interactive Auto-Sliding PageView
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is UserScrollNotification) {
                    _resetAutoSlideTimer();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex % _slideCount;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = index % _slideCount;
                    switch (slide) {
                      case 0:
                        return _buildSlideWaterLevel(telemetry, isDark);
                      case 1:
                        return _buildSlideSmartLamp(telemetry, isDark);
                      case 2:
                        return _buildSlideClimate(telemetry, isDark);
                      case 3:
                        return _buildSlideDevice(telemetry, isDark);
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ),

              // Animated Page Dots Indicator (Pinned at Bottom Center)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slideCount, (i) {
                    final isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 20 : 6,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive
                            ? primaryColor
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.18)
                                : const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SLIDE 1: Status Banjir & Ketinggian Air
  // ==========================================
  Widget _buildSlideWaterLevel(TelemetryData? telemetry, bool isDark) {
    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    final floodStatus = telemetry?.floodStatus ?? 'Aman';
    final waterLevelCm = telemetry?.waterLevelCm ?? 0.0;
    final waterDistanceCm = telemetry?.waterDistanceCm ?? 0.0;

    final statusColor = AetherFormatters.getFloodStatusColor(floodStatus);
    final statusBg = AetherFormatters.getFloodStatusBgColor(floodStatus);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Label & Flood Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.waves_rounded,
                      color: Color(0xFF0284C7),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DETEKSI KETINGGIAN AIR & BANJIR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
              // Dynamic Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.35)),
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
                    const SizedBox(width: 5),
                    Text(
                      floodStatus,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Title
          Text(
            'Deteksi Ketinggian Air & Banjir',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),

          const Spacer(),

          // Metrics Row
          Row(
            children: [
              // Value 1: Tinggi Genangan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tinggi Genangan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${waterLevelCm.toStringAsFixed(1)} cm',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 32,
                width: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 14),

              // Value 2: Jarak Pantulan Sensor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jarak Pantulan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${waterDistanceCm.toStringAsFixed(1)} cm',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Info Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x301E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sensor Air',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 2: Status Smart Lamp & Ambien
  // ==========================================
  Widget _buildSlideSmartLamp(TelemetryData? telemetry, bool isDark) {
    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    final isAuto = telemetry?.lightingMode != 'manual';
    final modeLabel = isAuto ? 'Otomatis (LDR)' : 'Manual (Operator)';
    final ambientLight = telemetry?.ambientLight ?? 'Terang';
    final isDarkAmbient = telemetry?.isDark ?? (ambientLight == 'Gelap');
    final ldrRaw = telemetry?.ldrRaw ?? 0;

    int activeCount = 0;
    if (telemetry != null) {
      if (telemetry.relay1) activeCount++;
      if (telemetry.relay2) activeCount++;
      if (telemetry.relay3) activeCount++;
      if (telemetry.relay4) activeCount++;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Label & Mode Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFFF59E0B),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PENERANGAN JALAN & AMBIEN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              // Mode Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isAuto
                      ? (isDark ? const Color(0x3010B981) : const Color(0xFFECFDF5))
                      : (isDark ? const Color(0x306366F1) : const Color(0xFFEEF2FF)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAuto
                        ? AetherConstants.statusGreen.withValues(alpha: 0.4)
                        : const Color(0xFF6366F1).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAuto ? Icons.auto_mode_rounded : Icons.tune_rounded,
                      size: 12,
                      color: isAuto ? AetherConstants.statusGreen : const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      modeLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isAuto ? AetherConstants.statusGreen : const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Title
          Text(
            'Sistem Penerangan Jalan & Sektor',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),

          const Spacer(),

          // Metrics Row
          Row(
            children: [
              // Value 1: Kondisi Ambien
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kondisi Ambien',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isDarkAmbient ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                          size: 16,
                          color: isDarkAmbient ? const Color(0xFFA78BFA) : const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$ambientLight ($ldrRaw)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                height: 32,
                width: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 14),

              // Value 2: Ringkasan Sektor Relay
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Sektor',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$activeCount dari 4 Sektor Menyala',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: activeCount > 0 ? const Color(0xFFF59E0B) : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Mini Sector LEDs
              Row(
                children: [
                  _buildMiniLed(telemetry?.relay1 ?? false),
                  const SizedBox(width: 3),
                  _buildMiniLed(telemetry?.relay2 ?? false),
                  const SizedBox(width: 3),
                  _buildMiniLed(telemetry?.relay3 ?? false),
                  const SizedBox(width: 3),
                  _buildMiniLed(telemetry?.relay4 ?? false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLed(bool isOn) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOn ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8).withValues(alpha: 0.4),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  // ==========================================
  // SLIDE 3: Kondisi Cuaca & Suhu Lingkungan
  // ==========================================
  Widget _buildSlideClimate(TelemetryData? telemetry, bool isDark) {
    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    final temp = telemetry?.temperatureC ?? 0.0;
    final humidity = telemetry?.humidityPercent ?? 0.0;
    final rainStatus = telemetry?.rainStatus ?? 'Kering';
    final isRaining = telemetry?.isRaining ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Label & Rain Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cloud_outlined,
                      color: Color(0xFF10B981),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'IKLIM & KONDISI LINGKUNGAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              // Rain Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isRaining
                      ? (isDark ? const Color(0x3038BDF8) : const Color(0xFFE0F2FE))
                      : (isDark ? const Color(0x3010B981) : const Color(0xFFECFDF5)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRaining
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                        : AetherConstants.statusGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRaining ? Icons.grain_rounded : Icons.water_drop_outlined,
                      size: 12,
                      color: isRaining ? const Color(0xFF0284C7) : AetherConstants.statusGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rainStatus,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isRaining ? const Color(0xFF0284C7) : AetherConstants.statusGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Title
          Text(
            'Iklim & Kondisi Lingkungan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),

          const Spacer(),

          // Metrics Row
          Row(
            children: [
              // Value 1: Suhu Udara
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suhu Udara',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${temp.toStringAsFixed(1)} °C',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 32,
                width: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 14),

              // Value 2: Kelembaban Udara
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelembaban Udara',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${humidity.toStringAsFixed(1)} %',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),

              // Info Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x301E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Suhu & Udara',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 4: Status Perangkat IoT & Koneksi
  // ==========================================
  Widget _buildSlideDevice(TelemetryData? telemetry, bool isDark) {
    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    final deviceId = telemetry?.deviceId ?? 'ESP32-S3 Node';
    final uptimeSeconds = telemetry?.uptimeSeconds ?? 0;
    final uptimeFormatted = _formatUptimeShort(uptimeSeconds);
    final rssi = telemetry?.wifiRssiDbm ?? -60;
    final rssiColor = AetherFormatters.getRssiColor(rssi);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Label & WiFi Signal Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.memory_rounded,
                      color: Color(0xFF6366F1),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'STATUS PERANGKAT IOT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              // Signal Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: rssiColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rssiColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_rounded,
                      size: 12,
                      color: rssiColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rssi dBm',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: rssiColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Title
          Text(
            'Status Perangkat IoT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),

          const Spacer(),

          // Metrics Row
          Row(
            children: [
              // Value 1: Device ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device ID',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deviceId,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Container(
                height: 32,
                width: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 14),

              // Value 2: Uptime (Jam & Menit)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu Aktif (Uptime)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      uptimeFormatted,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              // Info Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x301E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Status IoT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
