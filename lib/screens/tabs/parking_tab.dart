import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/parking_lot_visualizer.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/staggered_entrance.dart';

class ParkingTab extends StatefulWidget {
  const ParkingTab({super.key});

  @override
  State<ParkingTab> createState() => _ParkingTabState();
}

class _ParkingTabState extends State<ParkingTab> {
  final GlobalKey<ParkingLotVisualizerState> _visualizerKey = GlobalKey<ParkingLotVisualizerState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TelemetryController>(
      builder: (context, controller, child) {
        // Live Hardware Telemetry from ESP32 & MQTT Broker
        const total = 9;
        final occupied = controller.parkingOccupiedSlots.clamp(0, total);
        final available = (total - occupied).clamp(0, total);
        final isEntryGateOpen = controller.isEntryGateOpen;
        final isExitGateOpen = controller.isExitGateOpen;
        final isIrEntryActive = controller.isIrEntryDetected;
        final isIrExitActive = controller.isIrExitDetected;
        final isOnline = controller.connectionStatus.toString().contains('connected');
        final percentAvailable = ((available / (total == 0 ? 1 : total)) * 100).toInt();

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header Bar with Realtime Status Badge & Reset
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Parking IoT',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Sinkronisasi Sensor IR & Servo ESP32 (MQTT Live)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Live Status Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: (isOnline ? AppColors.green : AppColors.warning).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: (isOnline ? AppColors.green : AppColors.warning).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOnline ? AppColors.green : AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isOnline ? 'MQTT LIVE' : 'OFFLINE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isOnline ? AppColors.green : AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Reset / Calibration button
                            PressableScale(
                              onTap: () => _confirmReset(context, controller),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.refresh_rounded, size: 14, color: AppColors.cyan),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reset',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.cyan,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Metrics Cards Row
                SliverToBoxAdapter(
                  child: StaggeredEntrance(
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Card 1: Slot Tersedia
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Slot Tersedia',
                              value: '$available',
                              suffix: '/ $total',
                              icon: Icons.local_parking_rounded,
                              iconColor: AppColors.green,
                              subtext: '$percentAvailable% Ruang Kosong',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Card 2: Slot Terisi
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Slot Terisi',
                              value: '$occupied',
                              suffix: '/ $total',
                              icon: Icons.directions_car_filled_rounded,
                              iconColor: occupied >= total ? AppColors.danger : AppColors.cyan,
                              subtext: occupied >= total ? 'Parkir Penuh' : 'Kapasitas Normal',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Visual Parking Lot Layout (Realtime synchronized with ESP32)
                SliverToBoxAdapter(
                  child: StaggeredEntrance(
                    index: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section title & Sensor State Tag
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: occupied >= total ? AppColors.danger : AppColors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'DENAH AREA PARKIR (9 SLOT)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (isIrEntryActive || isIrExitActive ? AppColors.warning : AppColors.cyan)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isIrEntryActive
                                        ? '⚡ IR MASUK AKTIF'
                                        : (isIrExitActive
                                            ? '⚡ IR KELUAR AKTIF'
                                            : '● REALTIME HARDWARE'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isIrEntryActive || isIrExitActive ? AppColors.warning : AppColors.cyan,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // The Custom Top-Down Visualizer (directly fed with occupiedCount)
                            ParkingLotVisualizer(
                              key: _visualizerKey,
                              occupiedCount: occupied,
                              occupiedSlots: null,
                              totalCount: total,
                              isEntryGateOpen: isEntryGateOpen,
                              isExitGateOpen: isExitGateOpen,
                              onSlotTap: (slot, isOccupied) {
                                _showSlotDetailModal(context, slot, isOccupied, controller, isDark);
                              },
                              onEntryGateTap: () {
                                controller.toggleEntryGate();
                              },
                              onExitGateTap: () {
                                controller.toggleExitGate();
                              },
                            ),

                            const SizedBox(height: 14),

                            // Map Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(AppColors.green, 'Kosong'),
                                const SizedBox(width: 14),
                                _buildLegendItem(AppColors.danger, 'Ada Mobil'),
                                const SizedBox(width: 14),
                                _buildLegendItem(AppColors.cyan, 'Palang Pintu (Sentuh)'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Hardware Live Sensor & Servo Status Cards
                SliverToBoxAdapter(
                  child: StaggeredEntrance(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Sensor & Servo Alat (ESP32)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // IR Entry Sensor Card
                              Expanded(
                                child: _buildSensorStatusCard(
                                  title: 'Sensor IR Masuk',
                                  isActive: isIrEntryActive,
                                  activeText: 'Mobil Terdeteksi',
                                  inactiveText: 'Jalur Bersih (Standby)',
                                  icon: Icons.sensors_rounded,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // IR Exit Sensor Card
                              Expanded(
                                child: _buildSensorStatusCard(
                                  title: 'Sensor IR Keluar',
                                  isActive: isIrExitActive,
                                  activeText: 'Mobil Terdeteksi',
                                  inactiveText: 'Jalur Bersih (Standby)',
                                  icon: Icons.sensors_rounded,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Gate Servo Controls (Entry & Exit)
                          _buildGateCard(
                            title: 'Servo Palang Masuk (IN)',
                            subtitle: isEntryGateOpen
                                ? 'Palang Terbuka (90°) • Kendaraan Lewat'
                                : 'Palang Tertutup (0°) • Menunggu Sensor IR',
                            isOpen: isEntryGateOpen,
                            isDark: isDark,
                            onToggle: () => controller.toggleEntryGate(),
                          ),
                          const SizedBox(height: 10),
                          _buildGateCard(
                            title: 'Servo Palang Keluar (OUT)',
                            subtitle: isExitGateOpen
                                ? 'Palang Terbuka (90°) • Kendaraan Lewat'
                                : 'Palang Tertutup (0°) • Menunggu Sensor IR',
                            isOpen: isExitGateOpen,
                            isDark: isDark,
                            onToggle: () => controller.toggleExitGate(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Action & Trigger Hardware Test Panel
                SliverToBoxAdapter(
                  child: StaggeredEntrance(
                    index: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                                Text(
                                  'Uji Coba & Simulasi Trigger Alat',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'MQTT TRIGGER',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.cyan,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gunakan tombol di bawah untuk menguji pergerakan palang servo dan kuota slot jika belum ada mobil fisik melintas di depan sensor IR.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Action Buttons: Car In & Car Out
                            Row(
                              children: [
                                // Mobil Masuk
                                Expanded(
                                  child: PressableScale(
                                    onTap: occupied >= total
                                        ? null
                                        : () {
                                            final nextSlot = occupied + 1;
                                            _visualizerKey.currentState?.animateCarEnteringSlot(nextSlot);
                                            controller.simulateCarEntry();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: AppColors.green,
                                                content: Text('Trigger IR Masuk: Palang buka -> Mobil masuk Slot P$nextSlot'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: (occupied >= total ? Colors.grey : AppColors.green).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: (occupied >= total ? Colors.grey : AppColors.green).withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_car_rounded,
                                            size: 16,
                                            color: occupied >= total ? Colors.grey : AppColors.green,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Trigger Masuk (+1)',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: occupied >= total ? Colors.grey : AppColors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Mobil Keluar
                                Expanded(
                                  child: PressableScale(
                                    onTap: occupied <= 0
                                        ? null
                                        : () {
                                            controller.simulateCarExit();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                backgroundColor: AppColors.danger,
                                                content: Text('Trigger IR Keluar: Palang buka -> 1 Mobil keluar'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: (occupied <= 0 ? Colors.grey : AppColors.danger).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: (occupied <= 0 ? Colors.grey : AppColors.danger).withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.logout_rounded,
                                            size: 16,
                                            color: occupied <= 0 ? Colors.grey : AppColors.danger,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Trigger Keluar (-1)',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: occupied <= 0 ? Colors.grey : AppColors.danger,
                                            ),
                                          ),
                                        ],
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
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 110),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorStatusCard({
    required String title,
    required bool isActive,
    required String activeText,
    required String inactiveText,
    required IconData icon,
    required bool isDark,
  }) {
    final statusColor = isActive ? AppColors.warning : AppColors.green;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? statusColor.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.border),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? statusColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: statusColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'TERDETEKSI' : 'STANDBY',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isActive ? activeText : inactiveText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String suffix,
    required IconData icon,
    required Color iconColor,
    required String subtext,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                suffix,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF748391),
          ),
        ),
      ],
    );
  }

  Widget _buildGateCard({
    required String title,
    required String subtitle,
    required bool isOpen,
    required bool isDark,
    required VoidCallback onToggle,
  }) {
    final statusColor = isOpen ? AppColors.green : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen ? AppColors.green.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.border),
          width: isOpen ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isOpen ? AppColors.green : AppColors.cyan).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOpen ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: isOpen ? AppColors.green : AppColors.cyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          // Toggle Action
          PressableScale(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: (isOpen ? AppColors.green : AppColors.cyan).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isOpen ? AppColors.green : AppColors.cyan).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isOpen ? 'Tutup Palang' : 'Buka Palang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isOpen ? AppColors.green : AppColors.cyan,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSlotDetailModal(
    BuildContext context,
    ParkingSlotConfig slot,
    bool isOccupied,
    TelemetryController controller,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Header with Slot Name & Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (isOccupied ? AppColors.danger : AppColors.green).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isOccupied ? Icons.directions_car_filled_rounded : Icons.local_parking_rounded,
                        color: isOccupied ? AppColors.danger : AppColors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          slot.isTopRow ? 'Lantai Dasar • Sisi Utara' : 'Lantai Dasar • Sisi Selatan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isOccupied ? AppColors.danger : AppColors.green).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOccupied ? 'TERISI' : 'TERSEDIA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isOccupied ? AppColors.danger : AppColors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Car details or empty state
            if (isOccupied) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D27) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    // Car sprite thumbnail (oriented facing upwards)
                    SizedBox(
                      width: 50,
                      height: 70,
                      child: Transform.rotate(
                        angle: 3.141592653589793,
                        child: Image.asset(
                          slot.carAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.carModelName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Plat: ${slot.plateNumber}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cyan,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Status: Terpantau Sistem MQTT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PressableScale(
                onTap: () {
                  Navigator.pop(ctx);
                  controller.simulateCarExit();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      'Keluarkan Mobil dari Area Parkir',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D27) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 36, color: AppColors.green),
                    const SizedBox(height: 8),
                    Text(
                      'Slot Ini Siap Digunakan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kapasitas tersedia untuk kendaraan berikutnya.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PressableScale(
                onTap: () {
                  Navigator.pop(ctx);
                  _visualizerKey.currentState?.animateCarEnteringSlot(slot.id);
                  controller.simulateCarEntry();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Parkirkan Mobil ke Slot Ini (Uji Animasi & Servo)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, TelemetryController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.refresh_rounded, color: AppColors.cyan),
            const SizedBox(width: 8),
            Text(
              'Reset Kuota Parkir?',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Tindakan ini akan mengosongkan seluruh slot terisi (0/9) dan mengkalibrasi servo palang mikrokontroler.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await controller.resetParkingSlots();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: success ? AppColors.green : AppColors.danger,
                    content: Text(
                      success
                          ? 'Perintah reset parkir berhasil dikirim ke ESP32.'
                          : 'Gagal mengirim perintah reset ke broker.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            },
            child: const Text('Ya, Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
