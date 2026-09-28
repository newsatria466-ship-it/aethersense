import 'dart:ui';
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x750F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, -4),
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
                ),
              ),

              // Tab 3: Smart Lamp (Coming Soon)
              Expanded(
                child: _buildTabItem(
                  context: context,
                  index: 2,
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Smart Lamp',
                  subtitle: 'Segera Hadir',
                  isActive: currentIndex == 2,
                ),
              ),
            ],
          ),
        ),
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
  }) {
    return InkWell(
      onTap: () {
        if (index != 0) {
          _showComingSoonNotice(context, title);
        } else {
          onTabSelected(index);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0x3538BDF8) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: AetherConstants.cyanAccent.withOpacity(0.4), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? AetherConstants.cyanAccent
                  : const Color(0xFF64748B),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? AetherConstants.cyanAccent
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonNotice(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AetherConstants.cyanAccent, size: 18),
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
