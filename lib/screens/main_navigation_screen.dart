import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/update_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pressable_scale.dart';
import 'tabs/home_tab.dart';
import 'tabs/lamp_tab.dart';
import 'tabs/monitoring_tab.dart';
import 'tabs/parking_tab.dart';
import 'widgets/update_dialog.dart';

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
  final PageStorageBucket _bucket = PageStorageBucket();
  double _horizontalDragDistance = 0.0;

  // Track navigation mode: false = Navbar tap (Motion Depth-Fade), true = Screen swipe (Efek Geser Biasa)
  bool _isSwipeNavigation = false;
  int _swipeDirection = 1; // 1 = swipe to next (right-to-left), -1 = swipe to prev (left-to-right)

  // Pre-cache tab instances so they are not re-instantiated from scratch on each transition
  late final List<Widget> _cachedTabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _cachedTabs = [
      HomeTab(
        key: const PageStorageKey('home_tab'),
        onNavigateToTab: _onTabTapped,
      ),
      const MonitoringTab(
        key: PageStorageKey('monitoring_tab'),
      ),
      const ParkingTab(
        key: PageStorageKey('parking_tab'),
      ),
      const LampTab(
        key: PageStorageKey('lamp_tab'),
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateSilently();
    });
  }

  Future<void> _checkUpdateSilently() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    try {
      final updateService = context.read<UpdateService>();
      final info = await updateService.checkForUpdate();
      if (info != null && info.hasUpdate && mounted) {
        UpdateDialog.show(context, info);
      }
    } catch (_) {}
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _isSwipeNavigation = false; // Navbar tap uses the signature Depth-Scale Motion
        _currentIndex = index;
      });
    }
  }

  void _onSwipeTab(int targetIndex, int direction) {
    if (_currentIndex != targetIndex && targetIndex >= 0 && targetIndex < 4) {
      HapticFeedback.selectionClick();
      setState(() {
        _isSwipeNavigation = true; // Screen gesture uses the natural horizontal slide effect
        _swipeDirection = direction;
        _currentIndex = targetIndex;
      });
    }
  }

  Widget _buildTabContent(int index) {
    return KeyedSubtree(
      key: ValueKey<int>(index),
      child: _cachedTabs[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: PageStorage(
        bucket: _bucket,
        child: Stack(
          children: [
            // Gesture-Enabled Dynamic Transition Body (Swipe anywhere horizontally to change tabs)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (_) {
                _horizontalDragDistance = 0.0;
              },
              onHorizontalDragUpdate: (details) {
                _horizontalDragDistance += details.primaryDelta ?? 0.0;
              },
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0.0;
                const velocityThreshold = 180.0;
                const distanceThreshold = 35.0;

                // Geser ke kiri (swipe left) -> tab berikutnya dengan efek geser horizontal
                if (velocity < -velocityThreshold || _horizontalDragDistance < -distanceThreshold) {
                  if (_currentIndex < 3) {
                    _onSwipeTab(_currentIndex + 1, 1);
                  }
                }
                // Geser ke kanan (swipe right) -> tab sebelumnya dengan efek geser horizontal
                else if (velocity > velocityThreshold || _horizontalDragDistance > distanceThreshold) {
                  if (_currentIndex > 0) {
                    _onSwipeTab(_currentIndex - 1, -1);
                  }
                }
                _horizontalDragDistance = 0.0;
              },
              child: AnimatedSwitcher(
                duration: _isSwipeNavigation
                    ? const Duration(milliseconds: 270)
                    : const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  final isIncoming = (child.key as ValueKey<int>?)?.value == _currentIndex;

                  // 1. JIKA DIGESER DENGAN LAYAR (SWIPE GESTURE) -> Efek Geser Biasa (Smooth Horizontal Slide)
                  if (_isSwipeNavigation) {
                    if (isIncoming) {
                      final beginOffset = _swipeDirection > 0
                          ? const Offset(1.0, 0.0)
                          : const Offset(-1.0, 0.0);
                      return SlideTransition(
                        position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
                          ),
                          child: child,
                        ),
                      );
                    } else {
                      final exitOffset = _swipeDirection > 0
                          ? const Offset(-0.25, 0.0)
                          : const Offset(0.25, 0.0);
                      return SlideTransition(
                        position: Tween<Offset>(begin: Offset.zero, end: exitOffset).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
                          ),
                          child: child,
                        ),
                      );
                    }
                  }

                  // 2. JIKA DITEKAN TOMBOL NAVBAR -> Motion Yang Sekarang (Depth Scale + Fade Buttery 60fps)
                  if (isIncoming) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  } else {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 0.98).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeIn,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  }
                },
                child: _buildTabContent(_currentIndex),
              ),
            ),

            // Bottom Navigation Bar with Sliding Liquid Magnetic Pill Accent
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigationBar(context),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomNavigationBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding > 0 ? 4 : 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final itemWidth = totalWidth / 4;

              return SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    // 1. Sliding Liquid Magnetic Pill Indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack, // Responsive elastic spring feel
                      left: _currentIndex * itemWidth + 4,
                      width: itemWidth - 8,
                      top: 2,
                      bottom: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.cyan.withValues(alpha: isDark ? 0.40 : 0.25),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),

                    // 2. Navigation Items Row
                    Row(
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          label: 'Beranda',
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.eco_outlined,
                          activeIcon: Icons.eco_rounded,
                          label: 'Monitoring',
                        ),
                        _buildNavItem(
                          index: 2,
                          icon: Icons.directions_car_outlined,
                          activeIcon: Icons.directions_car_filled_rounded,
                          label: 'Parkir',
                        ),
                        _buildNavItem(
                          index: 3,
                          icon: Icons.lightbulb_outline_rounded,
                          activeIcon: Icons.lightbulb_rounded,
                          label: 'PJU',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
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
        scaleDownFactor: 0.90,
        onTap: () => _onTabTapped(index),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Micro-Bounce Pop Icon
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                builder: (context, animValue, child) {
                  final scale = 1.0 + (0.16 * animValue);
                  final yOffset = -2.0 * animValue;
                  return Transform.translate(
                    offset: Offset(0, yOffset),
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey<bool>(isSelected),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
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

