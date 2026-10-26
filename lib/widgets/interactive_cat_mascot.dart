import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The active interaction state of the login mascot
enum CatMascotState {
  idle,
  emailFocused,
  emailTyping,
  passwordHidden,
  passwordVisible,
  loading,
  error,
  success,
}

/// A naturally integrated mascot layout where the cat physically leans from behind
/// the login card, with its paws resting directly on top of the card's upper rim.
class InteractiveCatMascotCardLayout extends StatefulWidget {
  final CatMascotState state;
  final double lookProgress; // 0.0 (far left) to 1.0 (far right)
  final Widget cardChild;

  const InteractiveCatMascotCardLayout({
    super.key,
    required this.state,
    this.lookProgress = 0.5,
    required this.cardChild,
  });

  @override
  State<InteractiveCatMascotCardLayout> createState() =>
      _InteractiveCatMascotCardLayoutState();
}

class _InteractiveCatMascotCardLayoutState
    extends State<InteractiveCatMascotCardLayout>
    with TickerProviderStateMixin {
  // Animation controllers for smooth physical transitions
  late AnimationController _coverAnimController; // Paws lifting to cover eyes
  late AnimationController _peekAnimController; // Right paw lowering to peek
  late AnimationController _happyAnimController; // Success celebration
  late AnimationController _blinkAnimController; // Natural idle blinking
  late AnimationController _breathAnimController; // Gentle rhythmic breathing
  late AnimationController _headPoseAnimController; // Head lifting from sleep
  late AnimationController _zzzAnimController; // Continuous looping Zzz dream stream

  // Animated values
  late Animation<double> _coverAnimation;
  late Animation<double> _peekAnimation;
  late Animation<double> _happyAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _headPoseAnimation;

  // Smooth pupil tracking interpolation
  double _currentLookProgress = 0.5;

  // Physical layout constants
  static const double mascotHeaderHeight = 152.0; // Space reserved above card for cat head
  static const double cardRimY = mascotHeaderHeight; // Exact Y position of the card's top edge

  @override
  void initState() {
    super.initState();
    _currentLookProgress = widget.lookProgress;

    // 1. Cover eyes animation (260ms smooth cubic)
    _coverAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _coverAnimation = CurvedAnimation(
      parent: _coverAnimController,
      curve: Curves.easeInOutCubic,
    );

    // 2. Peek animation (220ms bouncy ease)
    _peekAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _peekAnimation = CurvedAnimation(
      parent: _peekAnimController,
      curve: Curves.easeOutBack,
    );

    // 3. Happy success celebration animation (450ms)
    _happyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _happyAnimation = CurvedAnimation(
      parent: _happyAnimController,
      curve: Curves.elasticOut,
    );

    // 4. Idle natural blink (loops every 3.2s with a quick 180ms blink)
    _blinkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _blinkAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 92),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 4),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 4),
    ]).animate(_blinkAnimController);

    // 5. Idle breathing wobble (gentle rhythmic breathing)
    _breathAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 6. Head posture animation (lifting up from nestled sleep pose when waking)
    _headPoseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headPoseAnimation = CurvedAnimation(
      parent: _headPoseAnimController,
      curve: Curves.easeOutCubic,
    );

    // 7. Continuous looping Zzz floating stream (2600ms repeat)
    _zzzAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _updateStateAnimations(widget.state, isInit: true);
  }

  @override
  void didUpdateWidget(InteractiveCatMascotCardLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      _updateStateAnimations(widget.state);
    }
  }

  void _updateStateAnimations(CatMascotState state, {bool isInit = false}) {
    // Manage head posture: nestled sleeping pose (0.0) vs alert raised pose (1.0)
    if (state == CatMascotState.idle) {
      _headPoseAnimController.reverse();
    } else {
      _headPoseAnimController.forward();
    }

    switch (state) {
      case CatMascotState.passwordHidden:
        _coverAnimController.forward();
        _peekAnimController.reverse();
        _happyAnimController.reverse();
        break;

      case CatMascotState.passwordVisible:
        _coverAnimController.forward();
        _peekAnimController.forward();
        _happyAnimController.reverse();
        break;

      case CatMascotState.success:
        _coverAnimController.reverse();
        _peekAnimController.reverse();
        _happyAnimController.forward();
        break;

      default:
        // Idle, emailFocused, emailTyping, loading, error
        _coverAnimController.reverse();
        _peekAnimController.reverse();
        _happyAnimController.reverse();
        break;
    }
  }

  @override
  void dispose() {
    _coverAnimController.dispose();
    _peekAnimController.dispose();
    _happyAnimController.dispose();
    _blinkAnimController.dispose();
    _breathAnimController.dispose();
    _headPoseAnimController.dispose();
    _zzzAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _currentLookProgress, end: widget.lookProgress),
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutQuad,
      builder: (context, lookVal, _) {
        _currentLookProgress = lookVal;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _coverAnimation,
            _peekAnimation,
            _happyAnimation,
            _blinkAnimation,
            _breathAnimController,
            _headPoseAnimation,
            _zzzAnimController,
          ]),
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // =============================================================
                // LAYER 1 (BEHIND CARD): Torso, Shoulders, Head, Ears, Eyes
                // =============================================================
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: mascotHeaderHeight + 70, // Extends 70px down behind card
                  child: CustomPaint(
                    painter: _CatHeadAndBodyPainter(
                      state: widget.state,
                      lookProgress: lookVal,
                      coverProgress: _coverAnimation.value,
                      peekProgress: _peekAnimation.value,
                      happyProgress: _happyAnimation.value,
                      blinkProgress: _blinkAnimation.value,
                      breathProgress: _breathAnimController.value,
                      headLiftProgress: _headPoseAnimation.value,
                      cardRimY: cardRimY,
                    ),
                  ),
                ),

                // =============================================================
                // LAYER 2 (MIDDLE): The White Login Card
                // Card physically sits in front of the cat's torso & shoulders!
                // =============================================================
                Padding(
                  padding: const EdgeInsets.only(top: mascotHeaderHeight),
                  child: widget.cardChild,
                ),

                // =============================================================
                // LAYER 3 (FOREGROUND): Paws & Forearms resting on card rim
                // =============================================================
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: mascotHeaderHeight + 50,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CatPawsForegroundPainter(
                        state: widget.state,
                        coverProgress: _coverAnimation.value,
                        peekProgress: _peekAnimation.value,
                        happyProgress: _happyAnimation.value,
                        headLiftProgress: _headPoseAnimation.value,
                        breathProgress: _breathAnimController.value,
                        cardRimY: cardRimY,
                      ),
                    ),
                  ),
                ),

                // =============================================================
                // LAYER 4 (TOP FOREGROUND): Floating Zzz Dream Stream & Effects
                // Placed in front of EVERYTHING so it is NEVER hidden!
                // =============================================================
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: mascotHeaderHeight + 90,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CatDecorationsForegroundPainter(
                        state: widget.state,
                        breathProgress: _breathAnimController.value,
                        zzzProgress: _zzzAnimController.value,
                        headLiftProgress: _headPoseAnimation.value,
                        cardRimY: cardRimY,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// ============================================================================
/// LAYER 1 PAINTER: Cat Body, Torso, Head, Ears, Face, and Eyes
/// Rendered behind the white card surface
/// ============================================================================
class _CatHeadAndBodyPainter extends CustomPainter {
  final CatMascotState state;
  final double lookProgress;
  final double coverProgress;
  final double peekProgress;
  final double happyProgress;
  final double blinkProgress;
  final double breathProgress;
  final double headLiftProgress;
  final double cardRimY;

  _CatHeadAndBodyPainter({
    required this.state,
    required this.lookProgress,
    required this.coverProgress,
    required this.peekProgress,
    required this.happyProgress,
    required this.blinkProgress,
    required this.breathProgress,
    required this.headLiftProgress,
    required this.cardRimY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Head vertical positioning:
    // When sleeping (idle), chin rests low nestled snugly onto the card rim.
    // When alert (waking), head lifts up by ~10px.
    final sleepDip = (1.0 - headLiftProgress) * 10.0;
    final breathOffset = state == CatMascotState.idle ? breathProgress * 2.0 : 0.0;
    final cy = (cardRimY - 56.0) + sleepDip + breathOffset;

    // 1. Torso & Shoulders rising from behind the card
    _drawTorsoAndShoulders(canvas, cx, cy, cardRimY);

    // 2. 3D Volumetric Ears
    _draw3DEars(canvas, cx, cy);

    // 3. Large 3D Chubby Head
    _draw3DHead(canvas, cx, cy);

    // 4. Airbrushed Blushing Cheeks
    _drawCheeks(canvas, cx, cy);

    // 5. 3D Glossy Anime Eyes & Pupils
    _draw3DEyes(canvas, cx, cy);

    // 6. Button Nose & Expressive Cat Mouth
    _drawNoseAndMouth(canvas, cx, cy);
  }

  void _drawTorsoAndShoulders(Canvas canvas, double cx, double cy, double cardRimY) {
    // Shoulders widening out behind the card
    final torsoPath = Path();
    torsoPath.moveTo(cx - 72, cy + 24);
    torsoPath.quadraticBezierTo(cx - 98, cy + 48, cx - 105, cardRimY + 60);
    torsoPath.lineTo(cx + 105, cardRimY + 60);
    torsoPath.quadraticBezierTo(cx + 98, cy + 48, cx + 72, cy + 24);
    torsoPath.close();

    final torsoRect = torsoPath.getBounds();
    final torsoPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFDF9),
          Color(0xFFF3ECE0),
          Color(0xFFE2D6C5),
        ],
      ).createShader(torsoRect);

    canvas.drawPath(torsoPath, torsoPaint);
  }



  void _draw3DEars(Canvas canvas, double cx, double cy) {
    // --- LEFT EAR (Slate Grey Patch side with 3D gradient) ---
    final leftEarPath = Path();
    leftEarPath.moveTo(cx - 34, cy - 46);
    leftEarPath.quadraticBezierTo(cx - 52, cy - 70, cx - 78, cy - 88); // inner curve to tip
    leftEarPath.quadraticBezierTo(cx - 86, cy - 86, cx - 84, cy - 76); // rounded tip
    leftEarPath.quadraticBezierTo(cx - 80, cy - 48, cx - 64, cy - 22); // outer curve to cheek
    leftEarPath.close();

    final leftEarRect = leftEarPath.getBounds();
    final leftEarPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF64748B), // Slate grey 500
          Color(0xFF475569), // Slate grey 600
          Color(0xFF334155), // Slate grey 700
        ],
      ).createShader(leftEarRect);

    canvas.drawPath(leftEarPath, leftEarPaint);

    // Left Inner Ear (Warm pastel peach cavity)
    final leftInnerEar = Path();
    leftInnerEar.moveTo(cx - 40, cy - 44);
    leftInnerEar.quadraticBezierTo(cx - 54, cy - 64, cx - 74, cy - 78);
    leftInnerEar.quadraticBezierTo(cx - 76, cy - 58, cx - 62, cy - 28);
    leftInnerEar.close();

    canvas.drawPath(
      leftInnerEar,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE29DA7),
            Color(0xFFC4818B),
          ],
        ).createShader(leftInnerEar.getBounds()),
    );

    // --- RIGHT EAR (Soft White/Cream side with 3D gradient) ---
    final rightEarPath = Path();
    rightEarPath.moveTo(cx + 34, cy - 46);
    rightEarPath.quadraticBezierTo(cx + 52, cy - 70, cx + 78, cy - 88);
    rightEarPath.quadraticBezierTo(cx + 86, cy - 86, cx + 84, cy - 76);
    rightEarPath.quadraticBezierTo(cx + 80, cy - 48, cx + 64, cy - 22);
    rightEarPath.close();

    final rightEarRect = rightEarPath.getBounds();
    final rightEarPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF9F4EB),
          Color(0xFFE8DFD3),
        ],
      ).createShader(rightEarRect);

    canvas.drawPath(rightEarPath, rightEarPaint);

    // Right Inner Ear (Cute pastel pink cavity)
    final rightInnerEar = Path();
    rightInnerEar.moveTo(cx + 40, cy - 44);
    rightInnerEar.quadraticBezierTo(cx + 54, cy - 64, cx + 74, cy - 78);
    rightInnerEar.quadraticBezierTo(cx + 76, cy - 58, cx + 62, cy - 28);
    rightInnerEar.close();

    canvas.drawPath(
      rightInnerEar,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 0.9,
          colors: [
            Color(0xFFFFC5CE),
            Color(0xFFFF9EA9),
          ],
        ).createShader(rightInnerEar.getBounds()),
    );
  }

  void _draw3DHead(Canvas canvas, double cx, double cy) {
    // Sculpted Organic Head Shape with chubby cheeks matching reference
    final cheekPuff = (1.0 - headLiftProgress) * 4.0;
    
    final headPath = Path();
    headPath.moveTo(cx, cy - 54);
    headPath.quadraticBezierTo(cx + 38, cy - 54, cx + 62, cy - 40);
    headPath.quadraticBezierTo(cx + 74, cy - 24, cx + 82 + cheekPuff, cy + 4);
    headPath.quadraticBezierTo(cx + 90 + cheekPuff, cy + 26, cx + 76, cy + 45);
    headPath.quadraticBezierTo(cx + 42, cy + 56, cx, cy + 54);
    headPath.quadraticBezierTo(cx - 42, cy + 56, cx - 76, cy + 45);
    headPath.quadraticBezierTo(cx - 90 - cheekPuff, cy + 26, cx - 82 - cheekPuff, cy + 4);
    headPath.quadraticBezierTo(cx - 74, cy - 24, cx - 62, cy - 40);
    headPath.quadraticBezierTo(cx - 38, cy - 54, cx, cy - 54);
    headPath.close();

    final headBounds = headPath.getBounds();

    // 1. Soft 3D drop shadow behind head
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawPath(headPath.shift(const Offset(0, 5)), shadowPaint);

    // 2. Base fur: 3D Volumetric Radial Gradient (Key light from top-left)
    final baseHeadPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 1.15,
        colors: [
          Color(0xFFFFFFFF), // Specular diffuse highlight
          Color(0xFFFFFDF8),
          Color(0xFFF7F1E7),
          Color(0xFFE9DECf), // Ambient occlusion shadow at base/chin
        ],
        stops: [0.0, 0.45, 0.82, 1.0],
      ).createShader(headBounds);

    canvas.drawPath(headPath, baseHeadPaint);

    // 3. Left Ear & Forehead Slate Grey 3D Patch (Asymmetrical, matching reference image!)
    canvas.save();
    canvas.clipPath(headPath);

    final patchPath = Path();
    patchPath.moveTo(cx - 32, cy - 56);
    patchPath.quadraticBezierTo(cx - 16, cy - 26, cx - 22, cy + 2);
    patchPath.quadraticBezierTo(cx - 46, cy + 10, cx - 88, cy + 2);
    patchPath.lineTo(cx - 98, cy - 44);
    patchPath.lineTo(cx - 32, cy - 56);
    patchPath.close();

    final patchRect = patchPath.getBounds();
    final patchPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF64748B),
          Color(0xFF475569),
          Color(0xFF334155),
        ],
      ).createShader(patchRect);

    canvas.drawPath(patchPath, patchPaint);
    canvas.restore();
  }

  void _drawCheeks(Canvas canvas, double cx, double cy) {
    final blushPaint = Paint()
      ..color = const Color(0xFFFF8DA1).withValues(alpha: 0.46)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    // Left blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 52, cy + 18), width: 22, height: 12),
      blushPaint,
    );
    // Right blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 52, cy + 18), width: 22, height: 12),
      blushPaint,
    );
  }

  void _draw3DEyes(Canvas canvas, double cx, double cy) {
    final eyeCenterY = cy - 4;
    const eyeDistX = 31.0;
    const eyeWidth = 27.0;
    const eyeHeight = 33.0;

    final leftEyeCenter = Offset(cx - eyeDistX, eyeCenterY);
    final rightEyeCenter = Offset(cx + eyeDistX, eyeCenterY);

    final bool isSleeping = state == CatMascotState.idle;
    final bool isSuccess = state == CatMascotState.success;
    final bool isError = state == CatMascotState.error;

    final bool leftEyeCovered = coverProgress > 0.65;
    final bool rightEyeCovered = coverProgress > 0.65 && peekProgress < 0.45;

    // 1. LEFT EYE
    if (!leftEyeCovered) {
      if (isSleeping || isSuccess) {
        _draw3DClosedEye(canvas, leftEyeCenter, isHappy: isSuccess, isLeftEye: true);
      } else {
        _draw3DOpenEye(
          canvas,
          leftEyeCenter,
          eyeWidth,
          eyeHeight,
          lookProgress,
          isError: isError,
          blink: blinkProgress,
        );
      }
    }

    // 2. RIGHT EYE
    if (!rightEyeCovered) {
      if (isSleeping || (isSuccess && coverProgress < 0.5)) {
        _draw3DClosedEye(canvas, rightEyeCenter, isHappy: isSuccess, isLeftEye: false);
      } else {
        final effectiveLook = (coverProgress > 0.5 && peekProgress > 0.4) ? 0.35 : lookProgress;
        _draw3DOpenEye(
          canvas,
          rightEyeCenter,
          eyeWidth,
          eyeHeight,
          effectiveLook,
          isError: isError,
          blink: (coverProgress > 0.5) ? 0.0 : blinkProgress,
        );
      }
    }
  }

  void _draw3DOpenEye(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    double look, {
    required bool isError,
    required double blink,
  }) {
    final scleraRect = Rect.fromCenter(center: center, width: w, height: h);

    canvas.save();
    final scleraRRect = RRect.fromRectAndRadius(scleraRect, Radius.circular(w / 2));
    canvas.clipRRect(scleraRRect);

    // Sclera with soft top shadow
    final scleraPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE2E8F0),
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
        ],
        stops: [0.0, 0.35, 1.0],
      ).createShader(scleraRect);
    canvas.drawRRect(scleraRRect, scleraPaint);

    // Pupil calculations: lookProgress 0.0 to 1.0 -> travel -12.5px to +12.5px
    final pupilOffsetX = (look - 0.5) * 13.0;
    final pupilOffsetY = isError ? -1.5 : 3.0;
    final pupilCenter = Offset(center.dx + pupilOffsetX, center.dy + pupilOffsetY);

    // 3D Volumetric Glossy Iris / Pupil
    final pupilRadius = isError ? 8.0 : 10.5;
    final irisRect = Rect.fromCircle(center: pupilCenter, radius: pupilRadius);

    final irisPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 0.9,
        colors: [
          Color(0xFF2C3E50),
          Color(0xFF182330),
          Color(0xFF0B1017),
        ],
      ).createShader(irisRect);
    canvas.drawCircle(pupilCenter, pupilRadius, irisPaint);

    // Corneal reflection arc at bottom of iris (glossy anime look)
    final reflectionArc = Path();
    reflectionArc.addArc(
      Rect.fromCircle(center: pupilCenter, radius: pupilRadius * 0.75),
      0.6,
      1.9,
    );
    canvas.drawPath(
      reflectionArc,
      Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Primary Specular Glint (top-left)
    canvas.drawCircle(
      Offset(pupilCenter.dx - pupilRadius * 0.36, pupilCenter.dy - pupilRadius * 0.38),
      pupilRadius * 0.38,
      Paint()..color = Colors.white,
    );

    // Secondary Specular Glint (bottom-right)
    canvas.drawCircle(
      Offset(pupilCenter.dx + pupilRadius * 0.36, pupilCenter.dy + pupilRadius * 0.36),
      pupilRadius * 0.20,
      Paint()..color = Colors.white,
    );

    // Blink eyelid
    if (blink > 0.05) {
      final lidHeight = h * blink;
      final lidPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF3ECE1),
          ],
        ).createShader(Rect.fromLTWH(scleraRect.left, scleraRect.top, scleraRect.width, lidHeight));

      canvas.drawRect(
        Rect.fromLTWH(scleraRect.left, scleraRect.top, scleraRect.width, lidHeight),
        lidPaint,
      );

      final lashPaint = Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(scleraRect.left, scleraRect.top + lidHeight),
        Offset(scleraRect.right, scleraRect.top + lidHeight),
        lashPaint,
      );
    }

    canvas.restore();
  }

  void _draw3DClosedEye(Canvas canvas, Offset center, {required bool isHappy, required bool isLeftEye}) {
    final arcPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isHappy) {
      path.moveTo(center.dx - 12, center.dy + 4);
      path.quadraticBezierTo(center.dx, center.dy - 8, center.dx + 12, center.dy + 4);
    } else {
      // Peaceful deep sleep eye curve matching the close-up reference photo
      if (isLeftEye) {
        // Sloping naturally down and outwards from inner corner to outer cheek
        path.moveTo(center.dx + 12, center.dy);
        path.quadraticBezierTo(center.dx, center.dy + 9, center.dx - 12, center.dy + 5.5);
        // Outer eyeliner flick
        path.quadraticBezierTo(center.dx - 14.5, center.dy + 4.5, center.dx - 16.5, center.dy + 2.5);

        // Sleepy lid crease fold
        final foldPaint = Paint()
          ..color = const Color(0xFFC4B5A5).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round;
        final foldPath = Path();
        foldPath.moveTo(center.dx + 9, center.dy - 5.5);
        foldPath.quadraticBezierTo(center.dx, center.dy - 3.5, center.dx - 9, center.dy - 1.0);
        canvas.drawPath(foldPath, foldPaint);
      } else {
        path.moveTo(center.dx - 12, center.dy);
        path.quadraticBezierTo(center.dx, center.dy + 9, center.dx + 12, center.dy + 5.5);
        // Outer eyeliner flick
        path.quadraticBezierTo(center.dx + 14.5, center.dy + 4.5, center.dx + 16.5, center.dy + 2.5);

        // Sleepy lid crease fold
        final foldPaint = Paint()
          ..color = const Color(0xFFC4B5A5).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round;
        final foldPath = Path();
        foldPath.moveTo(center.dx - 9, center.dy - 5.5);
        foldPath.quadraticBezierTo(center.dx, center.dy - 3.5, center.dx + 9, center.dy - 1.0);
        canvas.drawPath(foldPath, foldPaint);
      }
    }
    canvas.drawPath(path, arcPaint);
  }

  void _drawNoseAndMouth(Canvas canvas, double cx, double cy) {
    // 3D Button Nose
    final noseCenterY = cy + 13.0;
    final nosePath = Path();
    nosePath.moveTo(cx - 4.8, noseCenterY - 2.8);
    nosePath.lineTo(cx + 4.8, noseCenterY - 2.8);
    nosePath.lineTo(cx, noseCenterY + 3.5);
    nosePath.close();

    final nosePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.4),
        radius: 0.8,
        colors: [
          Color(0xFFFF9EA9),
          Color(0xFFFF6B81),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, noseCenterY), radius: 5));
    canvas.drawPath(nosePath, nosePaint);

    canvas.drawCircle(Offset(cx - 1.0, noseCenterY - 1.5), 1.1, Paint()..color = Colors.white);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    if (state == CatMascotState.success) {
      final mouthPath = Path();
      mouthPath.moveTo(cx - 9, noseCenterY + 5);
      mouthPath.quadraticBezierTo(cx, noseCenterY + 17, cx + 9, noseCenterY + 5);
      mouthPath.close();

      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFFF5277));
      canvas.drawPath(mouthPath, mouthPaint);

      final tonguePath = Path();
      tonguePath.moveTo(cx - 5, noseCenterY + 12);
      tonguePath.quadraticBezierTo(cx, noseCenterY + 8, cx + 5, noseCenterY + 12);
      tonguePath.quadraticBezierTo(cx, noseCenterY + 16.5, cx - 5, noseCenterY + 12);
      canvas.drawPath(tonguePath, Paint()..color = const Color(0xFFFF8DA1));
    } else if (state == CatMascotState.error) {
      final mouthPath = Path();
      mouthPath.moveTo(cx - 8, noseCenterY + 9);
      mouthPath.quadraticBezierTo(cx - 3, noseCenterY + 4, cx, noseCenterY + 8);
      mouthPath.quadraticBezierTo(cx + 4, noseCenterY + 12, cx + 8, noseCenterY + 7);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      final mouthPath = Path();
      mouthPath.moveTo(cx - 9, noseCenterY + 6);
      mouthPath.quadraticBezierTo(cx - 4.5, noseCenterY + 10.5, cx, noseCenterY + 5.5);
      mouthPath.quadraticBezierTo(cx + 4.5, noseCenterY + 10.5, cx + 9, noseCenterY + 6);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CatHeadAndBodyPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.lookProgress != lookProgress ||
        oldDelegate.coverProgress != coverProgress ||
        oldDelegate.peekProgress != peekProgress ||
        oldDelegate.happyProgress != happyProgress ||
        oldDelegate.blinkProgress != blinkProgress ||
        oldDelegate.breathProgress != breathProgress ||
        oldDelegate.headLiftProgress != headLiftProgress;
  }
}

