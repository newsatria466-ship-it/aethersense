import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class SmartCityNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const SmartCityNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AetherConstants.surfaceDark : Colors.white;
    final borderColor = isDark ? AetherConstants.borderDark : AetherConstants.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Tab 1: EcoSense / Telemetry (Active)
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 0,
              icon: Icons.radar_rounded,
              title: 'EcoSense',
              subtitle: 'Live IoT',
              isActive: currentIndex == 0,
              isDark: isDark,
            ),
          ),

          // Tab 2: Smart Parking (Coming Soon)
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 1,
              icon: Icons.local_parking_rounded,
              title: 'Smart Parking',
              subtitle: 'Segera Hadir',
              isActive: currentIndex == 1,
              isDark: isDark,
            ),
          ),

          // Tab 3: Smart Lamp (Active Kontrol Sektor)
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 2,
              icon: currentIndex == 2 ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
              title: 'Smart Lamp',
              subtitle: 'Kontrol Sektor',
              isActive: currentIndex == 2,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isDark,
  }) {
    final activeBg = isDark ? const Color(0x3538BDF8) : const Color(0xFFEFF6FF);
    final activeColor = isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue;
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: () {
        if (index == 1) {
          _showComingSoonNotice(context, title, isDark);
        } else {
          onTabSelected(index);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonNotice(BuildContext context, String moduleName, bool isDark) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: isDark ? AetherConstants.cyanAccent : Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Modul $moduleName sedang dalam integrasi ekosistem Tegal EcoSense.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
