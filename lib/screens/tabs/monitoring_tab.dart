import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../models/telemetry_data.dart';
import '../../services/mqtt_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/monitoring_history_modal.dart';
import '../../widgets/pressable_scale.dart';

class MonitoringTab extends StatelessWidget {
  const MonitoringTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<TelemetryController>();
    final telemetry = controller.telemetry;
    final isConnected = controller.connectionStatus == MqttConnectionStateStatus.connected;
    final isConnecting = controller.connectionStatus == MqttConnectionStateStatus.connecting;

    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
          children: [
            // Page Header
            _buildPageHeader(isDark, textPrimary, textSecondary, controller.freshnessText),

            const SizedBox(height: 16),

            // Connection State Banner if not connected
            if (!isConnected)
              _buildConnectionBanner(isConnecting, controller, isDark),

            // A. FLOOD MONITORING SECTION (High Priority)
            _buildFloodMonitoringSection(telemetry, isDark, cardBg, border, textPrimary, textSecondary),

            const SizedBox(height: 18),

            // B. WEATHER & MICROCLIMATE
            _buildWeatherSection(telemetry, isDark, cardBg, border, textPrimary, textSecondary),

            const SizedBox(height: 18),

            // C. AIR QUALITY (MQ-135)
            _buildAirQualitySection(telemetry, isDark, cardBg, border, textPrimary, textSecondary),

            const SizedBox(height: 18),

            // D. DEVICE HARDWARE & CONNECTIVITY
            _buildDeviceDiagnostics(controller, telemetry, isDark, cardBg, border, textPrimary, textSecondary),

            const SizedBox(height: 18),

            // E. HISTORICAL ANALYTICS ACTION
            _buildAnalyticsBanner(context, isDark),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PAGE HEADER
  // ==========================================
  Widget _buildPageHeader(bool isDark, Color textPrimary, Color textSecondary, String freshness) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MONITORING LINGKUNGAN',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Stasiun Telemetri Alun-Alun Kota Tegal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: AppRadii.rPill,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.cyanBlue),
              const SizedBox(width: 4),
              Text(
                freshness,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CONNECTION WARNING BANNER
  // ==========================================
  Widget _buildConnectionBanner(bool isConnecting, TelemetryController controller, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isConnecting ? AppColors.warningBgLight : AppColors.criticalBgLight,
        borderRadius: AppRadii.rLg,
        border: Border.all(
          color: (isConnecting ? AppColors.warning : AppColors.critical).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnecting ? Icons.sync_rounded : Icons.cloud_off_rounded,
            color: isConnecting ? AppColors.warning : AppColors.critical,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isConnecting
                  ? 'Sedang menghubungkan ke broker MQTT...'
                  : 'Koneksi terputus. Menampilkan data terakhir yang tersimpan.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isConnecting ? const Color(0xFF92400E) : const Color(0xFF991B1B),
              ),
            ),
          ),
          if (!isConnecting)
            TextButton(
              onPressed: () => controller.retryConnection(),
              child: const Text('Hubungkan'),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // A. FLOOD MONITORING
  // ==========================================
  Widget _buildFloodMonitoringSection(
    TelemetryData? telemetry,
    bool isDark,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final hasData = telemetry != null;
    final isWarning = telemetry?.isFloodWarning ?? false;
    final waterLevel = telemetry?.waterLevelCm ?? 0.0;
    final waterDistance = telemetry?.waterDistanceCm ?? 0.0;
    final status = telemetry?.floodStatus ?? 'Menunggu Sensor';

    Color statusColor = AppColors.safe;
    if (waterLevel >= 35.0) {
      statusColor = AppColors.critical;
    } else if (waterLevel >= 20.0) {
      statusColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadii.rXl,
        border: Border.all(
          color: isWarning ? AppColors.critical.withValues(alpha: 0.5) : border,
          width: isWarning ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isWarning
                ? AppColors.critical.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Label & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.cyanBlue.withValues(alpha: 0.12),
                      borderRadius: AppRadii.rSm,
                    ),
                    child: const Icon(Icons.waves_rounded, size: 16, color: AppColors.cyanBlue),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DETEKSI GENANGAN & BANJIR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.cyanBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.rPill,
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Main Measurement Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                hasData ? waterLevel.toStringAsFixed(1) : '--.-',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: isWarning ? AppColors.critical : textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'cm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Jarak Sensor Probe',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: textSecondary,
                    ),
                  ),
                  Text(
                    hasData ? '${waterDistance.toStringAsFixed(1)} cm' : '-- cm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Reference Threshold Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: hasData ? (waterLevel / 50.0).clamp(0.0, 1.0) : 0.0,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Threshold Indicator Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Aman (<20 cm)', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.safe)),
              Text('Waspada (20-34 cm)', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.warning)),
              Text('Siaga (≥35 cm)', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.critical)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // B. WEATHER & CLIMATE
  // ==========================================
  Widget _buildWeatherSection(
    TelemetryData? telemetry,
    bool isDark,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final hasData = telemetry != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadii.rXl,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.ecoGreen.withValues(alpha: 0.12),
                  borderRadius: AppRadii.rSm,
                ),
                child: const Icon(Icons.wb_sunny_rounded, size: 16, color: AppColors.ecoGreen),
              ),
              const SizedBox(width: 8),
              Text(
                'CUACA & IKLIM MIKRO',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.ecoGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              // Temperature
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Suhu Udara', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      hasData ? '${telemetry.temperatureC.toStringAsFixed(1)}°C' : '--°C',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    Text('DHT22 Sensor', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: textSecondary)),
                  ],
                ),
              ),

              // Divider
              Container(width: 1, height: 38, color: border),

              // Humidity
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kelembaban', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        hasData ? '${telemetry.humidityPercent.toStringAsFixed(0)}%' : '--%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      Text('Uap Relatif', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: textSecondary)),
                    ],
                  ),
                ),
              ),

              // Divider
              Container(width: 1, height: 38, color: border),

              // Rain Sensor
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hujan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        hasData ? (telemetry.isRaining ? 'Hujan' : 'Kering') : '--',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: hasData && telemetry.isRaining ? AppColors.cyanBlue : AppColors.safe,
                        ),
                      ),
                      Text('Sensor Plat', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: textSecondary)),
                    ],
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
  // C. AIR QUALITY (MQ-135)
  // ==========================================
  Widget _buildAirQualitySection(
    TelemetryData? telemetry,
    bool isDark,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final hasData = telemetry != null;
    final mqRaw = telemetry?.mq135Raw ?? 0;
    final airStatus = telemetry?.airQualityStatus ?? 'Normal / Baik';
    final isPolluted = telemetry?.isGasPolluted ?? false;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadii.rXl,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      borderRadius: AppRadii.rSm,
                    ),
                    child: const Icon(Icons.air_rounded, size: 16, color: Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KUALITAS UDARA (GAS MQ-135)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPolluted ? AppColors.critical : AppColors.safe).withValues(alpha: 0.12),
                  borderRadius: AppRadii.rPill,
                ),
                child: Text(
                  airStatus,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isPolluted ? AppColors.critical : AppColors.safe,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    hasData ? '$mqRaw' : '---',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ADC Raw (0-4095)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                'Tegangan: ${telemetry != null ? (telemetry.mq135AdcMv / 1000).toStringAsFixed(2) : '--'} V',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            '*Catatan teknis: Pembacaan merupakan sinyal analog langsung dari sensor MQ-135 yang sensitif terhadap gas amonia, asap kendaraan, dan CO2 di ruang terbuka.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // D. DEVICE HARDWARE & DIAGNOSTICS
  // ==========================================
  Widget _buildDeviceDiagnostics(
    TelemetryController controller,
    TelemetryData? telemetry,
    bool isDark,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadii.rXl,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.memory_rounded, size: 16, color: AppColors.cyanBlue),
              const SizedBox(width: 6),
              Text(
                'INFORMASI PERANGKAT IOT (ESP32-S3)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ID Perangkat:', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: textSecondary)),
              Text(
                telemetry?.deviceId ?? 'esp32s3-node',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sinyal Wi-Fi (RSSI):', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: textSecondary)),
              Text(
                telemetry != null ? '${telemetry.wifiRssiDbm} dBm' : '-- dBm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Waktu Aktif (Uptime):', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: textSecondary)),
              Text(
                telemetry != null ? '${telemetry.uptimeSeconds ~/ 3600}h ${(telemetry.uptimeSeconds % 3600) ~/ 60}m' : '--',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // E. ANALYTICS BANNER
  // ==========================================
  Widget _buildAnalyticsBanner(BuildContext context, bool isDark) {
    return PressableScale(
      onPressed: () => MonitoringHistoryModal.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: AppRadii.rLg,
          boxShadow: [
            BoxShadow(
              color: AppColors.cyanBlue.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buka Analitika Riwayat 24 Jam',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Lihat fluktuasi grafik & rekap log per jam',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
