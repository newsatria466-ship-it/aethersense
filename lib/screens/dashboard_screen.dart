import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/telemetry_controller.dart';
import '../controllers/theme_controller.dart';
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
import '../widgets/smart_lamp_section.dart';
import '../widgets/smart_parking_section.dart';
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
    final isDark = context.read<ThemeController>().isDarkMode;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? AetherConstants.cyanAccent : Colors.white,
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

  void _showMenuModal(
    BuildContext context,
    TelemetryController controller,
    UpdateService updateService,
    ThemeController themeController,
  ) {
    final isDark = themeController.isDarkMode;
    final modalBg = isDark ? AetherConstants.surfaceDark : Colors.white;
    final textPrimary = isDark ? Colors.white : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Platform IoT Smart City • v${updateService.currentVersion}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close_rounded, color: textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
              ),
              const SizedBox(height: 8),

              // Menu Item: Mode Tema (Terang / Gelap)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x30FBBF24) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                    color: isDark ? const Color(0xFFFBBF24) : AetherConstants.primaryBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  isDark ? 'Mode Tampilan: Gelap' : 'Mode Tampilan: Terang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                subtitle: Text(
                  isDark ? 'Ketuk untuk beralih ke Mode Terang' : 'Ketuk untuk beralih ke Mode Gelap',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) {
                    themeController.toggleTheme();
                    Navigator.pop(ctx);
                  },
                  activeTrackColor: AetherConstants.cyanAccent,
                ),
                onTap: () {
                  themeController.toggleTheme();
                  Navigator.pop(ctx);
                },
              ),

              // Menu Item: Cek Pembaruan
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x3038BDF8) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Periksa Pembaruan Sistem (OTA)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Unduh pembaruan APK langsung dari GitHub',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _checkUpdateManually();
                },
              ),

              // Menu Item: Hubungkan Ulang MQTT
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0x2010B981),
                    borderRadius: BorderRadius.circular(10),
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
                    color: textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Broker: ${AetherConstants.brokerHost}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.retryConnection();
                },
              ),

              // Pilih Perangkat jika ada lebih dari 1
              if (controller.devices.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'PILIH NODE ESP32:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.devices.keys.map((devId) {
                    final isSelected = devId == controller.activeDeviceId;
                    final activeColor = isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue;

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
                          color: isSelected ? Colors.white : textPrimary,
                        ),
                      ),
                      selectedColor: activeColor,
                      backgroundColor: isDark ? const Color(0x301E293B) : const Color(0xFFF1F5F9),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 18),
              Text(
                'Pemerintah Kota Tegal • Smart City EcoSense',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    final controller = context.watch<TelemetryController>();
    final updateService = context.watch<UpdateService>();
    final telemetry = controller.telemetry;
    final hasUpdate = updateService.updateInfo?.hasUpdate ?? false;

    final scaffoldBg = isDark ? AetherConstants.bgDark : AetherConstants.bgLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Scrollable Dashboard Content
            RefreshIndicator(
              color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
              backgroundColor: isDark ? AetherConstants.surfaceDark : Colors.white,
              onRefresh: () => controller.retryConnection(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Clean Hero Banner Section (Header, Alun-Alun Tegal photo, Metric overview, Theme Toggle)
                    HeroBannerSection(
                      telemetry: telemetry,
                      connectionStatus: controller.connectionStatus,
                      onCheckUpdate: _checkUpdateManually,
                      onToggleTheme: () => themeController.toggleTheme(),
                      onMenuTap: () => _showMenuModal(
                        context,
                        controller,
                        updateService,
                        themeController,
                      ),
                      onRetryConnection: () => controller.retryConnection(),
                      isDarkMode: isDark,
                      hasUpdate: hasUpdate,
                      currentVersion: updateService.currentVersion,
                    ),

                    const SizedBox(height: 16),

                    // Tab View Switcher
                    if (_selectedNavIndex == 2)
                      const SmartLampSection()
                    else if (_selectedNavIndex == 1)
                      const SmartParkingSection()
                    else
                      _buildMonitoringSection(
                        context: context,
                        controller: controller,
                        telemetry: telemetry,
                        isDark: isDark,
                        textSecondary: textSecondary,
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              left: 18,
              right: 18,
              bottom: 14,
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
      ),
    );
  }

  /// Section Monitoring Lingkungan (Tab 0)
  Widget _buildMonitoringSection({
    required BuildContext context,
    required TelemetryController controller,
    required dynamic telemetry,
    required bool isDark,
    required Color textSecondary,
  }) {
    final activeRelayCount = controller.activeRelayCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flood Warning / Safe Banner
          FloodAlertBanner(
            isFloodWarning: telemetry?.isFloodWarning ?? false,
            floodStatus: telemetry?.floodStatus ?? 'Aman',
            waterLevelCm: telemetry?.waterLevelCm ?? 0.0,
          ),

          const SizedBox(height: 16),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONITORING LINGKUNGAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x301E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  controller.freshnessText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
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

          // Climate Card (DHT22 Detail)
          ClimateCard(
            temperatureC: telemetry?.temperatureC ?? 0.0,
            humidityPercent: telemetry?.humidityPercent ?? 0.0,
          ),

          const SizedBox(height: 14),

          // Smart Lamp Quick Access Card inside Monitoring
          InkWell(
            onTap: () {
              setState(() {
                _selectedNavIndex = 2;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AetherConstants.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: activeRelayCount > 0
                      ? (isDark ? const Color(0x80F59E0B) : const Color(0xFFFCD34D))
                      : (isDark ? AetherConstants.borderDark : AetherConstants.borderLight),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: activeRelayCount > 0
                          ? (isDark ? const Color(0x35F59E0B) : const Color(0xFFFEF3C7))
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: activeRelayCount > 0 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Smart Lamp Kota Tegal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AetherConstants.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: activeRelayCount > 0
                                    ? const Color(0x3010B981)
                                    : (isDark ? const Color(0x3064748B) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                activeRelayCount > 0 ? '$activeRelayCount Aktif' : 'Semua Padam',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: activeRelayCount > 0
                                      ? const Color(0xFF10B981)
                                      : textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${controller.isAutoMode ? "Otomatis (LDR)" : "Manual (Operator)"} • Ambien: ${controller.ambientLight} (${controller.ldrRaw} ADC)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Technical Device Info Card
          TechnicalInfoCard(
            deviceId: telemetry?.deviceId ?? (controller.activeDeviceId ?? 'ESP32-S3'),
            uptimeSeconds: telemetry?.uptimeSeconds ?? 0,
            sequence: telemetry?.sequence ?? 0,
            wifiRssiDbm: telemetry?.wifiRssiDbm ?? -70,
          ),

          // Bottom padding for navigation clearance
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}
