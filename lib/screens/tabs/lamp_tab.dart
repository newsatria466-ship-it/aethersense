import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/staggered_entrance.dart';

class LampTab extends StatelessWidget {
  const LampTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TelemetryController>(
      builder: (context, controller, child) {
        final isOnline = controller.connectionStatus.toString().contains('connected');
        final isAuto = controller.isAutoMode;
        final activeCount = controller.activeRelayCount;
        final isMasterActive = activeCount > 0;
        final ldrRaw = controller.ldrRaw;
        final ambientLight = controller.ambientLight;

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PJU Lampu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
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
                      ],
                    ),
                  ),
                ),

                // 2. Top Master Card (Semua Zona)
                SliverToBoxAdapter(
                  child: StaggeredEntrance(
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          gradient: isMasterActive
                              ? RadialGradient(
                                  center: const Alignment(-0.85, 0.0),
                                  radius: 1.4,
                                  colors: [
                                    Colors.amber.withValues(alpha: isDark ? 0.22 : 0.14),
                                    isDark ? AppColors.surfaceDark : Colors.white,
                                  ],
                                )
                              : null,
                          border: Border.all(
                            color: isMasterActive
                                ? Colors.amber.shade600.withValues(alpha: 0.5)
                                : (isDark ? AppColors.borderDark : AppColors.border),
                            width: isMasterActive ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isMasterActive
                                  ? Colors.amber.withValues(alpha: isDark ? 0.22 : 0.12)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: isMasterActive ? 16 : 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isMasterActive
                                    ? Colors.amber.withValues(alpha: 0.25)
                                    : AppColors.cyan.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isMasterActive
                                    ? [
                                        BoxShadow(
                                          color: Colors.amber.withValues(alpha: 0.5),
                                          blurRadius: 18,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                isMasterActive ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                                size: 28,
                                color: isMasterActive ? Colors.amber.shade800 : AppColors.cyan,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penerangan Kota (Master)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isMasterActive ? 'Aktif' : 'Padam',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isMasterActive
                                          ? (isDark ? Colors.amberAccent : Colors.amber.shade800)
                                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    '$activeCount dari 4 zona menyala',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Master Switch
                            if (controller.isRelayPending('all'))
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.amber,
                                ),
                              )
                            else
                              Switch(
                                value: isMasterActive,
                                activeThumbColor: Colors.amber.shade700,
                                activeTrackColor: Colors.amber.withValues(alpha: 0.35),
                                inactiveThumbColor: AppColors.textSecondary.withValues(alpha: 0.6),
                                inactiveTrackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                onChanged: isOnline
                                    ? (val) => controller.sendRelayCommand(relay: 'all', state: val)
                                    : null,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),


                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 3. Mode Operasi: Sensor Otomatis (LDR) vs Manual (Jadwal Dihapus)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode Operasi Lampu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Two-option Segmented Mode Selector: [ Sensor Otomatis ] vs [ Manual ]
                        Container(
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
                              // Option 1: Sensor Otomatis
                              Expanded(
                                child: PressableScale(
                                  onTap: isOnline && !isAuto
                                      ? () => controller.setLightingMode('auto')
                                      : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isAuto ? AppColors.green : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isAuto
                                          ? [
                                              BoxShadow(
                                                color: AppColors.green.withValues(alpha: 0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.brightness_auto_rounded,
                                          size: 16,
                                          color: isAuto
                                              ? Colors.white
                                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Sensor Otomatis (LDR)',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: isAuto ? FontWeight.w700 : FontWeight.w600,
                                            color: isAuto
                                                ? Colors.white
                                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Option 2: Kontrol Manual
                              Expanded(
                                child: PressableScale(
                                  onTap: isOnline && isAuto
                                      ? () => controller.setLightingMode('manual')
                                      : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !isAuto ? AppColors.cyan : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: !isAuto
                                          ? [
                                              BoxShadow(
                                                color: AppColors.cyan.withValues(alpha: 0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.touch_app_rounded,
                                          size: 16,
                                          color: !isAuto
                                              ? Colors.white
                                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Kontrol Manual',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: !isAuto ? FontWeight.w700 : FontWeight.w600,
                                            color: !isAuto
                                                ? Colors.white
                                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 4. Status Card (Sensor LDR vs Info Manual)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAuto
                              ? AppColors.green.withValues(alpha: 0.35)
                              : (isDark ? AppColors.borderDark : AppColors.border),
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
                              color: (isAuto ? AppColors.green : AppColors.cyan).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isAuto ? Icons.wb_sunny_outlined : Icons.tune_rounded,
                              color: isAuto ? AppColors.green : AppColors.cyan,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAuto ? 'Sensor Cahaya (LDR) Aktif' : 'Mode Manual Operator',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAuto
                                      ? 'Lampu otomatis nyala saat petang/gelap & padam saat terang.'
                                      : 'Penerangan dikendalikan secara manual lewat saklar zona di bawah.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isAuto && controller.hasData)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    ambientLight,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.green,
                                    ),
                                  ),
                                  Text(
                                    'ADC: $ldrRaw',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 5. Header Zona Lampu
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Kontrol 4 Zona Penerangan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // 6. Daftar 4 Zona Lampu
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildZoneItem(
                          index: 2,
                          zoneTitle: 'Zona 1',
                          zoneSubtitle: 'Jalan Utama (Alun-Alun)',
                          icon: Icons.alt_route_rounded,
                          isOn: controller.relay1,
                          isPending: controller.isRelayPending(1),
                          isOnline: isOnline,
                          isDark: isDark,
                          onToggle: (state) => controller.sendRelayCommand(relay: 1, state: state),
                        ),
                        const SizedBox(height: 10),
                        _buildZoneItem(
                          index: 3,
                          zoneTitle: 'Zona 2',
                          zoneSubtitle: 'Area Taman & Gazebo',
                          icon: Icons.park_rounded,
                          isOn: controller.relay2,
                          isPending: controller.isRelayPending(2),
                          isOnline: isOnline,
                          isDark: isDark,
                          onToggle: (state) => controller.sendRelayCommand(relay: 2, state: state),
                        ),
                        const SizedBox(height: 10),
                        _buildZoneItem(
                          index: 4,
                          zoneTitle: 'Zona 3',
                          zoneSubtitle: 'Trotoar & Jalur Pedestrian',
                          icon: Icons.directions_walk_rounded,
                          isOn: controller.relay3,
                          isPending: controller.isRelayPending(3),
                          isOnline: isOnline,
                          isDark: isDark,
                          onToggle: (state) => controller.sendRelayCommand(relay: 3, state: state),
                        ),
                        const SizedBox(height: 10),
                        _buildZoneItem(
                          index: 5,
                          zoneTitle: 'Zona 4',
                          zoneSubtitle: 'Fasilitas Publik & Parkir',
                          icon: Icons.location_city_rounded,
                          isOn: controller.relay4,
                          isPending: controller.isRelayPending(4),
                          isOnline: isOnline,
                          isDark: isDark,
                          onToggle: (state) => controller.sendRelayCommand(relay: 4, state: state),
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

  Widget _buildZoneItem({
    required int index,
    required String zoneTitle,
    required String zoneSubtitle,
    required IconData icon,
    required bool isOn,
    required bool isPending,
    required bool isOnline,
    required bool isDark,
    required ValueChanged<bool> onToggle,
  }) {
    return StaggeredEntrance(
      index: index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          gradient: isOn
              ? RadialGradient(
                  center: const Alignment(-0.85, 0.0),
                  radius: 1.35,
                  colors: [
                    Colors.amber.withValues(alpha: isDark ? 0.22 : 0.15),
                    isDark ? AppColors.surfaceDark : Colors.white,
                  ],
                )
              : null,
          border: Border.all(
            color: isOn
                ? Colors.amber.shade600.withValues(alpha: 0.5)
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isOn ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isOn
                  ? Colors.amber.withValues(alpha: isDark ? 0.22 : 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isOn ? 14 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (isOn ? Colors.amber : AppColors.cyan).withValues(alpha: isOn ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isOn ? Icons.lightbulb_rounded : icon,
                size: 21,
                color: isOn ? Colors.amber.shade800 : AppColors.cyan,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zoneTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    zoneSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isPending)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.amber,
                ),
              )
            else
              Switch(
                value: isOn,
                activeThumbColor: Colors.amber.shade700,
                activeTrackColor: Colors.amber.withValues(alpha: 0.35),
                inactiveThumbColor: AppColors.textSecondary.withValues(alpha: 0.6),
                inactiveTrackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                onChanged: isOnline ? (val) => onToggle(val) : null,
              ),
          ],
        ),
      ),
    );
  }

}
