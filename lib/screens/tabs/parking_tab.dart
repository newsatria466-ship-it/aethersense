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
        final total = controller.parkingTotalSlots;
        final occupied = controller.parkingOccupiedSlots;
        final available = controller.parkingAvailableSlots;
        final isOnline = controller.connectionStatus.toString().contains('connected');
        final percentAvailable = ((available / (total == 0 ? 1 : total)) * 100).toInt();

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Parking 2D',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Denah Real-Time & Sensor IR',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isOnline ? AppColors.green : AppColors.warning).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOnline ? AppColors.green : AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isOnline ? 'Online' : 'Offline',
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
                            // Reset button
                            PressableScale(
                              onTap: controller.isResettingParking
                                  ? null
                                  : () => _confirmReset(context, controller),
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

                // Visual Parking Lot Layout (User uploaded map with top-down cars)
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
                            // Section title & Live Status Pill
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
                                    color: (controller.isIrEntryDetected || controller.isIrExitDetected
                                            ? AppColors.cyan
                                            : AppColors.green)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    controller.isIrEntryDetected
                                        ? '⚡ IR MASUK DETEKSI'
                                        : (controller.isIrExitDetected ? '⚡ IR KELUAR DETEKSI' : '● SENSOR STANDBY'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: controller.isIrEntryDetected || controller.isIrExitDetected
                                          ? AppColors.cyan
                                          : AppColors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // The Custom Top-Down Visualizer
                            ParkingLotVisualizer(
                              key: _visualizerKey,
                              occupiedCount: occupied,
                              totalCount: total,
                              isEntryGateOpen: controller.isEntryGateOpen,
                              isExitGateOpen: controller.isExitGateOpen,
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
                                _buildLegendItem(AppColors.green, 'Kosong / Siap Parkir'),
                                const SizedBox(width: 14),
                                _buildLegendItem(AppColors.danger, 'Terisi (Ada Mobil)'),
                                const SizedBox(width: 14),
                                _buildLegendItem(AppColors.cyan, 'Palang Gerbang'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Interactive Quick Actions & Simulation Panel
                SliverToBoxAdapter(
                  child: StaggeredEntrance(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
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
                                  'Simulasi & Kontrol Gerbang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Ketuk untuk Uji Animasi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Action Buttons Row
                            Row(
                              children: [
                                // Simulasi Masuk
                                Expanded(
                                  child: PressableScale(
                                    onTap: occupied >= total
                                        ? null
                                        : () {
                                            final nextSlot = occupied + 1;
                                            _visualizerKey.currentState?.animateCarEnteringSlot(nextSlot);
                                            controller.simulateCarEntry();
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
                                            'Mobil Masuk',
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
                                // Simulasi Keluar
                                Expanded(
                                  child: PressableScale(
                                    onTap: occupied <= 0
                                        ? null
                                        : () {
                                            controller.simulateCarExit();
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
                                            'Mobil Keluar',
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

                // Gate Action Cards (Entry & Exit)
                SliverToBoxAdapter(
                  child: StaggeredEntrance(
                    index: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildGateCard(
                            title: 'Gerbang Masuk (IN)',
                            subtitle: 'Servo Palang IN & Sensor IR Masuk',
                            isOpen: controller.isEntryGateOpen,
                            isDark: isDark,
                            onToggle: () => controller.toggleEntryGate(),
                          ),
                          const SizedBox(height: 10),
                          _buildGateCard(
                            title: 'Gerbang Keluar (OUT)',
                            subtitle: 'Servo Palang OUT & Sensor IR Keluar',
                            isOpen: controller.isExitGateOpen,
                            isDark: isDark,
                            onToggle: () => controller.toggleExitGate(),
                          ),
                        ],
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
          color: isDark ? AppColors.borderDark : AppColors.border,
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
                    fontSize: 14,
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
                    // Car sprite thumbnail
                    SizedBox(
                      width: 50,
                      height: 70,
                      child: Image.asset(
                        slot.carAsset,
                        fit: BoxFit.contain,
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
                            'Sensor: IR Deteksi Aktif',
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
                      'Keluarkan Mobil dari Slot Ini',
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
                      'Belum ada objek kendaraan terdeteksi pada sensor IR slot ini.',
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
                      'Parkirkan Mobil ke Slot Ini (Uji Animasi)',
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
                          ? 'Perintah reset parkir berhasil dikirim.'
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
