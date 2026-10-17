import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Crisp, modern vector Brand Logo for Smart City Tegal (Urban Eco-Tech identity)
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;
  final Color? textColor;

  const BrandLogo({
    super.key,
    this.size = 36,
    this.showText = false,
    this.isDark = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final emblem = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => CustomPaint(
          painter: _BrandLogoPainter(),
        ),
      ),
    );

    if (!showText) {
      return emblem;
    }

    final primary = textColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        SizedBox(width: size * 0.3),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SMART CITY',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: size * 0.34,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: primary,
                height: 1.05,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TEGAL',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.cyanBlue,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.ecoGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'ECO-TECH',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: secondary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer Leaf (Eco Green)
    final greenPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C868), AppColors.ecoGreen],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final greenPath = Path();
    greenPath.moveTo(w * 0.5, h * 0.04);
    greenPath.cubicTo(w * 0.88, h * 0.08, w * 0.98, h * 0.52, w * 0.82, h * 0.80);
    greenPath.cubicTo(w * 0.68, h * 0.98, w * 0.38, h * 0.98, w * 0.22, h * 0.84);
    greenPath.cubicTo(w * 0.40, h * 0.78, w * 0.62, h * 0.58, w * 0.58, h * 0.36);
    greenPath.cubicTo(w * 0.56, h * 0.22, w * 0.52, h * 0.12, w * 0.5, h * 0.04);
    greenPath.close();

    canvas.drawPath(greenPath, greenPaint);

    // Inner Droplet / Tech Wave (Cyan Blue)
    final cyanPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), AppColors.cyanBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final cyanPath = Path();
    cyanPath.moveTo(w * 0.46, h * 0.12);
    cyanPath.cubicTo(w * 0.48, h * 0.28, w * 0.44, h * 0.46, w * 0.30, h * 0.60);
    cyanPath.cubicTo(w * 0.14, h * 0.74, w * 0.08, h * 0.58, w * 0.08, h * 0.46);
    cyanPath.cubicTo(w * 0.08, h * 0.26, w * 0.28, h * 0.14, w * 0.46, h * 0.12);
    cyanPath.close();

    canvas.drawPath(cyanPath, cyanPaint);

    // Overlapping Central Eco-Node (Pure White Node)
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.48, h * 0.54), w * 0.10, whitePaint);

    // Inner Cyan Dot inside white node
    final nodeCorePaint = Paint()
      ..color = AppColors.cyanBlue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.48, h * 0.54), w * 0.048, nodeCorePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
