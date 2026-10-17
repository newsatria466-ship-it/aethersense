import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/update_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pressable_scale.dart';
import 'widgets/update_dialog.dart';
import 'tabs/home_tab.dart';
import 'tabs/lamp_tab.dart';
import 'tabs/monitoring_tab.dart';
import 'tabs/parking_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateSilently();
    });
  }

  Future<void> _checkUpdateSilently() async {
    if (!mounted) return;
    try {
      final updateService = context.read<UpdateService>();
      final info = await updateService.checkForUpdate();
      if (info != null && info.hasUpdate && mounted) {
        UpdateDialog.show(context, info);
      }
    } catch (_) {
      // Non-blocking update check
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // IndexedStack preserves state across tabs without rebuilding
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeTab(onNavigateToTab: _onTabTapped),
              const MonitoringTab(),
              const ParkingTab(),
              const LampTab(),
            ],
          ),

          // Custom floating bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding > 0 ? 4 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Beranda',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics_rounded,
                label: 'Monitoring',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.local_parking_outlined,
                activeIcon: Icons.local_parking_rounded,
                label: 'Parkir',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.lightbulb_outline_rounded,
                activeIcon: Icons.lightbulb_rounded,
                label: 'PJU Lampu',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.cyan : AppColors.textSecondary;

    return Expanded(
      child: PressableScale(
        onTap: () => _onTabTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyan.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey<bool>(isSelected),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
