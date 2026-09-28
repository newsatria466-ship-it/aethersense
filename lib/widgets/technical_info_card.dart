import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class TechnicalInfoCard extends StatelessWidget {
  final String deviceId;
  final int uptimeSeconds;
  final int sequence;
  final int wifiRssiDbm;

  const TechnicalInfoCard({
    super.key,
    required this.deviceId,
    required this.uptimeSeconds,
    required this.sequence,
    required this.wifiRssiDbm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AetherConstants.surfaceDark : Colors.white;
    final borderColor = isDark ? AetherConstants.borderDark : AetherConstants.borderLight;
    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    final rssiQuality = AetherFormatters.getRssiQuality(wifiRssiDbm);
    final rssiColor = AetherFormatters.getRssiColor(wifiRssiDbm);
    final uptimeText = AetherFormatters.formatUptime(uptimeSeconds);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x2538BDF8) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.memory_rounded,
                  color: isDark ? AetherConstants.cyanAccent : const Color(0xFF475569),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'INFORMASI PERANGKAT & JARINGAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 3 Column Info Row (Uptime, Sequence, Wi-Fi RSSI)
          Row(
            children: [
              // Uptime
              Expanded(
                child: _buildInfoItem(
                  label: 'Uptime Sistem',
                  value: uptimeText,
                  icon: Icons.timer_outlined,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),

              Container(
                width: 1,
                height: 38,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
              ),

              // Sequence
              Expanded(
                child: _buildInfoItem(
                  label: 'Paket Data',
                  value: '#$sequence',
                  icon: Icons.tag_rounded,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),

              Container(
                width: 1,
                height: 38,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
              ),

              // Wi-Fi RSSI
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_rounded, size: 14, color: rssiColor),
                        const SizedBox(width: 4),
                        Text(
                          '$wifiRssiDbm dBm',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: rssiColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        rssiQuality,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: rssiColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: textSecondary),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}
