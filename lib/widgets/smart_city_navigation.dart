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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AetherConstants.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Tab 1: AetherSense (Active)
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 0,
              icon: Icons.radar_rounded,
              title: 'AetherSense',
              subtitle: 'Active',
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? AetherConstants.primaryBlue
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? AetherConstants.primaryBlue
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF94A3B8),
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
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Modul $moduleName sedang dalam tahap pengembangan ekosistem Smart City.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
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
