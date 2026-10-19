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

  // Standalone Playground / Manual Mode state (Active by default for interactive sandbox play)
  bool _isManualMode = true;
  final Set<int> _manualOccupiedSlots = {1, 3, 7};
  bool _manualEntryGateOpen = false;
  bool _manualExitGateOpen = false;
  bool _manualIrEntryActive = false;
  bool _manualIrExitActive = false;

  void _handleManualCarEntry({int? preferredSlot}) {
    if (_manualOccupiedSlots.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('Semua slot parkir sudah penuh (9/9)!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int target = 0;
    if (preferredSlot != null && !_manualOccupiedSlots.contains(preferredSlot)) {
      target = preferredSlot;
    } else {
      for (int i = 1; i <= 9; i++) {
        if (!_manualOccupiedSlots.contains(i)) {
          target = i;
          break;
        }
      }
    }

    if (target == 0) return;

    setState(() {
      _manualIrEntryActive = true;
      _manualEntryGateOpen = true;
    });

    _visualizerKey.currentState?.animateCarEnteringSlot(target);

    // Add slot to occupied set
    setState(() {
      _manualOccupiedSlots.add(target);
    });

    // Auto-close entry gate after car parks
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        setState(() {
          _manualEntryGateOpen = false;
          _manualIrEntryActive = false;
        });
      }
    });
  }

  void _handleManualCarExit({int? targetSlot}) {
    if (_manualOccupiedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text('Area parkir kosong, tidak ada mobil yang bisa keluar.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final toRemove = targetSlot ?? _manualOccupiedSlots.last;

    setState(() {
      _manualOccupiedSlots.remove(toRemove);
      _manualIrExitActive = true;
      _manualExitGateOpen = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.cyan,
        content: Text('Mobil di Slot P$toRemove keluar melewati gerbang OUT.'),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _manualExitGateOpen = false;
          _manualIrExitActive = false;
        });
      }
    });
  }

  void _handleManualFillAll() {
    setState(() {
      for (int i = 1; i <= 9; i++) {
        _manualOccupiedSlots.add(i);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.green,
        content: Text('Semua 9 slot terisi dengan mobil warna-warni!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleManualClearAll() {
    setState(() {
      _manualOccupiedSlots.clear();
      _manualEntryGateOpen = false;
      _manualExitGateOpen = false;
      _manualIrEntryActive = false;
      _manualIrExitActive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.cyan,
        content: Text('Seluruh area parkir telah dikosongkan (0/9).'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TelemetryController>(
      builder: (context, controller, child) {
        // Resolve values based on whether user is in Manual/Playground mode or MQTT Live Mode
        const total = 9;
        final occupied = _isManualMode ? _manualOccupiedSlots.length : controller.parkingOccupiedSlots;
        final available = total - occupied;
        final isEntryGateOpen = _isManualMode ? _manualEntryGateOpen : controller.isEntryGateOpen;
        final isExitGateOpen = _isManualMode ? _manualExitGateOpen : controller.isExitGateOpen;
        final isIrEntryActive = _isManualMode ? _manualIrEntryActive : controller.isIrEntryDetected;
        final isIrExitActive = _isManualMode ? _manualIrExitActive : controller.isIrExitDetected;
        final isOnline = controller.connectionStatus.toString().contains('connected');
        final percentAvailable = ((available / (total == 0 ? 1 : total)) * 100).toInt();

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header Bar with Mode Toggle
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                  _isManualMode ? 'Mode Sandbox / Mainan Bebas' : 'Sinkronisasi Telemetry MQTT',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _isManualMode ? AppColors.cyan : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Mode Toggle Button
                                PressableScale(
                                  onTap: () {
                                    setState(() {
                                      _isManualMode = !_isManualMode;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: _isManualMode ? AppColors.cyan : AppColors.green,
                                        content: Text(
                                          _isManualMode
                                              ? 'Mode Mainan (Manual) Aktif: Bebas klik mobil, slot, dan gerbang!'
                                              : 'Mode Broker MQTT Aktif: Data mengikuti sensor ESP32.',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (_isManualMode ? AppColors.cyan : AppColors.green).withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: (_isManualMode ? AppColors.cyan : AppColors.green).withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isManualMode ? Icons.sports_esports_rounded : Icons.sensors_rounded,
                                          size: 15,
                                          color: _isManualMode ? AppColors.cyan : AppColors.green,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _isManualMode ? 'Manual' : 'MQTT',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _isManualMode ? AppColors.cyan : AppColors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Reset button
                                PressableScale(
                                  onTap: () {
                                    if (_isManualMode) {
                                      _handleManualClearAll();
                                    } else {
                                      _confirmReset(context, controller);
                                    }
                                  },
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
                                    color: (isIrEntryActive || isIrExitActive
                                            ? AppColors.cyan
                                            : (_isManualMode ? AppColors.cyan : (isOnline ? AppColors.green : AppColors.warning)))
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isIrEntryActive
                                        ? '⚡ IR MASUK AKTIF'
                                        : (isIrExitActive
                                            ? '⚡ IR KELUAR AKTIF'
                                            : (_isManualMode ? '🎮 MODE MAINAN' : (isOnline ? '● MQTT LIVE' : '● OFFLINE'))),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isIrEntryActive || isIrExitActive
                                          ? AppColors.cyan
                                          : (_isManualMode ? AppColors.cyan : (isOnline ? AppColors.green : AppColors.warning)),
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
                              occupiedSlots: _isManualMode ? _manualOccupiedSlots : null,
                              totalCount: total,
                              isEntryGateOpen: isEntryGateOpen,
                              isExitGateOpen: isExitGateOpen,
                              onSlotTap: (slot, isOccupied) {
                                _showSlotDetailModal(context, slot, isOccupied, controller, isDark);
                              },
                              onEntryGateTap: () {
                                if (_isManualMode) {
                                  setState(() {
                                    _manualEntryGateOpen = !_manualEntryGateOpen;
                                  });
                                } else {
                                  controller.toggleEntryGate();
                                }
                              },
                              onExitGateTap: () {
                                if (_isManualMode) {
                                  setState(() {
                                    _manualExitGateOpen = !_manualExitGateOpen;
                                  });
                                } else {
                                  controller.toggleExitGate();
                                }
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

                // Interactive Quick Actions & Simulation Panel (Sandbox Playground)
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
                                  'Kontrol Interaktif & Mainan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _isManualMode ? 'Mode Manual Bebas' : 'Mode Broker',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: AppColors.cyan,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
                                            if (_isManualMode) {
                                              _handleManualCarEntry();
                                            } else {
                                              final nextSlot = occupied + 1;
                                              _visualizerKey.currentState?.animateCarEnteringSlot(nextSlot);
                                              controller.simulateCarEntry();
                                            }
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
                                            'Mobil Masuk (+)',
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
                                            if (_isManualMode) {
                                              _handleManualCarExit();
                                            } else {
                                              controller.simulateCarExit();
                                            }
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
                                            'Mobil Keluar (-)',
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

                            const SizedBox(height: 8),

                            // Sandbox Quick Fill & Empty Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: PressableScale(
                                    onTap: _handleManualFillAll,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.cyan.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.cyan.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.grid_view_rounded, size: 14, color: AppColors.cyan),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Isi Semua (9 Mobil)',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.cyan,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: PressableScale(
                                    onTap: _handleManualClearAll,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isDark ? AppColors.borderDark : AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.delete_sweep_rounded,
                                            size: 15,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Kosongkan Semua',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
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
                            subtitle: isEntryGateOpen ? 'Palang Terbuka (Kendaraan Boleh Masuk)' : 'Palang Tertutup (Standby Sensor)',
                            isOpen: isEntryGateOpen,
                            isDark: isDark,
                            onToggle: () {
                              if (_isManualMode) {
                                setState(() {
                                  _manualEntryGateOpen = !_manualEntryGateOpen;
                                });
                              } else {
                                controller.toggleEntryGate();
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildGateCard(
                            title: 'Gerbang Keluar (OUT)',
                            subtitle: isExitGateOpen ? 'Palang Terbuka (Kendaraan Boleh Keluar)' : 'Palang Tertutup (Standby Sensor)',
                            isOpen: isExitGateOpen,
                            isDark: isDark,
                            onToggle: () {
                              if (_isManualMode) {
                                setState(() {
                                  _manualExitGateOpen = !_manualExitGateOpen;
                                });
                              } else {
                                controller.toggleExitGate();
                              }
                            },
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
                  if (_isManualMode) {
                    _handleManualCarExit(targetSlot: slot.id);
                  } else {
                    controller.simulateCarExit();
                  }
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
                  if (_isManualMode) {
                    _handleManualCarEntry(preferredSlot: slot.id);
                  } else {
                    _visualizerKey.currentState?.animateCarEnteringSlot(slot.id);
                    controller.simulateCarEntry();
                  }
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
