import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/telemetry_controller.dart';
import '../services/update_service.dart';
import '../utils/constants.dart';
import '../widgets/connection_badge.dart';
import '../widgets/empty_telemetry_view.dart';
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
        content: Text(
          'Memeriksa pembaruan sistem AetherSense...',
          style: GoogleFonts.plusJakartaSans(),
        ),
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
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AetherConstants.statusGreenText,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TelemetryController>();
    final telemetry = controller.telemetry;
    final hasData = controller.hasData;
    final activeDevice = controller.activeDeviceId ?? 'Waiting...';

    return Scaffold(
      backgroundColor: AetherConstants.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.retryConnection(),
          child: Column(
            children: [
              // Header & Connection Section
              _buildAppBar(context, activeDevice, controller),

              // Main Body: Empty State or Populated Responsive Dashboard
              Expanded(
                child: hasData && telemetry != null
                    ? _buildResponsiveDashboard(context, telemetry, controller)
                    : EmptyTelemetryView(
                        connectionStatus: controller.connectionStatus,
                        onRetry: () => controller.retryConnection(),
                      ),
              ),

              // Bottom Smart City Navigation
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
      ),
    );
  }

  /// App Bar with Device Identifier and Status Badge
  Widget _buildAppBar(
    BuildContext context,
    String activeDevice,
    TelemetryController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AetherConstants.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand & Active Device Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.cloud_sync_rounded,
                          color: AetherConstants.primaryBlue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AetherSense Dashboard',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AetherConstants.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        'Device: ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AetherConstants.textSecondary,
                        ),
                      ),
                      Text(
                        activeDevice,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: activeDevice == 'Waiting...'
                              ? const Color(0xFFD97706)
                              : AetherConstants.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Manual Update Check Button
              IconButton(
                onPressed: _checkUpdateManually,
                tooltip: 'Cek Pembaruan',
                icon: const Icon(
                  Icons.system_update_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Live Connection Status Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConnectionBadge(
                status: controller.connectionStatus,
                isLive: !controller.isTelemetryDelayed,
                freshnessText: controller.freshnessText,
                onRetry: () => controller.retryConnection(),
              ),

              // Device Selector if multiple ESP32 devices found
              if (controller.devices.length > 1)
                _buildDeviceSelector(controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSelector(TelemetryController controller) {
    return PopupMenuButton<String>(
      onSelected: (devId) => controller.selectDevice(devId),
      tooltip: 'Pilih Perangkat',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.devices_rounded, size: 12, color: Color(0xFF475569)),
            const SizedBox(width: 4),
            Text(
              '${controller.devices.length} Devices',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 14, color: Color(0xFF64748B)),
          ],
        ),
      ),
      itemBuilder: (context) {
        return controller.devices.keys.map((id) {
          final isSelected = id == controller.activeDeviceId;
          return PopupMenuItem(
            value: id,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 16,
                  color: isSelected ? AetherConstants.primaryBlue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  id,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  /// Responsive Layout: Mobile stacked vs Tablet/Desktop wide grid
  Widget _buildResponsiveDashboard(
    BuildContext context,
    dynamic telemetry,
    TelemetryController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 768;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO FLOOD ALERT (Top Priority)
              FloodAlertBanner(
                isFloodWarning: telemetry.isFloodWarning,
                floodStatus: telemetry.floodStatus,
                waterLevelCm: telemetry.waterLevelCm,
              ),

              const SizedBox(height: 18),

              if (isWideScreen)
                // Tablet / Desktop Multi-Column Grid
                _buildWideLayout(telemetry)
              else
                // Mobile Stacked Layout
                _buildMobileLayout(telemetry),

              const SizedBox(height: 16),

              // Technical Device & RSSI Information
              TechnicalInfoCard(
                deviceId: telemetry.deviceId,
                uptimeSeconds: telemetry.uptimeSeconds,
                sequence: telemetry.sequence,
                wifiRssiDbm: telemetry.wifiRssiDbm,
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(dynamic telemetry) {
    return Column(
      children: [
        // Flood Monitor Card
        FloodMonitorCard(
          waterLevelCm: telemetry.waterLevelCm,
          waterDistanceCm: telemetry.waterDistanceCm,
          floodStatus: telemetry.floodStatus,
          isFloodWarning: telemetry.isFloodWarning,
        ),

        const SizedBox(height: 14),

        // Climate Card (DHT22)
        ClimateCard(
          temperatureC: telemetry.temperatureC,
          humidityPercent: telemetry.humidityPercent,
        ),

        const SizedBox(height: 14),

        // Air Quality Card (MQ-135)
        AirQualityCard(
          airQualityStatus: telemetry.airQualityStatus,
          mq135SensorMv: telemetry.mq135SensorMv,
          mq135Raw: telemetry.mq135Raw,
          isGasPolluted: telemetry.isGasPolluted,
        ),

        const SizedBox(height: 14),

        // Rain Sensor Card
        RainSensorCard(
          rainStatus: telemetry.rainStatus,
          rainRaw: telemetry.rainRaw,
          isRaining: telemetry.isRaining,
        ),
      ],
    );
  }

  Widget _buildWideLayout(dynamic telemetry) {
    return Column(
      children: [
        // Top Wide Row: Flood Monitor + Climate
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: FloodMonitorCard(
                waterLevelCm: telemetry.waterLevelCm,
                waterDistanceCm: telemetry.waterDistanceCm,
                floodStatus: telemetry.floodStatus,
                isFloodWarning: telemetry.isFloodWarning,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 5,
              child: ClimateCard(
                temperatureC: telemetry.temperatureC,
                humidityPercent: telemetry.humidityPercent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Bottom Wide Row: Air Quality + Rain
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: AirQualityCard(
                airQualityStatus: telemetry.airQualityStatus,
                mq135SensorMv: telemetry.mq135SensorMv,
                mq135Raw: telemetry.mq135Raw,
                isGasPolluted: telemetry.isGasPolluted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 5,
              child: RainSensorCard(
                rainStatus: telemetry.rainStatus,
                rainRaw: telemetry.rainRaw,
                isRaining: telemetry.isRaining,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
