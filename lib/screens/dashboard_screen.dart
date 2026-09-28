import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/telemetry_controller.dart';
import '../services/update_service.dart';
import '../utils/constants.dart';
import '../widgets/hero_banner_section.dart';
import '../widgets/flood_alert_banner.dart';
import '../widgets/flood_monitor_card.dart';
import '../widgets/climate_card.dart';
import '../widgets/air_quality_card.dart';
import '../widgets/rain_sensor_card.dart';
import '../widgets/technical_info_card.dart';
import '../widgets/smart_city_navigation.dart';
import 'widgets/update_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;
  Timer? _updateCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCheckTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _checkUpdateSilently();
        }
      });
    });
  }

  @override
  void dispose() {
    _updateCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkUpdateSilently() async {
    if (!mounted) return;
    final updateService = context.read<UpdateService>();
    final info = await updateService.checkForUpdate();
    if (info != null && info.hasUpdate && mounted) {
      UpdateDialog.show(context, info);
    }
  }

  Future<void> _checkUpdateManually() async {
    final updateService = context.read<UpdateService>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AetherConstants.cyanAccent,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Memeriksa pembaruan Tegal EcoSense...',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    final info = await updateService.checkForUpdate();
    if (!mounted) return;

    if (info != null && info.hasUpdate) {
      UpdateDialog.show(context, info);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aplikasi sudah versi terbaru (v${updateService.currentVersion})',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF065F46),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMenuModal(BuildContext context, TelemetryController controller, UpdateService updateService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
              decoration: BoxDecoration(
                color: const Color(0xF00F172A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tegal EcoSense',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Smart City IoT Platform • v${updateService.currentVersion}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AetherConstants.cyanAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 12),

                  // Menu Action 1: Cek Pembaruan
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x3038BDF8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.system_update_rounded,
                        color: AetherConstants.cyanAccent,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Periksa Pembaruan Sistem (OTA)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Unduh versi APK terbaru dari GitHub Releases',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _checkUpdateManually();
                    },
                  ),

                  // Menu Action 2: Reconnect MQTT
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x3010B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sync_rounded,
                        color: AetherConstants.statusGreen,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Hubungkan Ulang MQTT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Broker: ${AetherConstants.brokerHost}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.retryConnection();
                    },
                  ),

                  // Menu Action 3: Pilih Perangkat Aktif
                  if (controller.devices.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'PILIH NODE ESP32 AKTIF:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.devices.keys.map((devId) {
                        final isSelected = devId == controller.activeDeviceId;
                        return ChoiceChip(
                          selected: isSelected,
                          onSelected: (_) {
                            controller.selectDevice(devId);
                            Navigator.pop(ctx);
                          },
                          label: Text(
                            devId,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                          selectedColor: AetherConstants.cyanAccent,
                          backgroundColor: const Color(0x301E293B),
                          side: BorderSide(
                            color: isSelected ? AetherConstants.cyanAccent : Colors.white24,
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Text(
                    'Pemerintah Kota Tegal • Smart City EcoSense 2026',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TelemetryController>();
    final updateService = context.watch<UpdateService>();
    final telemetry = controller.telemetry;
    final hasUpdate = updateService.updateInfo?.hasUpdate ?? false;

    return Scaffold(
      backgroundColor: AetherConstants.background,
      body: Stack(
        children: [
          // Main Scrollable Area
          RefreshIndicator(
            color: AetherConstants.cyanAccent,
            backgroundColor: const Color(0xFF0F172A),
            onRefresh: () => controller.retryConnection(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HERO BANNER SECTION (Photo Alun-Alun Tegal, Title, Glassmorphic Cards)
                  HeroBannerSection(
                    telemetry: telemetry,
                    connectionStatus: controller.connectionStatus,
                    onCheckUpdate: _checkUpdateManually,
                    onMenuTap: () => _showMenuModal(context, controller, updateService),
                    onRetryConnection: () => controller.retryConnection(),
                    hasUpdate: hasUpdate,
                    currentVersion: updateService.currentVersion,
                  ),

                  const SizedBox(height: 16),

                  // 2. MAIN SENSORS CONTENT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Flood Alert Banner (if warning or normal status)
                        FloodAlertBanner(
                          isFloodWarning: telemetry?.isFloodWarning ?? false,
                          floodStatus: telemetry?.floodStatus ?? 'Aman',
                          waterLevelCm: telemetry?.waterLevelCm ?? 0.0,
                        ),

                        const SizedBox(height: 16),

                        // Section Heading: Pemantauan Lingkungan Realtime
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MONITORING LINGKUNGAN',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: AetherConstants.cyanAccent,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0x301E293B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Text(
                                controller.freshnessText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Water Level & Flood Monitor Card
                        FloodMonitorCard(
                          waterLevelCm: telemetry?.waterLevelCm ?? 0.0,
                          waterDistanceCm: telemetry?.waterDistanceCm ?? 0.0,
                          floodStatus: telemetry?.floodStatus ?? 'Aman',
                          isFloodWarning: telemetry?.isFloodWarning ?? false,
                        ),

                        const SizedBox(height: 14),

                        // Air Quality Sensor Card (MQ-135)
                        AirQualityCard(
                          airQualityStatus: telemetry?.airQualityStatus ?? 'Normal / Baik',
                          mq135SensorMv: telemetry?.mq135SensorMv ?? 0.0,
                          mq135Raw: telemetry?.mq135Raw ?? 0,
                          isGasPolluted: telemetry?.isGasPolluted ?? false,
                        ),

                        const SizedBox(height: 14),

                        // Rain Sensor Card
                        RainSensorCard(
                          rainStatus: telemetry?.rainStatus ?? 'Tidak Hujan',
                          rainRaw: telemetry?.rainRaw ?? 4095,
                          isRaining: telemetry?.isRaining ?? false,
                        ),

                        const SizedBox(height: 14),

                        // Climate & Ambient Card (DHT22 Detail)
                        ClimateCard(
                          temperatureC: telemetry?.temperatureC ?? 0.0,
                          humidityPercent: telemetry?.humidityPercent ?? 0.0,
                        ),

                        const SizedBox(height: 14),

                        // Technical Device Info Card
                        TechnicalInfoCard(
                          deviceId: telemetry?.deviceId ?? (controller.activeDeviceId ?? 'ESP32-S3'),
                          uptimeSeconds: telemetry?.uptimeSeconds ?? 0,
                          sequence: telemetry?.sequence ?? 0,
                          wifiRssiDbm: telemetry?.wifiRssiDbm ?? -70,
                        ),

                        // Bottom space so navigation doesn't overlap
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: SmartCityNavigation(
              currentIndex: _selectedNavIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedNavIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
