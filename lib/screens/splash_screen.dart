import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
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
      duration: const Duration(milliseconds: 950),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward();

    // Smooth transition into dashboard
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 240),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: Stack(
        children: [
          // Wave graphic at bottom with brand cyan/green gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: CustomPaint(
              painter: _SplashWavePainter(isDark: isDark),
            ),
          ),

          // Centered Content
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand Logo Image
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withValues(alpha: 0.14),
                                  blurRadius: 32,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // App Name
                          Text(
                            'Smart City Tegal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Tagline
                          Text(
                            'Kota Terhubung • Lingkungan Terpantau',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
        ],
      ),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  final bool isDark;

  _SplashWavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // First wave layer (Cyan soft)
    final path1 = Path();
    path1.moveTo(0, h * 0.45);
    path1.cubicTo(w * 0.25, h * 0.20, w * 0.70, h * 0.65, w, h * 0.35);
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();

    final paint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.cyan.withValues(alpha: isDark ? 0.3 : 0.65),
          AppColors.cyan.withValues(alpha: isDark ? 0.15 : 0.35),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path1, paint1);

    // Second wave layer (Cyan to Green gradient)
    final path2 = Path();
    path2.moveTo(0, h * 0.62);
    path2.cubicTo(w * 0.32, h * 0.85, w * 0.65, h * 0.35, w, h * 0.55);
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();

    final paint2 = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.cyan,
          AppColors.green,
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
