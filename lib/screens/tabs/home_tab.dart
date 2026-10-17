import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/telemetry_data.dart';
import '../../services/mqtt_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/monitoring_history_modal.dart';
import '../../widgets/pressable_scale.dart';

class HomeTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeTab({
    super.key,
    required this.onNavigateToTab,
  });

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String _getCurrentDateFormatted() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<TelemetryController>();
    final themeController = context.watch<ThemeController>();
    final telemetry = controller.telemetry;
    final isConnected = controller.connectionStatus == MqttConnectionStateStatus.connected;
    final isConnecting = controller.connectionStatus == MqttConnectionStateStatus.connecting;

    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
          children: [
            // 1. Top Header Bar
            _buildTopHeader(context, isDark, controller, themeController, isConnected, isConnecting),

            const SizedBox(height: 16),

            // 2. Greeting & Date Banner
            _buildGreetingSection(isDark, textPrimary, textSecondary),

            const SizedBox(height: 16),

            // 3. Compact Hero Section: Alun-Alun Kota Tegal
            _buildCompactHero(context, isDark),

            const SizedBox(height: 20),

            // 4. Primary Safety Alert Banner (Only shown if Flood or Critical Condition)
            if (telemetry != null && (telemetry.isFloodWarning || telemetry.isGasPolluted))
              _buildCriticalAlertBanner(telemetry, isDark),

            // 5. Environmental Overview Grid (Safety First, Clean Hierarchy)
            _buildSectionTitle('RINGKASAN LINGKUNGAN', Icons.eco_rounded, textSecondary),
            const SizedBox(height: 10),

            _buildEnvironmentalGrid(context, telemetry, isDark, controller.freshnessText),

            const SizedBox(height: 20),

            // 6. Facility Quick Status (Smart Parking & Smart Lamp)
            _buildSectionTitle('FASILITAS CERDAS KOTA', Icons.hub_rounded, textSecondary),
            const SizedBox(height: 10),

            _buildFacilityOverviewCards(context, controller, isDark),

            const SizedBox(height: 20),

            // 7. Historical Analytics Quick Access Card
            _buildHistoryLauncherCard(context, isDark),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP HEADER BAR
  // ==========================================
  Widget _buildTopHeader(
    BuildContext context,
    bool isDark,
    TelemetryController controller,
    ThemeController themeController,
    bool isConnected,
    bool isConnecting,
  ) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.surfaceDark : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Identity (Logo + Name)
        const BrandLogo(size: 32, showText: true),

        // Action Buttons: Connection Indicator & Theme Toggle
        Row(
          children: [
            // Connection Pill Indicator
            PressableScale(
              onPressed: () => controller.retryConnection(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isConnected
                      ? (isDark ? AppColors.safeBgDark : AppColors.safeBgLight)
                      : isConnecting
                          ? (isDark ? AppColors.warningBgDark : AppColors.warningBgLight)
                          : (isDark ? AppColors.criticalBgDark : AppColors.criticalBgLight),
                  borderRadius: AppRadii.rPill,
                  border: Border.all(
                    color: isConnected
                        ? AppColors.safe.withValues(alpha: 0.3)
                        : isConnecting
                            ? AppColors.warning.withValues(alpha: 0.3)
                            : AppColors.critical.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isConnected
                            ? AppColors.safe
                            : isConnecting
                                ? AppColors.warning
                                : AppColors.critical,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected
                          ? 'Online'
                          : isConnecting
                              ? 'Menyambung'
                              : 'Offline',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isConnected
                            ? AppColors.safe
                            : isConnecting
                                ? AppColors.warning
                                : AppColors.critical,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Theme Toggle Button
            PressableScale(
              onPressed: () => themeController.toggleTheme(),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppRadii.rMd,
                  border: Border.all(color: border),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                  size: 18,
                  color: isDark ? const Color(0xFFFBBF24) : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // GREETING SECTION
  // ==========================================
  Widget _buildGreetingSection(bool isDark, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getTimeGreeting()}, Warga Tegal 👋',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _getCurrentDateFormatted(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // COMPACT HERO SECTION
  // ==========================================
  Widget _buildCompactHero(BuildContext context, bool isDark) {
    return Container(
      height: 148,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadii.rXl,
        image: const DecorationImage(
          image: AssetImage('assets/images/hero-alun-alun.jpeg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle Dark & Cyan Gradient Overlay for maximum readability
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.rXl,
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.70),
                  Colors.black.withValues(alpha: 0.25),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location Pin Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: AppRadii.rPill,
                    border: Border.all(
                      color: AppColors.cyanBlue.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: AppColors.cyanBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Kawasan Alun-Alun Kota Tegal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Title & Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pusat Komando Cerdas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pemantauan lingkungan & otomasi fasilitas secara real-time',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CRITICAL ALERT BANNER
  // ==========================================
  Widget _buildCriticalAlertBanner(TelemetryData telemetry, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.criticalBgDark : AppColors.criticalBgLight,
        borderRadius: AppRadii.rLg,
        border: Border.all(
          color: AppColors.critical.withValues(alpha: isDark ? 0.6 : 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  telemetry.isFloodWarning
                      ? 'Peringatan: Potensi Genangan Air!'
                      : 'Peringatan: Polusi Udara Terdeteksi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.critical,
                  ),
                ),
                Text(
                  telemetry.isFloodWarning
                      ? 'Tinggi air mencapai ${telemetry.waterLevelCm.toStringAsFixed(1)} cm (${telemetry.floodStatus}). Harap waspada.'
                      : 'Indeks MQ-135 mencapai ${telemetry.mq135Raw} (${telemetry.airQualityStatus}).',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ENVIRONMENTAL OVERVIEW GRID
  // ==========================================
  Widget _buildEnvironmentalGrid(
    BuildContext context,
    TelemetryData? telemetry,
    bool isDark,
    String freshness,
  ) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      children: [
        // Row 1: Ketinggian Air (Full Width Card for Safety Priority)
        PressableScale(
          onPressed: () => onNavigateToTab(1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: AppRadii.rLg,
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (telemetry?.isFloodWarning ?? false)
                        ? AppColors.critical.withValues(alpha: 0.12)
                        : AppColors.cyanBlue.withValues(alpha: 0.12),
                    borderRadius: AppRadii.rMd,
                  ),
                  child: Icon(
                    Icons.waves_rounded,
                    color: (telemetry?.isFloodWarning ?? false)
                        ? AppColors.critical
                        : AppColors.cyanBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ketinggian Air & Banjir',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: (telemetry?.isFloodWarning ?? false)
                                  ? (isDark ? AppColors.criticalBgDark : AppColors.criticalBgLight)
                                  : (isDark ? AppColors.safeBgDark : AppColors.safeBgLight),
                              borderRadius: AppRadii.rPill,
                            ),
                            child: Text(
                              telemetry?.floodStatus ?? 'Menunggu Data',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: (telemetry?.isFloodWarning ?? false)
                                    ? AppColors.critical
                                    : AppColors.safe,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            telemetry != null
                                ? telemetry.waterLevelCm.toStringAsFixed(1)
                                : '--.-',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'cm',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            freshness,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Row 2: Suhu Udara & Kelembaban (2 Columns)
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Suhu Udara',
                value: telemetry != null ? '${telemetry.temperatureC.toStringAsFixed(1)}°C' : '--°C',
                subtitle: telemetry != null && telemetry.temperatureC > 33 ? 'Cuaca Terik' : 'Ideal Normal',
                icon: Icons.thermostat_rounded,
                iconColor: const Color(0xFFEA580C),
                cardBg: cardBg,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => onNavigateToTab(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Kelembaban',
                value: telemetry != null ? '${telemetry.humidityPercent.toStringAsFixed(0)}%' : '--%',
                subtitle: telemetry?.rainStatus ?? 'Kering',
                icon: Icons.water_drop_rounded,
                iconColor: AppColors.cyanBlue,
                cardBg: cardBg,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => onNavigateToTab(1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 3: Kualitas Udara MQ-135 & Hujan
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Kualitas Udara',
                value: telemetry != null ? '${telemetry.mq135Raw} ADC' : '-- ADC',
                subtitle: telemetry?.airQualityStatus ?? 'Normal',
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF8B5CF6),
                cardBg: cardBg,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => onNavigateToTab(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Status Hujan',
                value: telemetry != null
                    ? (telemetry.isRaining ? 'Hujan' : 'Tidak Hujan')
                    : '--',
                subtitle: telemetry != null && telemetry.isRaining ? 'Plat sensor basah' : 'Cerah / Kering',
                icon: Icons.cloud_queue_rounded,
                iconColor: telemetry != null && telemetry.isRaining
                    ? AppColors.cyanBlue
                    : AppColors.safe,
                cardBg: cardBg,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => onNavigateToTab(1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadii.rLg,
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                Icon(icon, size: 16, color: iconColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FACILITY QUICK GLANCE
  // ==========================================
  Widget _buildFacilityOverviewCards(
    BuildContext context,
    TelemetryController controller,
    bool isDark,
  ) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      children: [
        // Smart Parking Glance
        Expanded(
          child: PressableScale(
            onPressed: () => onNavigateToTab(2),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadii.rLg,
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.cyanBlue.withValues(alpha: 0.12),
                          borderRadius: AppRadii.rSm,
                        ),
                        child: const Icon(Icons.local_parking_rounded, size: 16, color: AppColors.cyanBlue),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMutedLight),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Smart Parking',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${controller.parkingAvailableSlots}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: controller.parkingAvailableSlots > 0 ? AppColors.safe : AppColors.critical,
                        ),
                      ),
                      Text(
                        '/${controller.parkingTotalSlots} Tersedia',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Smart Lamp Glance
        Expanded(
          child: PressableScale(
            onPressed: () => onNavigateToTab(3),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadii.rLg,
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.ecoGreen.withValues(alpha: 0.12),
                          borderRadius: AppRadii.rSm,
                        ),
                        child: const Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.ecoGreen),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMutedLight),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Smart Public Lamp',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${controller.activeRelayCount} Nyala • Mode ${controller.isAutoMode ? "Auto" : "Manual"}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HISTORICAL ANALYTICS LAUNCHER
  // ==========================================
  Widget _buildHistoryLauncherCard(BuildContext context, bool isDark) {
    return PressableScale(
      onPressed: () => MonitoringHistoryModal.show(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: AppRadii.rLg,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyanBlue.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cyanBlue.withValues(alpha: 0.12),
                borderRadius: AppRadii.rMd,
              ),
              child: const Icon(Icons.insights_rounded, color: AppColors.cyanBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat & Analitika Sensor',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Buka rekap 24 jam & grafik fluktuasi harian',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.cyanBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
      ],
    );
  }
}
