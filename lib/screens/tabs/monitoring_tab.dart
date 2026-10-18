import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/monitoring_history_modal.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/staggered_entrance.dart';

class MonitoringTab extends StatefulWidget {
  const MonitoringTab({super.key});

  @override
  State<MonitoringTab> createState() => _MonitoringTabState();
}

class _MonitoringTabState extends State<MonitoringTab> {
  int _selectedSegment = 0; // 0: Lingkungan, 1: Riwayat, 2: Perangkat

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<TelemetryController>();
    final telemetry = controller.telemetry;
    final hasData = controller.hasData && telemetry != null;
    final isConnected = controller.connectionStatus.toString().contains('connected');

    final waterLevel = telemetry?.waterLevelCm;
    final isFlood = telemetry?.isFloodWarning ?? false;
    final temp = telemetry?.temperatureC;
    final humidity = telemetry?.humidityPercent;
    final isRaining = telemetry?.isRaining ?? false;
    final isAirPolluted = telemetry?.isGasPolluted ?? false;
    final airQualityStatus = telemetry?.airQualityStatus ?? (isAirPolluted ? 'Sedang' : 'Baik');

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header: Title "Monitoring"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Monitoring',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Top Segmented Tabs: "Lingkungan", "Riwayat", "Perangkat"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    _buildSegmentItem(0, 'Lingkungan'),
                    _buildSegmentItem(1, 'Riwayat'),
                    _buildSegmentItem(2, 'Perangkat'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Segmented Tab Content
            Expanded(
              child: _selectedSegment == 0
                  ? _buildLingkunganList(
                      isDark: isDark,
                      hasData: hasData,
                      waterLevel: waterLevel,
                      isFlood: isFlood,
                      temp: temp,
                      humidity: humidity,
                      isRaining: isRaining,
                      isAirPolluted: isAirPolluted,
                      airQualityStatus: airQualityStatus,
                      isConnected: isConnected,
                    )
                  : _selectedSegment == 1
                      ? _buildRiwayatView(isDark)
                      : _buildPerangkatView(isDark, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem(int index, String label) {
    final isSelected = _selectedSegment == index;
    return Expanded(
      child: PressableScale(
        onTap: () {
          setState(() {
            _selectedSegment = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyan : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLingkunganList({
    required bool isDark,
    required bool hasData,
    required double? waterLevel,
    required bool isFlood,
    required double? temp,
    required double? humidity,
    required bool isRaining,
    required bool isAirPolluted,
    required String airQualityStatus,
    required bool isConnected,
  }) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        // 1. Ketinggian Air
        StaggeredEntrance(
          index: 0,
          child: _buildMetricItem(
            isDark: isDark,
            icon: Icons.waves_rounded,
            iconColor: AppColors.cyan,
            iconBg: AppColors.cyan.withValues(alpha: 0.12),
            title: 'Ketinggian Air',
            value: hasData ? '${waterLevel!.toStringAsFixed(0)} cm' : '-- cm',
            status: hasData ? (isFlood ? 'Waspada' : 'Normal') : 'Menunggu',
            statusColor: hasData
                ? (isFlood ? AppColors.danger : AppColors.green)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            showSparkline: true,
            onTap: () => MonitoringHistoryModal.show(context),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Suhu Udara
        StaggeredEntrance(
          index: 1,
          child: _buildMetricItem(
            isDark: isDark,
            icon: Icons.thermostat_rounded,
            iconColor: Colors.deepOrangeAccent,
            iconBg: Colors.deepOrangeAccent.withValues(alpha: 0.12),
            title: 'Suhu Udara',
            value: hasData ? '${temp!.toStringAsFixed(1)}°C' : '--°C',
            status: hasData ? (temp! > 33 ? 'Panas' : 'Normal') : 'Menunggu',
            statusColor: hasData
                ? (temp! > 33 ? AppColors.warning : AppColors.green)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            showSparkline: true,
            onTap: () => MonitoringHistoryModal.show(context),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Kelembapan
        StaggeredEntrance(
          index: 2,
          child: _buildMetricItem(
            isDark: isDark,
            icon: Icons.water_drop_rounded,
            iconColor: Colors.blueAccent,
            iconBg: Colors.blueAccent.withValues(alpha: 0.12),
            title: 'Kelembapan',
            value: hasData ? '${humidity!.toStringAsFixed(0)}%' : '--%',
            status: hasData ? 'Optimal' : 'Menunggu',
            statusColor: hasData
                ? AppColors.green
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            showSparkline: false,
            onTap: () => MonitoringHistoryModal.show(context),
          ),
        ),
        const SizedBox(height: 12),

        // 4. Deteksi Hujan
        StaggeredEntrance(
          index: 3,
          child: _buildMetricItem(
            isDark: isDark,
            icon: Icons.cloud_rounded,
            iconColor: AppColors.cyan,
            iconBg: AppColors.cyan.withValues(alpha: 0.12),
            title: 'Deteksi Hujan',
            value: hasData ? (isRaining ? 'Hujan' : 'Tidak Hujan') : '--',
            status: hasData ? (isRaining ? 'Hati-hati' : 'Aman') : 'Menunggu',
            statusColor: hasData
                ? (isRaining ? AppColors.warning : AppColors.green)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            showSparkline: false,
            onTap: () => MonitoringHistoryModal.show(context),
          ),
        ),
        const SizedBox(height: 12),

        // 5. Kualitas Udara
        StaggeredEntrance(
          index: 4,
          child: _buildMetricItem(
            isDark: isDark,
            icon: Icons.eco_rounded,
            iconColor: AppColors.green,
            iconBg: AppColors.green.withValues(alpha: 0.12),
            title: 'Kualitas Udara',
            value: hasData ? airQualityStatus : '--',
            status: hasData ? (isAirPolluted ? 'Perhatian' : 'Normal') : 'Menunggu',
            statusColor: hasData
                ? (isAirPolluted ? AppColors.warning : AppColors.green)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            showSparkline: false,
            onTap: () => MonitoringHistoryModal.show(context),
          ),
        ),

      ],
    );
  }

  Widget _buildMetricItem({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required String status,
    required Color statusColor,
    required bool showSparkline,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    status,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            if (showSparkline)
              Container(
                width: 60,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                child: CustomPaint(
                  painter: _MonitoringSparklinePainter(color: iconColor),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.insights_rounded, size: 48, color: AppColors.cyan),
              const SizedBox(height: 12),
              Text(
                'Analitik Riwayat Sensor',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lihat rekapan 24 jam untuk ketinggian air, suhu, kelembapan, dan kualitas udara per tanggal kalender pilihan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              PressableScale(
                onTap: () => MonitoringHistoryModal.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.analytics_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Buka Grafik Riwayat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerangkatView(bool isDark, TelemetryController controller) {
    final telemetry = controller.telemetry;
    final isConnected = controller.connectionStatus.toString().contains('connected');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diagnostik Mikrokontroler (ESP32)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              _buildTechRow('Device ID', telemetry?.deviceId ?? 'ESP32_TEGAL_01', isDark),
              _buildTechRow('MQTT Broker', 'broker.hivemq.com (Port 1883/8884)', isDark),
              _buildTechRow('Status Koneksi', isConnected ? 'Terhubung (Online)' : 'Terputus (Offline)', isDark),
              _buildTechRow('Data Terakhir', controller.freshnessText, isDark),
              _buildTechRow('WiFi RSSI', '${telemetry?.wifiRssiDbm ?? -58} dBm', isDark),
              _buildTechRow('Uptime', '${telemetry?.uptimeSeconds ?? 1240} detik', isDark),
              _buildTechRow('MQ-135 ADC', '${telemetry?.mq135Raw ?? 142} (0-4095)', isDark),
              _buildTechRow('LDR ADC', '${telemetry?.ldrRaw ?? 340} (0-4095)', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringSparklinePainter extends CustomPainter {
  final Color color;

  _MonitoringSparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.7);
    path.quadraticBezierTo(w * 0.35, h * 0.9, w * 0.5, h * 0.3);
    path.quadraticBezierTo(w * 0.75, h * 0.1, w, h * 0.35);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