/// ============================================================================
/// LAYER 3 PAINTER: 3D Paws and Forearms
/// Rendered in front of the white card, resting directly on the card rim!
/// ============================================================================
class _CatPawsForegroundPainter extends CustomPainter {
  final CatMascotState state;
  final double coverProgress;
  final double peekProgress;
  final double happyProgress;
  final double headLiftProgress;
  final double breathProgress;
  final double cardRimY;

  _CatPawsForegroundPainter({
    required this.state,
    required this.coverProgress,
    required this.peekProgress,
    required this.happyProgress,
    required this.headLiftProgress,
    required this.breathProgress,
    required this.cardRimY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Resting Paws Position:
    // Sitting directly ON TOP of the white card's upper rim (cardRimY),
    // hooking slightly over the front edge of the card!
    const pawWidth = 48.0;
    const pawHeight = 36.0;

    final restLeftPaw = Offset(cx - 48, cardRimY - pawHeight * 0.38);
    final restRightPaw = Offset(cx + 48, cardRimY - pawHeight * 0.38);

    // Eye covering positions (covering eyes at cx ± 31, eyeY ~86)
    final sleepDip = (1.0 - headLiftProgress) * 9.0;
    final breathOffset = state == CatMascotState.idle ? breathProgress * 1.8 : 0.0;
    final cy = (cardRimY - 56.0) + sleepDip + breathOffset;
    final eyeY = cy - 4;

    final coverLeftPaw = Offset(cx - 31, eyeY);
    final coverRightPaw = Offset(cx + 31, eyeY);

    // Peeking position for right paw (lowered by ~34px, tilted outward)
    final peekRightPaw = Offset(cx + 54, eyeY + 34);

    // Celebratory positions (raised high)
    final happyLeftPaw = Offset(cx - 72, cy - 42);
    final happyRightPaw = Offset(cx + 72, cy - 42);

    // Left Paw Pos & Rotation
    Offset leftPos = Offset.lerp(restLeftPaw, coverLeftPaw, coverProgress)!;
    if (happyProgress > 0) {
      leftPos = Offset.lerp(leftPos, happyLeftPaw, happyProgress)!;
    }
    final double leftAngle = math.sin(coverProgress * math.pi) * 0.28 - happyProgress * 0.42;

    // Right Paw Pos & Rotation
    Offset rightPos = Offset.lerp(restRightPaw, coverRightPaw, coverProgress)!;
    if (peekProgress > 0) {
      rightPos = Offset.lerp(rightPos, peekRightPaw, peekProgress)!;
    }
    if (happyProgress > 0) {
      rightPos = Offset.lerp(rightPos, happyRightPaw, happyProgress)!;
    }
    final double rightAngle = -math.sin(coverProgress * math.pi) * 0.28 +
        peekProgress * 0.38 +
        happyProgress * 0.42;

    // 1. Forearms connecting from behind the card rim up to the paws
    _drawForearm(canvas, Offset(cx - 68, cardRimY + 30), leftPos, pawWidth, isLeft: true);
    _drawForearm(canvas, Offset(cx + 68, cardRimY + 30), rightPos, pawWidth, isLeft: false);

    // 2. Draw Left & Right 3D Paws
    _drawSingle3DPaw(
      canvas,
      leftPos,
      pawWidth,
      pawHeight,
      angle: leftAngle,
      isLeft: true,
      cardRimY: cardRimY,
    );
    _drawSingle3DPaw(
      canvas,
      rightPos,
      pawWidth,
      pawHeight,
      angle: rightAngle,
      isLeft: false,
      cardRimY: cardRimY,
    );
  }

  void _drawForearm(
    Canvas canvas,
    Offset shoulderAnchor,
    Offset pawCenter,
    double pawWidth, {
    required bool isLeft,
  }) {
    // Only visible when paws lift off the card rim toward the eyes or in celebration
    if (coverProgress < 0.08 && happyProgress < 0.08) return;

    final armPath = Path();
    final halfW = pawWidth / 2;

    armPath.moveTo(shoulderAnchor.dx - halfW * 0.9, shoulderAnchor.dy);
    armPath.lineTo(pawCenter.dx - halfW * 0.7, pawCenter.dy);
    armPath.lineTo(pawCenter.dx + halfW * 0.7, pawCenter.dy);
    armPath.lineTo(shoulderAnchor.dx + halfW * 0.9, shoulderAnchor.dy);
    armPath.close();

    final armPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFDF9),
          Color(0xFFF3ECE0),
          Color(0xFFE2D6C5),
        ],
      ).createShader(armPath.getBounds());

    canvas.drawPath(armPath, armPaint);
  }

  void _drawSingle3DPaw(
    Canvas canvas,
    Offset center,
    double width,
    double height, {
    required double angle,
    required bool isLeft,
    required double cardRimY,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (angle != 0.0) {
      canvas.rotate(angle);
    }

    final halfW = width / 2;
    final halfH = height / 2;

    // Contact shadow cast directly onto the white card surface below the paw!
    // Fades out when paws lift up off the card.
    final double shadowOpacity = (1.0 - coverProgress).clamp(0.0, 1.0) *
        (1.0 - happyProgress).clamp(0.0, 1.0);

    if (shadowOpacity > 0.05) {
      final shadowPath = Path();
      shadowPath.addOval(
        Rect.fromCenter(
          center: Offset(0, halfH * 0.75),
          width: width * 1.05,
          height: height * 0.52,
        ),
      );
      canvas.drawPath(
        shadowPath,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.14 * shadowOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
      );
    }

    // 3D Chubby Paw Path with 4 rounded finger/toe lobes (matching reference photo)
    final pawPath = Path();
    pawPath.moveTo(-halfW * 0.90, -halfH * 0.65);
    pawPath.quadraticBezierTo(0, -halfH * 0.95, halfW * 0.90, -halfH * 0.65);

    // Toe 4 (rightmost)
    pawPath.quadraticBezierTo(halfW * 1.08, 0, halfW * 0.96, halfH * 0.60);
    pawPath.quadraticBezierTo(halfW * 0.82, halfH * 1.08, halfW * 0.52, halfH * 0.92);

    // Toe 3 (center-right)
    pawPath.quadraticBezierTo(halfW * 0.28, halfH * 1.15, halfW * 0.05, halfH * 0.95);

    // Toe 2 (center-left)
    pawPath.quadraticBezierTo(-halfW * 0.22, halfH * 1.15, -halfW * 0.52, halfH * 0.92);

    // Toe 1 (leftmost)
    pawPath.quadraticBezierTo(-halfW * 0.82, halfH * 1.08, -halfW * 0.96, halfH * 0.60);
    pawPath.quadraticBezierTo(-halfW * 1.08, 0, -halfW * 0.90, -halfH * 0.65);
    pawPath.close();

    // 3D Volumetric Radial Gradient
    final pawBounds = pawPath.getBounds();
    final pawPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.4),
        radius: 1.0,
        colors: [
          Color(0xFFFFFFFF), // Specular highlight on knuckle
          Color(0xFFFFFDF9),
          Color(0xFFF5EEE3),
          Color(0xFFE2D6C5), // Ambient occlusion underneath
        ],
        stops: [0.0, 0.45, 0.8, 1.0],
      ).createShader(pawBounds);

    canvas.drawPath(pawPath, pawPaint);

    // 3 Toe Creases (defining the 4 plump fingers)
    final creasePaint = Paint()
      ..color = const Color(0xFFD6C8B5).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Crease between toe 1 and 2
    canvas.drawLine(
      Offset(-halfW * 0.52, halfH * 0.25),
      Offset(-halfW * 0.52, halfH * 0.88),
      creasePaint,
    );
    // Crease between toe 2 and 3 (center)
    canvas.drawLine(
      Offset(0, halfH * 0.32),
      Offset(0, halfH * 0.92),
      creasePaint,
    );
    // Crease between toe 3 and 4
    canvas.drawLine(
      Offset(halfW * 0.52, halfH * 0.25),
      Offset(halfW * 0.52, halfH * 0.88),
      creasePaint,
    );

    // Soft warm pink toe pad glow
    final padPaint = Paint()
      ..color = const Color(0xFFFFB8C2).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: 16, height: 9),
      padPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CatPawsForegroundPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.coverProgress != coverProgress ||
        oldDelegate.peekProgress != peekProgress ||
        oldDelegate.happyProgress != happyProgress ||
        oldDelegate.headLiftProgress != headLiftProgress ||
        oldDelegate.breathProgress != breathProgress;
  }
}

