import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/telemetry_controller.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';
import 'auto_scroll_marquee_text.dart';

class SmartLampSection extends StatelessWidget {
  const SmartLampSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<TelemetryController>();
    final isConnected = controller.connectionStatus == MqttConnectionStateStatus.connected;
    final activeCount = controller.activeRelayCount;

    final cardBg = isDark ? AetherConstants.surfaceDark : Colors.white;
    final borderColor = isDark ? AetherConstants.borderDark : AetherConstants.borderLight;
    final textPrimary = isDark ? Colors.white : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Connection Warning Banner if Disconnected
          if (!isConnected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x35EF4444) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0x60EF4444) : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: AetherConstants.statusRed,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Broker Terputus',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFFCA5A5) : AetherConstants.statusRedText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kontrol lampu dinonaktifkan sementara hingga terhubung kembali.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => controller.retryConnection(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: AetherConstants.statusRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'Hubungkan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 2. Section Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SMART LAMP & OTOMASI LDR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Penerangan Sektor Kota Tegal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              // Sector Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: activeCount > 0
                      ? (isDark ? const Color(0x30F59E0B) : const Color(0xFFFEF3C7))
                      : (isDark ? const Color(0x30334155) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeCount > 0
                        ? (isDark ? const Color(0x60F59E0B) : const Color(0xFFFDE68A))
                        : borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: activeCount > 0 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$activeCount / 4 Sektor Aktif',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: activeCount > 0
                            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                            : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // A. Kartu Sensor Ambien LDR & Mode Selector (Paling Atas)
          _buildAmbientLdrAndModeCard(
            context: context,
            controller: controller,
            isDark: isDark,
            isConnected: isConnected,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 16),

          // B. Master Quick Actions (Bar Tombol Cepat)
          _buildMasterControlBar(
            context: context,
            controller: controller,
            isDark: isDark,
            isConnected: isConnected,
          ),

          const SizedBox(height: 20),

          // Subtitle for individual sectors
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'KONTROL 4 SEKTOR PENERANGAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // C. 4 Kartu Sektor Lampu (Grid / List Interaktif)
          _buildSectorCard(
            context: context,
            controller: controller,
            sectorNumber: 1,
            title: 'Sektor 01: Kawasan Alun-Alun & Monumen Bahari',
            subtitle: 'Kawasan Pusat Titik Nol & Ikon Wisata Tegal',
            isOn: controller.relay1,
            isDark: isDark,
            isConnected: isConnected,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 12),

          _buildSectorCard(
            context: context,
            controller: controller,
            sectorNumber: 2,
            title: 'Sektor 02: Koridor Jl. KH Wahid Hasyim',
            subtitle: 'Koridor Utama Pusat Niaga & Kuliner Malam',
            isOn: controller.relay2,
            isDark: isDark,
            isConnected: isConnected,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 12),

          _buildSectorCard(
            context: context,
            controller: controller,
            sectorNumber: 3,
            title: 'Sektor 03: RTH & Jalur Sepeda Bahari',
            subtitle: 'Ruang Terbuka Hijau & Trek Rekreasi Warga',
            isOn: controller.relay3,
            isDark: isDark,
            isConnected: isConnected,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 12),

          _buildSectorCard(
            context: context,
            controller: controller,
            sectorNumber: 4,
            title: 'Sektor 04: Saluran Drainase & Tanggul Pesisir',
            subtitle: 'Penerangan Inspeksi Pompa & Mitigasi Rob',
            isOn: controller.relay4,
            isDark: isDark,
            isConnected: isConnected,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 18),

          // Bottom Info Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x2038BDF8) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0x4038BDF8) : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sensors_rounded,
                  size: 20,
                  color: isDark ? AetherConstants.cyanAccent : const Color(0xFF15803D),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Otomasi Berbasis Sensor Cahaya (LDR)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pada mode otomatis, sensor cahaya mengontrol penerangan jalan saat senja dan malam secara mandiri, menghemat konsumsi energi secara terukur untuk Kota Tegal.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.4,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom margin for navigation clearance
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  /// A. Kartu Sensor Ambien LDR & Mode Selector (Paling Atas)
  Widget _buildAmbientLdrAndModeCard({
    required BuildContext context,
    required TelemetryController controller,
    required bool isDark,
    required bool isConnected,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isAuto = controller.isAutoMode;
    final ambientLight = controller.ambientLight;
    final isDarkCondition = controller.isDark || ambientLight == 'Gelap';
    final ldrRaw = controller.ldrRaw;
    final isPendingMode = controller.isPendingModeChange;

    // Ambient light icon and container colors
    final IconData lightIcon = isDarkCondition
        ? Icons.nightlight_round
        : Icons.wb_sunny_rounded;

    final Color lightIconColor = isDarkCondition
        ? const Color(0xFF818CF8) // Indigo Moon
        : const Color(0xFFF59E0B); // Amber Sun

    final Color lightIconBg = isDarkCondition
        ? (isDark ? const Color(0x356366F1) : const Color(0xFFEEF2FF))
        : (isDark ? const Color(0x35F59E0B) : const Color(0xFFFEF3C7));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Ambient Light Info (LDR Sensor)
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: lightIconBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: lightIconColor.withValues(alpha: isDark ? 0.25 : 0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    lightIcon,
                    color: lightIconColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sensor Ambien LDR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x3038BDF8) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SENSOR CAHAYA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          'Kondisi: ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        Text(
                          ambientLight,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDarkCondition ? const Color(0xFF818CF8) : const Color(0xFFD97706),
                          ),
                        ),
                        Text(
                          ' • Raw ADC: $ldrRaw',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge (TERANG / GELAP)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkCondition
                      ? (isDark ? const Color(0x306366F1) : const Color(0xFFEEF2FF))
                      : (isDark ? const Color(0x30F59E0B) : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDarkCondition ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isDarkCondition ? 'GELAP' : 'TERANG',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDarkCondition
                            ? (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA))
                            : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309)),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            height: 1,
          ),

          const SizedBox(height: 12),

          // Row 2: Mode Selector Label & Segmented Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PILIHAN MODE OPERASI:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              if (isPendingMode)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AetherConstants.cyanAccent,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Segmented Buttons: Otomatis (LDR) vs Manual (Operator)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                // 1. Mode Otomatis (LDR)
                Expanded(
                  child: InkWell(
                    onTap: (!isConnected || isPendingMode)
                        ? null
                        : () {
                            if (!isAuto) {
                              controller.setLightingMode('auto');
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Mode sistem diubah ke Otomatis (LDR)',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: const Color(0xFF0284C7),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isAuto
                            ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isAuto
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_mode_rounded,
                            size: 16,
                            color: isAuto
                                ? (isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue)
                                : textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Otomatis (LDR)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isAuto ? FontWeight.w800 : FontWeight.w600,
                              color: isAuto
                                  ? (isDark ? Colors.white : AetherConstants.textPrimaryLight)
                                  : textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // 2. Mode Manual (Operator)
                Expanded(
                  child: InkWell(
                    onTap: (!isConnected || isPendingMode)
                        ? null
                        : () {
                            if (isAuto) {
                              controller.setLightingMode('manual');
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Mode sistem diubah ke Manual (Operator)',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: const Color(0xFFD97706),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isAuto
                            ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !isAuto
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 16,
                            color: !isAuto
                                ? const Color(0xFFD97706)
                                : textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Manual (Operator)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: !isAuto ? FontWeight.w800 : FontWeight.w600,
                              color: !isAuto
                                  ? (isDark ? Colors.white : AetherConstants.textPrimaryLight)
                                  : textSecondary,
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

          const SizedBox(height: 10),

          // Small visual note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pada mode otomatis, semua lampu menyala saat gelap (>3000 ADC) dan padam saat terang.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    height: 1.35,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// B. Master Quick Actions (Bar Tombol Cepat)
  Widget _buildMasterControlBar({
    required BuildContext context,
    required TelemetryController controller,
    required bool isDark,
    required bool isConnected,
  }) {
    final isPendingAll = controller.isRelayPending('all');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AetherConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AetherConstants.borderDark : AetherConstants.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x30F59E0B) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Master Saklar Lampu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AetherConstants.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'Kontrol serentak seluruh sektor penerangan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPendingAll)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFD97706),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Dua Tombol Aksi Cepat
          Row(
            children: [
              // 1. Tombol Nyalakan Semua (Amber/Kuning Terang)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (!isConnected || isPendingAll)
                      ? null
                      : () {
                          controller.sendRelayCommand(relay: 'all', state: true);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Perintah menyalakan seluruh sektor berhasil dikirim',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: const Color(0xFFB45309),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706), // Warm Amber
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    disabledForegroundColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.wb_incandescent_rounded, size: 18),
                  label: Text(
                    'Nyalakan Semua',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 2. Tombol Matikan Semua (Netral/Abu-abu gelap)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (!isConnected || isPendingAll)
                      ? null
                      : () {
                          controller.sendRelayCommand(relay: 'all', state: false);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Perintah memadamkan seluruh sektor berhasil dikirim',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: const Color(0xFF334155),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    foregroundColor: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                  label: Text(
                    'Matikan Semua',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// C. Kartu Sektor Lampu Individual
  Widget _buildSectorCard({
    required BuildContext context,
    required TelemetryController controller,
    required int sectorNumber,
    required String title,
    required String subtitle,
    required bool isOn,
    required bool isDark,
    required bool isConnected,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isPending = controller.isRelayPending(sectorNumber);

    // Dynamic accent styles when lamp is turned ON vs OFF
    final bulbBg = isOn
        ? (isDark ? const Color(0x35F59E0B) : const Color(0xFFFEF3C7))
        : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9));

    final bulbColor = isOn
        ? const Color(0xFFF59E0B) // Amber ON
        : const Color(0xFF94A3B8); // Cool Gray OFF

    final cardBorder = isOn
        ? (isDark ? const Color(0x80F59E0B) : const Color(0xFFFCD34D))
        : borderColor;

    return InkWell(
      onTap: (!isConnected || isPending)
          ? null
          : () {
              controller.sendRelayCommand(relay: sectorNumber, state: !isOn);
            },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorder, width: isOn ? 1.5 : 1.0),
          boxShadow: [
            BoxShadow(
              color: isOn
                  ? (const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.08))
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: isOn ? 14 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Glowing Lamp Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bulbBg,
                shape: BoxShape.circle,
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: isPending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: bulbColor,
                        ),
                      )
                    : Icon(
                        isOn ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                        color: bulbColor,
                        size: 26,
                      ),
              ),
            ),

            const SizedBox(width: 14),

            // Sector Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Marquee Text (Smooth horizontal auto-scroller)
                  Row(
                    children: [
                      Expanded(
                        child: AutoScrollMarqueeText(
                          text: title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Subtitle area description
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Status Badge
                  Row(
                    children: [
                      // Badge Menyala / Padam
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOn
                              ? (isDark ? const Color(0x3510B981) : const Color(0xFFECFDF5))
                              : (isDark ? const Color(0x3564748B) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isOn ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isOn ? 'MENYALA' : 'PADAM',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isOn
                                    ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
                                    : textSecondary,
                                letterSpacing: 0.5,
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

            const SizedBox(width: 8),

            // Interactive Switch
            Switch(
              value: isOn,
              onChanged: (!isConnected || isPending)
                  ? null
                  : (bool value) {
                      controller.sendRelayCommand(relay: sectorNumber, state: value);
                    },
              activeThumbColor: const Color(0xFFF59E0B),
              activeTrackColor: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              inactiveThumbColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ],
        ),
      ),
    );
  }
}
