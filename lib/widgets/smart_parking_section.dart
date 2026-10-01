import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/telemetry_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';

class SmartParkingSection extends StatelessWidget {
  const SmartParkingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final controller = context.watch<TelemetryController>();
    final isConnected = controller.connectionStatus == MqttConnectionStateStatus.connected;

    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    final totalSlots = controller.parkingTotalSlots;
    final occupiedSlots = controller.parkingOccupiedSlots;
    final availableSlots = controller.parkingAvailableSlots;
    final isFull = controller.isParkingFull || (occupiedSlots >= totalSlots);

    final isEntryOpen = controller.isEntryGateOpen;
    final isExitOpen = controller.isExitGateOpen;
    final isIrEntry = controller.isIrEntryDetected;
    final isIrExit = controller.isIrExitDetected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x3038BDF8) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_parking_rounded,
                      color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMART PARKING SYSTEM',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                        ),
                      ),
                      Text(
                        'Kapasitas 10 Slot & Gerbang Servo Otomatis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Reset Kuota Button
              OutlinedButton.icon(
                onPressed: (!isConnected || controller.isResettingParking)
                    ? null
                    : () => _confirmResetSlots(context, controller, isDark),
                icon: controller.isResettingParking
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 14),
                label: Text(
                  'Reset',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFF38BDF8) : AetherConstants.primaryBlue,
                  side: BorderSide(
                    color: isDark ? const Color(0x6638BDF8) : const Color(0xFFBFDBFE),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 1. Main Occupancy Card (Capacity Gauge & Status)
          _buildOccupancyCard(
            context: context,
            totalSlots: totalSlots,
            occupiedSlots: occupiedSlots,
            availableSlots: availableSlots,
            isFull: isFull,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 16),

          // 2. Dual Automatic Gates Status (Entry & Exit)
          Row(
            children: [
              Expanded(
                child: _buildGateCard(
                  context: context,
                  isDark: isDark,
                  title: 'PINTU MASUK',
                  isOpen: isEntryOpen,
                  isIrDetected: isIrEntry,
                  irActionLabel: 'Mobil Masuk',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGateCard(
                  context: context,
                  isDark: isDark,
                  title: 'PINTU KELUAR',
                  isOpen: isExitOpen,
                  isIrDetected: isIrExit,
                  irActionLabel: 'Mobil Keluar',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Section Sub-header: Grid Denah 10 Slot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DENAH 10 SLOT PARKIR KOTA TEGAL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem(const Color(0xFF10B981), 'Kosong ($availableSlots)', isDark),
                  const SizedBox(width: 10),
                  _buildLegendItem(const Color(0xFFEF4444), 'Terisi ($occupiedSlots)', isDark),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. 10 Parking Bays Grid
          _buildSlotsGrid(
            totalSlots: totalSlots,
            occupiedSlots: occupiedSlots,
            isDark: isDark,
            textPrimary: textPrimary,
          ),

          // Bottom clearance for navigation bar
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ==========================================
  // 1. OCCUPANCY OVERVIEW CARD
  // ==========================================
  Widget _buildOccupancyCard({
    required BuildContext context,
    required int totalSlots,
    required int occupiedSlots,
    required int availableSlots,
    required bool isFull,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final cardBg = isDark ? AetherConstants.surfaceDark : Colors.white;
    final borderColor = isFull
        ? const Color(0xFFEF4444).withValues(alpha: 0.6)
        : (isDark ? AetherConstants.borderDark : AetherConstants.borderLight);

    final ratio = totalSlots > 0 ? (occupiedSlots / totalSlots).clamp(0.0, 1.0) : 0.0;

    final statusColor = isFull
        ? const Color(0xFFEF4444)
        : (occupiedSlots >= 8 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    final statusLabel = isFull
        ? 'PARKIR PENUH'
        : (occupiedSlots >= 8 ? 'HAMPIR PENUH' : 'TERSEDIA');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isFull ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: isFull
                ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Status Badge & Occupancy Ratio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                'Terisi ${(ratio * 100).toInt()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Stats Row
          Row(
            children: [
              // Available Slots
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slot Kosong',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$availableSlots',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: isFull ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ $totalSlots',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                height: 42,
                width: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 18),

              // Occupied Slots
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobil Terparkir',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$occupiedSlots',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: occupiedSlots > 0 ? const Color(0xFFEF4444) : textPrimary,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Kendaraan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0x301E293B) : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. GATE CARD (ENTRY / EXIT SERVO & IR)
  // ==========================================
  Widget _buildGateCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required bool isOpen,
    required bool isIrDetected,
    required String irActionLabel,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final cardBg = isDark ? AetherConstants.surfaceDark : Colors.white;
    final gateBorder = isOpen
        ? const Color(0xFF10B981).withValues(alpha: 0.6)
        : (isDark ? AetherConstants.borderDark : AetherConstants.borderLight);

    const openColor = Color(0xFF10B981);
    final closedColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gateBorder, width: isOpen ? 1.4 : 1.0),
        boxShadow: [
          BoxShadow(
            color: isOpen
                ? const Color(0xFF10B981).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.15 : 0.025),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gate Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isDark ? const Color(0xFF38BDF8) : AetherConstants.primaryBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x301E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PALANG OTOMATIS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Gate Icon & Angle Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOpen
                      ? openColor.withValues(alpha: isDark ? 0.2 : 0.12)
                      : (isDark ? const Color(0x2064748B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isOpen ? Icons.door_sliding_rounded : Icons.door_back_door_rounded,
                  color: isOpen ? openColor : closedColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOpen ? 'TERBUKA' : 'TERTUTUP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isOpen ? openColor : textPrimary,
                    ),
                  ),
                  Text(
                    isOpen ? 'Sudut: 90°' : 'Sudut: 0°',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // IR Sensor Status Indicator
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isIrDetected ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                  shape: BoxShape.circle,
                  boxShadow: isIrDetected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isIrDetected ? '$irActionLabel Terdeteksi' : 'Sensor IR: Siaga',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: isIrDetected ? FontWeight.w800 : FontWeight.w500,
                    color: isIrDetected ? const Color(0xFFF59E0B) : textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. 10 SLOTS GRID
  // ==========================================
  Widget _buildSlotsGrid({
    required int totalSlots,
    required int occupiedSlots,
    required bool isDark,
    required Color textPrimary,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: totalSlots,
      itemBuilder: (context, index) {
        final slotNumber = index + 1;
        final isOccupied = slotNumber <= occupiedSlots;

        final bayBg = isOccupied
            ? (isDark ? const Color(0x35EF4444) : const Color(0xFFFEF2F2))
            : (isDark ? const Color(0x2510B981) : const Color(0xFFECFDF5));

        final bayBorder = isOccupied
            ? const Color(0xFFEF4444).withValues(alpha: 0.5)
            : const Color(0xFF10B981).withValues(alpha: 0.5);

        final bayColor = isOccupied ? const Color(0xFFEF4444) : const Color(0xFF10B981);

        return Container(
          decoration: BoxDecoration(
            color: bayBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: bayBorder, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#0$slotNumber',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                isOccupied ? Icons.directions_car_rounded : Icons.local_parking_rounded,
                size: 22,
                color: bayColor,
              ),
              const SizedBox(height: 4),
              Text(
                isOccupied ? 'TERISI' : 'KOSONG',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: bayColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  void _confirmResetSlots(BuildContext context, TelemetryController controller, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AetherConstants.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Kuota Parkir?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AetherConstants.textPrimaryLight,
          ),
        ),
        content: Text(
          'Tindakan ini akan mengosongkan status kuota terisi kembali menjadi 0/10 slot kosong.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.resetParkingSlots();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Perintah reset kuota parkir telah berhasil dikirim',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF0284C7),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Ya, Reset',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
