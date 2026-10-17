import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pressable_scale.dart';

class LampTab extends StatelessWidget {
  const LampTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TelemetryController>(
      builder: (context, controller, child) {
        final isOnline = controller.isConnected;
        final isDelayed = controller.isTelemetryDelayed;
        final isAuto = controller.isAutoMode;
        final activeCount = controller.activeRelayCount;
        final ldrRaw = controller.latestTelemetry?.ldrRaw ?? 0;
        final ambient = controller.latestTelemetry?.ambientLight ?? 'Normal';
        final isDark = controller.isDark;

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
                                        Icons.lightbulb_rounded,
                                        color: AppColors.cyan,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Smart Public Lighting',
                                      style: AppTextStyles.h2.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Penerangan Jalan Umum & Taman Kota',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            // Active lights pill badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: activeCount > 0
                                    ? AppColors.green.withValues(alpha: 0.12)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                                border: Border.all(
                                  color: activeCount > 0
                                      ? AppColors.green.withValues(alpha: 0.3)
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: activeCount > 0 ? AppColors.green : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$activeCount / 4 Aktif',
                                    style: AppTextStyles.caption.copyWith(
                                      color: activeCount > 0 ? AppColors.green : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Offline banner
                        if (!isOnline) ...[
                          const SizedBox(height: AppSpacings.m),
                          _buildNoticeBanner(
                            icon: Icons.cloud_off_rounded,
                            title: 'Status: Mikrokontroler Offline',
                            message: 'Kontrol relay dan sensor LDR dinonaktifkan sementara.',
                            color: AppColors.warning,
                          ),
                        ] else if (isDelayed) ...[
                          const SizedBox(height: AppSpacings.m),
                          _buildNoticeBanner(
                            icon: Icons.timer_outlined,
                            title: 'Telemetri Tertunda',
                            message: 'Status relay terakhir: ${controller.freshnessText}',
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Lighting Mode Selector (Otomatis vs Manual)
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
                                'Mode Operasi Sistem',
                                style: AppTextStyles.bodyBold.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (controller.isPendingModeChange)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.cyan,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildModeButton(
                                    title: 'Otomatis (LDR)',
                                    subtitle: 'Sensor Cahaya',
                                    icon: Icons.brightness_auto_rounded,
                                    isSelected: isAuto,
                                    onTap: isOnline && !controller.isPendingModeChange
                                        ? () => controller.setLightingMode('auto')
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildModeButton(
                                    title: 'Manual (Operator)',
                                    subtitle: 'Kontrol Mandiri',
                                    icon: Icons.touch_app_rounded,
                                    isSelected: !isAuto,
                                    onTap: isOnline && !controller.isPendingModeChange
                                        ? () => controller.setLightingMode('manual')
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAuto
                                ? 'Lampu akan menyala otomatis saat sensor LDR mendeteksi kondisi gelap/malam dan padam saat siang.'
                                : 'Lampu dikontrol secara manual oleh operator. Mengubah sakelar di bawah akan otomatis mengaktifkan mode manual.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // LDR Ambient Light Sensor Card
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.warning : AppColors.cyan)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                              size: 24,
                              color: isDark ? AppColors.warning : AppColors.cyan,
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
                                      'Sensor Cahaya LDR',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (isDark ? AppColors.warning : AppColors.green)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isDark ? 'GELAP' : 'TERANG',
                                        style: AppTextStyles.caption.copyWith(
                                          color: isDark ? AppColors.warning : AppColors.green,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      ambient,
                                      style: AppTextStyles.bodyBold.copyWith(
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ADC: $ldrRaw / 4095',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
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
                ),

                // Master Lighting Controls
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacings.m,
                      vertical: AppSpacings.s,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: PressableScale(
                            onTap: isOnline && !controller.isRelayPending('all')
                                ? () => controller.sendRelayCommand(relay: 'all', state: true)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.cyan,
                                borderRadius: BorderRadius.circular(AppRadii.sm),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.cyan.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (controller.isRelayPending('all'))
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.flash_on_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Nyalakan Semua',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PressableScale(
                            onTap: isOnline && !controller.isRelayPending('all')
                                ? () => controller.sendRelayCommand(relay: 'all', state: false)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.flash_off_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Matikan Semua',
                                    style: AppTextStyles.bodyBold.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
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

                // Individual Lamp Relays (4 Relays)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacings.m,
                      AppSpacings.s,
                      AppSpacings.m,
                      AppSpacings.xxl * 2, // Space for bottom bar
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kendali Lampu Individu',
                          style: AppTextStyles.bodyBold.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Relay 1: PJU Jalur Utama
                        _buildRelayCard(
                          relayIndex: 1,
                          name: 'PJU Jalur Utama',
                          location: 'Jl. Pemuda / Depan Alun-Alun',
                          icon: Icons.alt_route_rounded,
                          isOn: controller.relay1,
                          isPending: controller.isRelayPending(1),
                          isOnline: isOnline,
                          onToggle: (state) => controller.sendRelayCommand(relay: 1, state: state),
                        ),
                        const SizedBox(height: 10),

                        // Relay 2: PJU Jalur Pedestrian
                        _buildRelayCard(
                          relayIndex: 2,
                          name: 'PJU Jalur Pedestrian',
                          location: 'Trotoar & Jalur Ramah Pejalan',
                          icon: Icons.directions_walk_rounded,
                          isOn: controller.relay2,
                          isPending: controller.isRelayPending(2),
                          isOnline: isOnline,
                          onToggle: (state) => controller.sendRelayCommand(relay: 2, state: state),
                        ),
                        const SizedBox(height: 10),

                        // Relay 3: Taman Timur
                        _buildRelayCard(
                          relayIndex: 3,
                          name: 'Lampu Taman Sisi Timur',
                          location: 'Area Taman Bunga & Gazebo',
                          icon: Icons.park_rounded,
                          isOn: controller.relay3,
                          isPending: controller.isRelayPending(3),
                          isOnline: isOnline,
                          onToggle: (state) => controller.sendRelayCommand(relay: 3, state: state),
                        ),
                        const SizedBox(height: 10),

                        // Relay 4: Taman Barat
                        _buildRelayCard(
                          relayIndex: 4,
                          name: 'Lampu Taman Sisi Barat',
                          location: 'Area Air Mancur & Monumen',
                          icon: Icons.yard_rounded,
                          isOn: controller.relay4,
                          isPending: controller.isRelayPending(4),
                          isOnline: isOnline,
                          onToggle: (state) => controller.sendRelayCommand(relay: 4, state: state),
                        ),
                      ],
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

  Widget _buildModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.cyan : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? AppColors.cyan : AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelayCard({
    required int relayIndex,
    required String name,
    required String location,
    required IconData icon,
    required bool isOn,
    required bool isPending,
    required bool isOnline,
    required ValueChanged<bool> onToggle,
  }) {
    final activeColor = isOn ? AppColors.cyan : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacings.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: isOn ? AppColors.cyan.withValues(alpha: 0.35) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isOn
                ? AppColors.cyan.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOn
                  ? AppColors.cyan.withValues(alpha: 0.12)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: activeColor,
            ),
          ),
          const SizedBox(width: 12),

          // Name and info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyBold.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'R$relayIndex',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Pending spinner or Switch
          if (isPending)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.cyan,
              ),
            )
          else
            Switch(
              value: isOn,
              activeThumbColor: AppColors.cyan,
              activeTrackColor: AppColors.cyan.withValues(alpha: 0.35),
              inactiveThumbColor: AppColors.textSecondary.withValues(alpha: 0.6),
              inactiveTrackColor: AppColors.background,
              onChanged: isOnline ? (value) => onToggle(value) : null,
            ),
        ],
      ),
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
}
