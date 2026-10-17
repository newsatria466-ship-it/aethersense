import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/telemetry_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pressable_scale.dart';

class LampTab extends StatefulWidget {
  const LampTab({super.key});

  @override
  State<LampTab> createState() => _LampTabState();
}

class _LampTabState extends State<LampTab> {
  int _selectedSegment = 0; // 0: Kontrol, 1: Jadwal

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TelemetryController>(
      builder: (context, controller, child) {
        final isOnline = controller.isConnected;
        final isAuto = controller.isAutoMode;
        final activeCount = controller.activeRelayCount;
        final isMasterActive = activeCount > 0;

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        // Connection dot indicator
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

                // 2. Top Master Card: Big bulb, "Penerangan Kota: Aktif", "4 zona menyala", Master Switch
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Yellow bulb container
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isMasterActive
                                  ? Colors.amber.withValues(alpha: 0.18)
                                  : AppColors.cyan.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.lightbulb_rounded,
                              size: 28,
                              color: isMasterActive ? Colors.amber.shade700 : AppColors.cyan,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Penerangan Kota',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isMasterActive ? 'Aktif' : 'Padam',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isMasterActive
                                        ? AppColors.green
                                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                  ),
                                ),
                                Text(
                                  '$activeCount zona menyala',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Master Toggle Switch
                          if (controller.isRelayPending('all'))
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.green,
                              ),
                            )
                          else
                            Switch(
                              value: isMasterActive,
                              activeThumbColor: AppColors.green,
                              activeTrackColor: AppColors.green.withValues(alpha: 0.35),
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

                // 3. Segmented Tabs: "Kontrol", "Jadwal"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildSegmentItem(0, 'Kontrol'),
                          _buildSegmentItem(1, 'Jadwal'),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Tab Content: 4 Zones List (Kontrol) or Schedules
                if (_selectedSegment == 0) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Zona 1: Jalan Utama (Relay 1)
                          _buildZoneItem(
                            zoneTitle: 'Zona 1',
                            zoneSubtitle: 'Jalan Utama',
                            icon: Icons.alt_route_rounded,
                            isOn: controller.relay1,
                            isPending: controller.isRelayPending(1),
                            isOnline: isOnline,
                            isDark: isDark,
                            onToggle: (state) => controller.sendRelayCommand(relay: 1, state: state),
                          ),
                          const SizedBox(height: 10),

                          // Zona 2: Area Taman (Relay 2)
                          _buildZoneItem(
                            zoneTitle: 'Zona 2',
                            zoneSubtitle: 'Area Taman',
                            icon: Icons.park_rounded,
                            isOn: controller.relay2,
                            isPending: controller.isRelayPending(2),
                            isOnline: isOnline,
                            isDark: isDark,
                            onToggle: (state) => controller.sendRelayCommand(relay: 2, state: state),
                          ),
                          const SizedBox(height: 10),

                          // Zona 3: Kawasan Barat (Relay 3)
                          _buildZoneItem(
                            zoneTitle: 'Zona 3',
                            zoneSubtitle: 'Kawasan Barat',
                            icon: Icons.apartment_rounded,
                            isOn: controller.relay3,
                            isPending: controller.isRelayPending(3),
                            isOnline: isOnline,
                            isDark: isDark,
                            onToggle: (state) => controller.sendRelayCommand(relay: 3, state: state),
                          ),
                          const SizedBox(height: 10),

                          // Zona 4: Kawasan Timur (Relay 4)
                          _buildZoneItem(
                            zoneTitle: 'Zona 4',
                            zoneSubtitle: 'Kawasan Timur',
                            icon: Icons.location_city_rounded,
                            isOn: controller.relay4,
                            isPending: controller.isRelayPending(4),
                            isOnline: isOnline,
                            isDark: isDark,
                            onToggle: (state) => controller.sendRelayCommand(relay: 4, state: state),
                          ),
                          const SizedBox(height: 14),

                          // Bottom Card: Mode Otomatis (LDR Sensor)
                          PressableScale(
                            onTap: isOnline
                                ? () => controller.setLightingMode(isAuto ? 'manual' : 'auto')
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isAuto
                                      ? AppColors.green.withValues(alpha: 0.4)
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
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
                                      Icons.brightness_auto_rounded,
                                      color: isAuto ? AppColors.green : AppColors.cyan,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mode Otomatis',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                        Text(
                                          isAuto
                                              ? 'Aktif • Lampu menyala saat gelap (LDR)'
                                              : 'Nonaktif • Lampu dalam mode manual',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: isAuto
                                                ? AppColors.green
                                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Jadwal view
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 40, color: AppColors.cyan),
                            const SizedBox(height: 12),
                            Text(
                              'Otomasi Jadwal Nyala & Padam',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Penerangan umum diatur otomatis menyala pukul 17:45 WIB dan padam pukul 05:30 WIB sesuai sensor LDR Alun-Alun Tegal.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

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
                        : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoneItem({
    required String zoneTitle,
    required String zoneSubtitle,
    required IconData icon,
    required bool isOn,
    required bool isPending,
    required bool isOnline,
    required bool isDark,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
          // Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isOn ? AppColors.green : AppColors.cyan).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isOn ? AppColors.green : AppColors.cyan,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zoneTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  zoneSubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Pending spinner or Switch
          if (isPending)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.green,
              ),
            )
          else
            Switch(
              value: isOn,
              activeThumbColor: AppColors.green,
              activeTrackColor: AppColors.green.withValues(alpha: 0.35),
              inactiveThumbColor: AppColors.textSecondary.withValues(alpha: 0.6),
              inactiveTrackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              onChanged: isOnline ? (val) => onToggle(val) : null,
            ),
        ],
      ),
    );
  }
}
