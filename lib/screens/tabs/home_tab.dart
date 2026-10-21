import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/monitoring_history_modal.dart';
import '../../widgets/pressable_scale.dart';
import '../login_screen.dart';

class HomeTab extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const HomeTab({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  Function(int) get onNavigateToTab => widget.onNavigateToTab;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

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

  void _showProfileModal(BuildContext context, bool isDark) {
    final auth = AuthService.instance;
    final email = auth.currentUserEmail ?? 'user@gmail.com';
    final name = auth.currentUserName ?? 'Operator Smart City';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // User Avatar & Info
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: AppColors.cyan,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Operator Smart City Tegal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyan,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Logout Button
            PressableScale(
              onTap: () async {
                Navigator.of(ctx).pop();
                await AuthService.instance.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Keluar dari Akun (Logout)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<TelemetryController>();
    final telemetry = controller.telemetry;
    final hasData = controller.hasData && telemetry != null;
    final isConnected = controller.connectionStatus.toString().contains('connected');

    final temp = telemetry?.temperatureC;
    final humidity = telemetry?.humidityPercent;
    final mq135 = telemetry?.mq135Raw;
    final isRaining = telemetry?.isRaining ?? false;
    final waterLevel = telemetry?.waterLevelCm;
    final isFloodWarning = telemetry?.isFloodWarning ?? false;
    final isAirPolluted = telemetry?.isGasPolluted ?? false;

    // Safety status
    final bool isAllSafe = isConnected && hasData && !isFloodWarning && !isAirPolluted;
    final String cityStatusTitle = !isConnected
        ? 'Offline'
        : !hasData
            ? 'Sinkronisasi'
            : (isFloodWarning || isAirPolluted)
                ? 'Perlu Perhatian'
                : 'Aman';
    final String cityStatusSubtitle = !isConnected
        ? 'Menghubungkan ke broker MQTT...'
        : !hasData
            ? 'Terhubung ke broker, menanti data sensor ESP32...'
            : isFloodWarning
                ? 'Waspada potensi genangan air sungai'
                : isAirPolluted
                    ? 'Indeks udara terdeteksi menurun'
                    : 'Semua sistem terpantau normal';
    final Color statusColor = !isConnected
        ? AppColors.warning
        : !hasData
            ? AppColors.cyan
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
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Top App Header (Full Logo + Title + Notification + Avatar)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Full Logo & Name
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart City',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'Tegal',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
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
                                        color: AppColors.green.withValues(alpha: 0.5),
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

                          // Profile Avatar (Tappable to view Profile & Logout)
                          PressableScale(
                            onTap: () => _showProfileModal(context, isDark),
                            child: Container(
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. UNIFIED CURVED HERO CARD (No overlapping cuts, perfectly joined)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Top Photo Area
                        SizedBox(
                          height: 155,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 3D Parallax & Stretch Zoom Depth Image
                              Transform.translate(
                                offset: Offset(0, _scrollOffset > 0 ? -(_scrollOffset * 0.35) : 0),
                                child: Transform.scale(
                                  scale: _scrollOffset < 0
                                      ? (1.18 + (_scrollOffset.abs() / 250))
                                      : 1.18,
                                  child: Image.asset(
                                    'assets/images/hero-alun-alun.jpeg',
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ),
                              ),


                              // Gradient Overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.15),
                                      Colors.black.withValues(alpha: 0.70),
                                    ],
                                  ),
                                ),
                              ),

                              // Texts & Weather Pill inside Photo
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Weather Pill at top right
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
                                                hasData
                                                    ? '${temp!.toStringAsFixed(0)}°C ${isRaining ? "Hujan" : "Cerah Berawan"}'
                                                    : (isConnected ? 'Sinkronisasi...' : 'Offline'),
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

                                    // Bottom Greeting & Date
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_getTimeGreeting()}\nTegal',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.15,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _getCurrentDateFormatted(),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(alpha: 0.90),
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

                        // Seamless Status Bar (Unified bottom part, completely legible)
                        PressableScale(
                          onTap: () => onNavigateToTab(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.verified_user_rounded,
                                    size: 22,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Kondisi Kota: ',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            cityStatusTitle,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
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
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.10),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // 3. MONITORING LINGKUNGAN (Tampil Langsung di Beranda!)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Monitoring Lingkungan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      PressableScale(
                        onTap: () => onNavigateToTab(1),
                        child: Text(
                          'Lihat Semua →',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // 4 Sensors Grid (2x2)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Row 1: Suhu & Kelembaban
                      Row(
                        children: [
                          Expanded(
                            child: _buildSensorMetricCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.thermostat_rounded,
                              iconColor: AppColors.cyan,
                              iconBg: AppColors.cyan.withValues(alpha: 0.12),
                              label: 'Suhu Udara',
                              value: hasData ? '${temp!.toStringAsFixed(1)}°C' : '--°C',
                              statusBadge: hasData ? (temp! > 33 ? 'Panas' : 'Normal') : 'Menunggu',
                              badgeColor: hasData
                                  ? (temp! > 33 ? AppColors.warning : AppColors.green)
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              onTap: () => onNavigateToTab(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSensorMetricCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.water_drop_rounded,
                              iconColor: const Color(0xFF0284C7),
                              iconBg: const Color(0xFF0284C7).withValues(alpha: 0.12),
                              label: 'Kelembaban',
                              value: hasData ? '${humidity!.toStringAsFixed(0)}%' : '--%',
                              statusBadge: hasData ? 'Optimal' : 'Menunggu',
                              badgeColor: hasData
                                  ? AppColors.green
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              onTap: () => onNavigateToTab(1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 2: Gas MQ-135 & Status Hujan
                      Row(
                        children: [
                          Expanded(
                            child: _buildSensorMetricCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.eco_rounded,
                              iconColor: isAirPolluted ? AppColors.warning : AppColors.green,
                              iconBg: (isAirPolluted ? AppColors.warning : AppColors.green).withValues(alpha: 0.12),
                              label: 'Kualitas Udara',
                              value: hasData ? '$mq135 PPM' : '-- PPM',
                              statusBadge: hasData ? (isAirPolluted ? 'Perlu Waspada' : 'Udara Bersih') : 'Menunggu',
                              badgeColor: hasData
                                  ? (isAirPolluted ? AppColors.warning : AppColors.green)
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              onTap: () => onNavigateToTab(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSensorMetricCard(
                              context: context,
                              isDark: isDark,
                              icon: isRaining ? Icons.umbrella_rounded : Icons.wb_sunny_rounded,
                              iconColor: isRaining ? const Color(0xFF2563EB) : Colors.amber.shade700,
                              iconBg: (isRaining ? const Color(0xFF2563EB) : Colors.amber).withValues(alpha: 0.12),
                              label: 'Status Hujan',
                              value: hasData ? (isRaining ? 'Hujan' : 'Cerah') : '--',
                              statusBadge: hasData ? (isRaining ? 'Basah' : 'Kering') : 'Menunggu',
                              badgeColor: hasData
                                  ? (isRaining ? AppColors.cyan : AppColors.green)
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              onTap: () => onNavigateToTab(1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Ketinggian Air Sungai & Riwayat
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PressableScale(
                    onTap: () => MonitoringHistoryModal.show(context),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: (isFloodWarning ? AppColors.danger : AppColors.cyan).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.waves_rounded,
                                      size: 18,
                                      color: isFloodWarning ? AppColors.danger : AppColors.cyan,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ketinggian Air Sungai',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Peringatan Dini Banjir',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Riwayat 24 Jam',
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Mini Sparkline Graph
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 52,
                                  child: CustomPaint(
                                    painter: _HomeSparklinePainter(
                                      color: isFloodWarning ? AppColors.danger : AppColors.cyan,
                                      isDark: isDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Water Level Text
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      hasData ? '${waterLevel!.toStringAsFixed(0)} cm' : '-- cm',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: hasData
                                            ? (isFloodWarning ? AppColors.danger : AppColors.green).withValues(alpha: 0.12)
                                            : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        hasData
                                            ? (isFloodWarning ? 'Waspada Banjir' : 'Bebas Banjir')
                                            : 'Menunggu Data',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: hasData
                                              ? (isFloodWarning ? AppColors.danger : AppColors.green)
                                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                        ),
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

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // 4. LAYANAN KOTA (Parkir & Penerangan Jalan dengan Animasi Berpindah)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Layanan Fasilitas Kota',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // 2 Interactive Feature Cards: Parkir & PJU
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  child: Row(
                    children: [
                      // Parkir Cerdas Card
                      Expanded(
                        child: PressableScale(
                          onTap: () => onNavigateToTab(2), // Animated jump to Parkir Tab
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.cyan,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Parkir Cerdas',
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
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Slot Kosong Tersedia',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: AppColors.cyan,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Penerangan (PJU) Card
                      Expanded(
                        child: PressableScale(
                          onTap: () => onNavigateToTab(3), // Animated jump to Lamp Tab
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.cyan,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Penerangan (PJU)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeRelays > 0 ? '$activeRelays Zona Nyala' : 'Padam',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: activeRelays > 0
                                        ? AppColors.green
                                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                  ),
                                ),
                                Text(
                                  controller.isAutoMode ? 'Mode Sensor Otomatis' : 'Mode Manual',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorMetricCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String statusBadge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusBadge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
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
