import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pressable_scale.dart';

class ParkingTab extends StatelessWidget {
  const ParkingTab({super.key});

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
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Smart Parking',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
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

                // Top Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.directions_car_filled_rounded,
                              size: 24,
                              color: AppColors.cyan,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$available / $total',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Slot Tersedia',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$percentAvailable%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Visual Parking Lot Layout (P1 to P10)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top Row (P1 - P5)
                          Row(
                            children: List.generate(5, (index) {
                              final slotNum = index + 1;
                              final isOccupied = slotNum <= occupied;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: _buildParkingSlot(
                                    slotName: 'P$slotNum',
                                    isOccupied: isOccupied,
                                    isDark: isDark,
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 12),

                          // Driveway
                          Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1A24) : const Color(0xFFEEF2F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '◄   JALUR MASUK & KELUAR   ►',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF8C9BA8),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Bottom Row (P6 - P10)
                          Row(
                            children: List.generate(5, (index) {
                              final slotNum = index + 6;
                              final isOccupied = slotNum <= occupied;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: _buildParkingSlot(
                                    slotName: 'P$slotNum',
                                    isOccupied: isOccupied,
                                    isDark: isDark,
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 16),

                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(AppColors.green, 'Tersedia'),
                              const SizedBox(width: 16),
                              _buildLegendItem(AppColors.danger, 'Terisi'),
                              const SizedBox(width: 16),
                              _buildLegendItem(const Color(0xFF9E9E9E), 'Tidak Aktif'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Gate Action Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildGateCard(
                          title: 'Gerbang Masuk',
                          status: controller.isEntryGateOpen ? 'Terbuka' : 'Tertutup',
                          isOpen: controller.isEntryGateOpen,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildGateCard(
                          title: 'Gerbang Keluar',
                          status: controller.isExitGateOpen ? 'Terbuka' : 'Tertutup',
                          isOpen: controller.isExitGateOpen,
                          isDark: isDark,
                        ),
                      ],
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

  Widget _buildParkingSlot({
    required String slotName,
    required bool isOccupied,
    required bool isDark,
  }) {
    final statusColor = isOccupied ? AppColors.danger : AppColors.green;

    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slotName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            isOccupied ? Icons.directions_car_filled_rounded : Icons.check_circle_outline_rounded,
            size: 22,
            color: statusColor,
          ),
          const SizedBox(height: 4),
          Text(
            isOccupied ? 'Terisi' : 'Kosong',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: statusColor,
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
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF748391),
          ),
        ),
      ],
    );
  }

  Widget _buildGateCard({
    required String title,
    required String status,
    required bool isOpen,
    required bool isDark,
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sensor_door_rounded,
              color: AppColors.green,
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
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.cyan,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: Colors.white,
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
          'Tindakan ini akan mengembalikan jumlah slot terisi menjadi 0/10 dan mengkalibrasi mikrokontroler.',
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
