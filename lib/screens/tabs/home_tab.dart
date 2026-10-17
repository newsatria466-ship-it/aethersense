import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../theme/app_theme.dart';
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
    final telemetry = controller.telemetry;
    final isConnected = controller.connectionStatus.toString().contains('connected');

    final temp = telemetry?.temperatureC ?? 28.0;
    final isRaining = telemetry?.isRaining ?? false;
    final waterLevel = telemetry?.waterLevelCm ?? 12.0;
    final isFloodWarning = telemetry?.isFloodWarning ?? false;
    final isAirPolluted = telemetry?.isGasPolluted ?? false;

    // Safety status
    final bool isAllSafe = isConnected && !isFloodWarning && !isAirPolluted;
    final String cityStatusTitle = !isConnected
        ? 'Offline'
        : (isFloodWarning || isAirPolluted)
            ? 'Perlu Perhatian'
            : 'Aman';
    final String cityStatusSubtitle = !isConnected
        ? 'Menunggu sinyal MQTT broker'
        : isFloodWarning
            ? 'Waspada potensi genangan air'
            : isAirPolluted
                ? 'Indeks udara terdeteksi menurun'
                : 'Semua sistem terpantau normal';
    final Color statusColor = !isConnected
        ? AppColors.warning
        : isAllSafe
            ? AppColors.green
            : AppColors.danger;

    final totalParking = controller.parkingTotalSlots;
    final availableParking = controller.parkingAvailableSlots;
    final activeRelays = controller.activeRelayCount;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.cyan,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Top App Header (Logo + Title + Notification + Avatar)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Logo & Name
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart City',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'Tegal',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: AppColors.cyan,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right Icons: Bell & Profile
                      Row(
                        children: [
                          // Pulse dot
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected ? AppColors.green : AppColors.warning,
                              boxShadow: isConnected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.green.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),

                          // Notification Bell
                          PressableScale(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isConnected
                                        ? 'Perangkat IoT Smart City Tegal aktif dan terhubung.'
                                        : 'Broker MQTT sedang mencoba rekoneksi otomatis.',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.border,
                                ),
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 20,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Profile Avatar
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cyan.withValues(alpha: 0.15),
                              border: Border.all(
                                color: AppColors.cyan.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 22,
                                color: AppColors.cyan,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Seamless Curved Header & Overlapping Status Card (matching dasbord.png)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Hero Photo Container (Curved edges)
                      Container(
                        height: 175,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/hero-alun-alun.jpeg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF1E3A8A),
                              ),
                            ),

                            // Gradient Overlay for readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.65),
                                  ],
                                ),
                              ),
                            ),

                            // Overlay Text: Greeting, Date, and Weather Pill
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Top Weather Pill
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.22),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isRaining
                                                  ? Icons.water_drop_rounded
                                                  : Icons.wb_sunny_rounded,
                                              size: 14,
                                              color: Colors.amberAccent,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${temp.toStringAsFixed(0)}°C ${isRaining ? "Hujan" : "Cerah Berawan"}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Bottom Greeting and Date
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_getTimeGreeting()}\nTegal',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getCurrentDateFormatted(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
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
                      ),

                      // OVERLAPPING CURVED CARD: "Kondisi Kota: Aman" (Menyatu & melengkung persis dasbord.png)
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: PressableScale(
                            onTap: () => onNavigateToTab(1), // Go to Monitoring Tab
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Green Shield Checkmark Icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.verified_user_rounded,
                                      size: 24,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Status Texts
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kondisi Kota',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          cityStatusTitle,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: statusColor,
                                          ),
                                        ),
                                        Text(
                                          cityStatusSubtitle,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Circular Action Chevron
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 20,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Quick Metric Cards (2 Columns: Parkir Tersedia & Penerangan)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Row(
                    children: [
                      // Parkir Tersedia
                      Expanded(
                        child: PressableScale(
                          onTap: () => onNavigateToTab(2), // Go to Parkir Tab
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.directions_car_filled_rounded,
                                    size: 20,
                                    color: AppColors.cyan,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Parkir Tersedia',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$availableParking / $totalParking',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Slot kosong',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Penerangan (PJU)
                      Expanded(
                        child: PressableScale(
                          onTap: () => onNavigateToTab(3), // Go to Lamp Tab
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: activeRelays > 0
                                        ? Colors.amber.withValues(alpha: 0.15)
                                        : AppColors.cyan.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_rounded,
                                    size: 20,
                                    color: activeRelays > 0 ? Colors.amber.shade700 : AppColors.cyan,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Penerangan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeRelays > 0 ? 'Aktif' : 'Padam',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: activeRelays > 0
                                        ? AppColors.green
                                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                  ),
                                ),
                                Text(
                                  '$activeRelays zona menyala',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Ringkasan Hari Ini (Sparkline Chart & Water Level Summary)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: PressableScale(
                    onTap: () => MonitoringHistoryModal.show(context),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ringkasan Hari Ini',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Buka Riwayat',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.cyan,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 10,
                                    color: AppColors.cyan,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              // Mini Sparkline Graph
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 60,
                                  child: CustomPaint(
                                    painter: _HomeSparklinePainter(
                                      color: AppColors.cyan,
                                      isDark: isDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Right Metric Text
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.cyan.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '+2cm',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.cyan,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ketinggian air',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '${waterLevel.toStringAsFixed(0)} cm',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      isFloodWarning ? 'Waspada' : 'Normal',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isFloodWarning ? AppColors.danger : AppColors.green,
                                      ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSparklinePainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _HomeSparklinePainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.75);
    path.cubicTo(w * 0.25, h * 0.85, w * 0.40, h * 0.20, w * 0.65, h * 0.35);
    path.cubicTo(w * 0.80, h * 0.45, w * 0.90, h * 0.10, w, h * 0.30);

    final fillPath = Path.from(path);
    fillPath.lineTo(w, h);
    fillPath.lineTo(0, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    canvas.drawCircle(Offset(w, h * 0.30), 4, Paint()..color = color);
    canvas.drawCircle(Offset(w, h * 0.30), 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
