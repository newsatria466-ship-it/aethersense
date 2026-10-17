import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward();

    // Transition smoothly after ~1100ms
    Future.delayed(const Duration(milliseconds: 1150), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 250),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect system reduced-motion preference
    final mediaQuery = MediaQuery.maybeOf(context);
    final disableAnimations = mediaQuery?.disableAnimations ?? false;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final opacity = disableAnimations ? 1.0 : _fadeAnimation.value;
              final scale = disableAnimations ? 1.0 : _scaleAnimation.value;

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand Logo Emblem
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanBlue.withValues(alpha: 0.14),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: const BrandLogo(size: 72),
                      ),

                      const SizedBox(height: 24),

                      // App Name
                      Text(
                        'SMART CITY TEGAL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Tagline / Concept
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.ecoGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Urban Eco-Tech Intelligence',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Animated Gradient Progress Accent
                      Container(
                        width: 48,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
