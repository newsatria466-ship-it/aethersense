import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pressable_scale.dart';

class ParkingTab extends StatelessWidget {
  const ParkingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TelemetryController>(
      builder: (context, controller, child) {
        final total = controller.parkingTotalSlots;
        final occupied = controller.parkingOccupiedSlots;
        final available = controller.parkingAvailableSlots;
        final isFull = controller.isParkingFull;
        final isOnline = controller.isConnected;
        final isDelayed = controller.isTelemetryDelayed;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacings.m,
                      AppSpacings.m,
                      AppSpacings.m,
                      AppSpacings.s,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.cyan.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.local_parking_rounded,
                                        color: AppColors.cyan,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Smart Parking',
                                      style: AppTextStyles.h2.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kawasan Alun-Alun Tegal',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            // Reset button
                            PressableScale(
                              onTap: controller.isResettingParking
                                  ? null
                                  : () => _confirmReset(context, controller),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadii.sm),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: controller.isResettingParking
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.cyan,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.refresh_rounded,
                                            size: 15,
                                            color: AppColors.cyan,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Reset Kuota',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),

                        // Offline / delay warning banner
                        if (!isOnline) ...[
                          const SizedBox(height: AppSpacings.m),
                          _buildNoticeBanner(
                            icon: Icons.cloud_off_rounded,
                            title: 'Status: Sensor Offline',
                            message: 'Menunggu koneksi MQTT broker untuk data slot teranyar.',
                            color: AppColors.warning,
                          ),
                        ] else if (isDelayed) ...[
                          const SizedBox(height: AppSpacings.m),
                          _buildNoticeBanner(
                            icon: Icons.timer_outlined,
                            title: 'Telemetri Tertunda',
                            message: 'Data parkir terakhir: ${controller.freshnessText}',
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Occupancy Summary Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacings.m,
                      vertical: AppSpacings.s,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Tersedia',
                            value: '$available',
                            unit: 'Slot',
                            icon: Icons.check_circle_outline_rounded,
                            accentColor: isFull ? AppColors.textSecondary : AppColors.green,
                            subtitle: isFull ? 'Parkir Penuh' : 'Siap Digunakan',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Terisi',
                            value: '$occupied',
                            unit: 'Slot',
                            icon: Icons.directions_car_filled_rounded,
                            accentColor: occupied > 7 ? AppColors.danger : AppColors.cyan,
                            subtitle: 'Dari total $total slot',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Kapasitas',
                            value: '$total',
                            unit: 'Total',
                            icon: Icons.grid_view_rounded,
                            accentColor: AppColors.textPrimary,
                            subtitle: '${((occupied / (total == 0 ? 1 : total)) * 100).toInt()}% Utilisasi',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Gate & Barrier Status Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacings.m,
                      vertical: AppSpacings.s,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacings.m),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.sensor_door_outlined,
                                size: 18,
                                color: AppColors.cyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Status Palang Otomatis (Servo)',
                                style: AppTextStyles.bodyBold.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacings.m),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGateIndicator(
                                  title: 'Palang Masuk',
                                  isOpen: controller.isEntryGateOpen,
                                  isIrActive: controller.isIrEntryDetected,
                                  icon: Icons.login_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGateIndicator(
                                  title: 'Palang Keluar',
                                  isOpen: controller.isExitGateOpen,
                                  isIrActive: controller.isIrExitDetected,
                                  icon: Icons.logout_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Visual Slot Grid (10 Slots)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacings.m,
                      vertical: AppSpacings.s,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacings.m),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
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
                                'Denah Slot Parkir (1-10)',
                                style: AppTextStyles.bodyBold.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  _buildLegendItem(AppColors.green, 'Kosong'),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(AppColors.danger, 'Terisi'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacings.m),

                          // Parking Layout (2 Rows of 5)
                          Column(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  final slotNum = index + 1;
                                  final isSlotOccupied = slotNum <= occupied;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      child: _buildSlotCell(slotNum, isSlotOccupied),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),
                              // Driveway / Jalur Manuver
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Center(
                                  child: Text(
                                    '◄ ─── JALUR AKSES KENDARAAN ─── ►',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: List.generate(5, (index) {
                                  final slotNum = index + 6;
                                  final isSlotOccupied = slotNum <= occupied;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      child: _buildSlotCell(slotNum, isSlotOccupied),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Note info card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacings.m,
                      AppSpacings.s,
                      AppSpacings.m,
                      AppSpacings.xxl * 2, // Space for bottom bar
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacings.m),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.cyan,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sistem mendeteksi kendaraan secara real-time via sensor inframerah & portal gerbang otomatis Alun-Alun Tegal. Kuota dapat diatur ulang dari tombol reset di atas.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
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
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color accentColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                style: AppTextStyles.h2.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGateIndicator({
    required String title,
    required bool isOpen,
    required bool isIrActive,
    required IconData icon,
  }) {
    final statusColor = isOpen ? AppColors.green : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: isOpen ? AppColors.green.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: statusColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isOpen ? 'TERBUKA' : 'TERTUTUP',
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodyBold.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isIrActive ? AppColors.cyan : AppColors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isIrActive ? 'IR: Kendaraan Terdeteksi' : 'IR: Siaga Standby',
                style: AppTextStyles.caption.copyWith(
                  color: isIrActive ? AppColors.cyan : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCell(int number, bool isOccupied) {
    final cellColor = isOccupied ? AppColors.danger : AppColors.green;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: cellColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: cellColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '#$number',
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            isOccupied ? Icons.directions_car_filled_rounded : Icons.check_circle_rounded,
            size: 22,
            color: cellColor,
          ),
          const SizedBox(height: 4),
          Text(
            isOccupied ? 'TERISI' : 'KOSONG',
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: cellColor,
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeBanner({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.m),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, TelemetryController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        title: Row(
          children: [
            const Icon(Icons.refresh_rounded, color: AppColors.cyan),
            const SizedBox(width: 8),
            Text(
              'Reset Kuota Parkir?',
              style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Tindakan ini akan mengembalikan jumlah slot terisi menjadi 0/10 dan mengirimkan sinyal kalibrasi ke mikrokontroler.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
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
                          ? 'Perintah reset parkir berhasil dikirim ke perangkat.'
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