/// ============================================================================
/// LAYER 4 PAINTER: Top Foreground Decorations (Zzz Dream Stream, Breath Puffs)
/// Rendered in front of EVERYTHING so it is NEVER hidden by the cat, paws, or card!
/// ============================================================================
class _CatDecorationsForegroundPainter extends CustomPainter {
  final CatMascotState state;
  final double breathProgress;
  final double zzzProgress;
  final double headLiftProgress;
  final double cardRimY;

  _CatDecorationsForegroundPainter({
    required this.state,
    required this.breathProgress,
    required this.zzzProgress,
    required this.headLiftProgress,
    required this.cardRimY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final sleepDip = (1.0 - headLiftProgress) * 10.0;
    final breathOffset = state == CatMascotState.idle ? breathProgress * 2.0 : 0.0;
    final cy = (cardRimY - 56.0) + sleepDip + breathOffset;

    if (state == CatMascotState.idle) {
      // 1. Soft breath snoring puff lines next to the sleeping right cheek
      final puffPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.75 * (1.0 - breathProgress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      final breathArc1 = Path();
      breathArc1.addArc(
        Rect.fromCircle(center: Offset(cx + 48, cy + 8), radius: 6.5 + breathProgress * 3.5),
        -0.5,
        1.1,
      );
      canvas.drawPath(breathArc1, puffPaint);

      final breathArc2 = Path();
      breathArc2.addArc(
        Rect.fromCircle(center: Offset(cx + 48, cy + 8), radius: 11.5 + breathProgress * 4.5),
        -0.5,
        1.1,
      );
      canvas.drawPath(breathArc2, puffPaint);

      // 2. Extra Prominent, Continuous looping Zzz dream stream: 4 staggered floating particles
      // Placed in the TOP FOREGROUND LAYER so it floats clearly over card, paws, and face!
      const particleOffsets = [0.0, 0.25, 0.5, 0.75];

      for (int i = 0; i < particleOffsets.length; i++) {
        final double t = (zzzProgress + particleOffsets[i]) % 1.0;

        // Quadratic Bézier curve: Start (right cheek) -> Control -> End (high in sky)
        final startP = Offset(cx + 50, cy);
        final controlP = Offset(cx + 76, cy - 42);
        final endP = Offset(cx + 104, cy - 96);

        final double oneMinusT = 1.0 - t;
        final double px = oneMinusT * oneMinusT * startP.dx +
            2 * oneMinusT * t * controlP.dx +
            t * t * endP.dx +
            math.sin(t * math.pi * 3) * 3.2;
        final double py = oneMinusT * oneMinusT * startP.dy +
            2 * oneMinusT * t * controlP.dy +
            t * t * endP.dy;

        // Smooth Opacity envelope: Fades in during first 18%, stays solid, fades out in last 22%
        double opacity = 1.0;
        if (t < 0.18) {
          opacity = t / 0.18;
        } else if (t > 0.78) {
          opacity = (1.0 - t) / 0.22;
        }

        // Much larger, prominent font size: 16px -> 34px as it floats!
        final double fontSize = 16.0 + t * 18.0;
        final String text = t < 0.32 ? 'z' : 'Z';
        final double rotation = -0.15 + t * 0.35 + math.sin(t * math.pi * 2) * 0.10;

        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(rotation);

        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: opacity),
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: const Color(0xFF00A3E0).withValues(alpha: 0.75 * opacity),
                  blurRadius: 9,
                  offset: const Offset(0, 2),
                ),
                Shadow(
                  color: const Color(0xFF0E2A47).withValues(alpha: 0.45 * opacity),
                  blurRadius: 4,
                  offset: const Offset(1, 1.5),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
    } else if (state == CatMascotState.error) {
      final dropPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.8,
          colors: [
            Color(0xFF67E8F9),
            Color(0xFF0284C7),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx + 64, cy - 25), radius: 10));

      final dropPath = Path();
      const dropX = 64.0;
      final dropY = cy - 30;
      dropPath.moveTo(cx + dropX, dropY);
      dropPath.quadraticBezierTo(cx + dropX + 6.5, dropY + 8, cx + dropX + 5.5, dropY + 14);
      dropPath.arcToPoint(Offset(cx + dropX - 5.5, dropY + 14), radius: const Radius.circular(5.5));
      dropPath.quadraticBezierTo(cx + dropX - 6.5, dropY + 8, cx + dropX, dropY);
      canvas.drawPath(dropPath, dropPaint);
      canvas.drawCircle(Offset(cx + dropX - 2, dropY + 10), 1.8, Paint()..color = Colors.white);
    } else if (state == CatMascotState.success) {
      final leavesPaint = Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.9);
      final goldPaint = Paint()..color = const Color(0xFFFBBF24);

      canvas.drawCircle(Offset(cx - 78, cy - 45), 5.5, leavesPaint);
      canvas.drawCircle(Offset(cx + 80, cy - 40), 5.0, leavesPaint);
      canvas.drawCircle(Offset(cx - 65, cy - 70), 4.0, goldPaint);
      canvas.drawCircle(Offset(cx + 68, cy - 74), 4.5, goldPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CatDecorationsForegroundPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.breathProgress != breathProgress ||
        oldDelegate.zzzProgress != zzzProgress ||
        oldDelegate.headLiftProgress != headLiftProgress;
  }
}

/// Standalone fallback wrapper for InteractiveCatMascot
class InteractiveCatMascot extends StatelessWidget {
  final CatMascotState state;
  final double lookProgress;
  final double size;

  const InteractiveCatMascot({
    super.key,
    required this.state,
    this.lookProgress = 0.5,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: InteractiveCatMascotCardLayout(
        state: state,
        lookProgress: lookProgress,
        cardChild: const SizedBox.shrink(),
      ),
    );
  }
}

