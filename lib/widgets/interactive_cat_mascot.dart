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

  // Physical layout constants
  static const double mascotHeaderHeight = 152.0; // Space reserved above card for cat head
  static const double cardRimY = mascotHeaderHeight; // Exact Y position of the card's top edge

  @override
  void initState() {
    super.initState();

    // 1. Cover eyes animation (300ms natural bouncy cubic)
    _coverAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _coverAnimation = CurvedAnimation(
      parent: _coverAnimController,
      curve: Curves.easeOutCubic,
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
    // Head posture: calm resting (0.0) vs active/alert (1.0)
    if (state == CatMascotState.idle) {
      _headPoseAnimController.reverse();
    } else {
      _headPoseAnimController.forward();
    }

    switch (state) {
      case CatMascotState.passwordHidden:
        // 5-stage sequence: normal -> eyes close -> paws rise -> paws cover eyes -> hold
        _coverAnimController.forward();
        _peekAnimController.reverse();
        _happyAnimController.reverse();
        break;

      case CatMascotState.passwordVisible:
        // Peek: left paw covers left eye, right paw slides aside so right eye peeks!
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
      tween: Tween<double>(begin: 0.5, end: widget.lookProgress),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      builder: (context, lookVal, _) {

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
    // When covering eyes, head lifts up an extra 18px so the chest/torso & armpits are clearly visible!
    final sleepDip = (1.0 - headLiftProgress) * 10.0;
    final breathOffset = state == CatMascotState.idle ? breathProgress * 2.0 : 0.0;
    final coverLift = coverProgress * 18.0;
    final cy = (cardRimY - 56.0) + sleepDip + breathOffset - coverLift;

    // 1. Tail wagging gently on the right side behind torso & card
    _draw3DTail(canvas, cx, cy, cardRimY);

    // 2. Torso & Chest rising from behind the card
    _drawTorsoAndShoulders(canvas, cx, cy, cardRimY);

    // 3. 3D Volumetric Ears (Left slate-grey, Right white-cream matching reference!)
    _draw3DEars(canvas, cx, cy);

    // 4. Large 3D Chubby Head
    _draw3DHead(canvas, cx, cy);

    // 5. Airbrushed Blushing Cheeks
    _drawCheeks(canvas, cx, cy);

    // 6. 3D Glossy Eyes & Pupils (Idle=sleep, Email=subtle pupil tracking, PasswordHidden=cover, Visible=peek)
    _draw3DEyes(canvas, cx, cy);

    // 7. Button Nose & Expressive Cat Mouth
    _drawNoseAndMouth(canvas, cx, cy);
  }

  void _draw3DTail(Canvas canvas, double cx, double cy, double cardRimY) {
    final double wag = math.sin(breathProgress * math.pi) * 4.5;
    final tailPath = Path();
    tailPath.moveTo(cx + 52, cardRimY + 4);
    tailPath.cubicTo(
      cx + 96,
      cardRimY + 2,
      cx + 114,
      cardRimY - 26 + wag,
      cx + 98,
      cardRimY - 38 + wag,
    );
    tailPath.cubicTo(
      cx + 88,
      cardRimY - 45 + wag,
      cx + 80,
      cardRimY - 34 + wag,
      cx + 84,
      cardRimY - 24 + wag,
    );
    tailPath.cubicTo(
      cx + 88,
      cardRimY - 12 + wag * 0.5,
      cx + 68,
      cardRimY - 10,
      cx + 48,
      cardRimY - 10,
    );
    tailPath.close();

    // Soft tail shadow
    canvas.drawPath(
      tailPath.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0xFF1E293B).withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );

    // Slate grey tail base
    canvas.drawPath(
      tailPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF6B778D),
            Color(0xFF838FA4),
          ],
        ).createShader(tailPath.getBounds()),
    );

    // White-cream tail tip clipped to tailPath
    canvas.save();
    canvas.clipPath(tailPath);
    canvas.drawCircle(
      Offset(cx + 96, cardRimY - 33 + wag),
      14.0,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.3),
          radius: 1.0,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFCF5),
            Color(0xFFEADFCC),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx + 96, cardRimY - 33 + wag), radius: 14)),
    );
    canvas.restore();
  }

  void _drawTorsoAndShoulders(Canvas canvas, double cx, double cy, double cardRimY) {
    // Smooth 3D torso/chest visible above cardRimY when head lifts
    final torsoPath = Path();
    torsoPath.moveTo(cx - 52, cy + 32);
    torsoPath.quadraticBezierTo(cx - 62, cy + 56, cx - 64, cardRimY + 60);
    torsoPath.lineTo(cx + 64, cardRimY + 60);
    torsoPath.quadraticBezierTo(cx + 62, cy + 56, cx + 52, cy + 32);
    torsoPath.close();

    final torsoRect = torsoPath.getBounds();
    final torsoPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, 0.25),
        radius: 0.9,
        colors: [
          Color(0xFFFFFCF5), // Bright chest center
          Color(0xFFF3ECE0),
          Color(0xFFE0D4C2), // Soft AO at sides/armpits
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(torsoRect);

    canvas.drawPath(torsoPath, torsoPaint);

    // Soft chin ambient occlusion shadow cast onto the chest
    final chinShadowPaint = Paint()
      ..color = const Color(0xFF3E2D24).withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 52), width: 92, height: 22),
      chinShadowPaint,
    );
  }



  void _draw3DEars(Canvas canvas, double cx, double cy) {
    // --- LEFT EAR (Soft rounded 3D clay ear, shorter & wider like Frame 3) ---
    final leftEarPath = Path();
    leftEarPath.moveTo(cx - 30, cy - 46);
    leftEarPath.quadraticBezierTo(cx - 46, cy - 66, cx - 68, cy - 72);
    leftEarPath.quadraticBezierTo(cx - 82, cy - 74, cx - 82, cy - 58);
    leftEarPath.quadraticBezierTo(cx - 80, cy - 38, cx - 66, cy - 18);
    leftEarPath.close();

    final leftEarRect = leftEarPath.getBounds();
    final leftEarPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFA0ABBE),
          Color(0xFF838FA4),
          Color(0xFF6B778D),
        ],
      ).createShader(leftEarRect);

    canvas.drawPath(leftEarPath, leftEarPaint);

    // Left Inner Ear (Warm pastel peach cavity with depth)
    final leftInnerEar = Path();
    leftInnerEar.moveTo(cx - 40, cy - 42);
    leftInnerEar.quadraticBezierTo(cx - 52, cy - 58, cx - 68, cy - 62);
    leftInnerEar.quadraticBezierTo(cx - 72, cy - 46, cx - 62, cy - 26);
    leftInnerEar.close();

    canvas.drawPath(
      leftInnerEar,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3B5BE),
            Color(0xFFD9939E),
          ],
        ).createShader(leftInnerEar.getBounds()),
    );

    // --- RIGHT EAR (Soft White/Cream side matching reference image!) ---
    final rightEarPath = Path();
    rightEarPath.moveTo(cx + 30, cy - 46);
    rightEarPath.quadraticBezierTo(cx + 46, cy - 66, cx + 68, cy - 72);
    rightEarPath.quadraticBezierTo(cx + 82, cy - 74, cx + 82, cy - 58);
    rightEarPath.quadraticBezierTo(cx + 80, cy - 38, cx + 66, cy - 18);
    rightEarPath.close();

    final rightEarRect = rightEarPath.getBounds();
    final rightEarPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFFFCF5),
          Color(0xFFE8DFD3),
        ],
      ).createShader(rightEarRect);

    canvas.drawPath(rightEarPath, rightEarPaint);

    // Right Inner Ear (Cute pastel pink cavity with depth)
    final rightInnerEar = Path();
    rightInnerEar.moveTo(cx + 40, cy - 42);
    rightInnerEar.quadraticBezierTo(cx + 52, cy - 58, cx + 68, cy - 62);
    rightInnerEar.quadraticBezierTo(cx + 72, cy - 46, cx + 62, cy - 26);
    rightInnerEar.close();

    canvas.drawPath(
      rightInnerEar,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFC5CE),
            Color(0xFFF39CA9),
          ],
        ).createShader(rightInnerEar.getBounds()),
    );
  }

  void _draw3DHead(Canvas canvas, double cx, double cy) {
    // Sculpted 3D Clay/Vinyl Organic Head Shape with chubby cheeks
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

    // 1. Soft 3D ambient drop shadow behind head
    final shadowPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawPath(headPath.shift(const Offset(0, 6)), shadowPaint);

    // 2. Base fur: 3D Volumetric Soft-Clay Radial Gradient
    final baseHeadPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.35),
        radius: 1.05,
        colors: [
          Color(0xFFFFFFFF), // Top diffuse highlight
          Color(0xFFFFFCF5), // Warm cream clay
          Color(0xFFF6EFE3), // Soft midtone
          Color(0xFFE3D7C5), // Ambient occlusion shadow at chin/cheeks
        ],
        stops: [0.0, 0.45, 0.80, 1.0],
      ).createShader(headBounds);

    canvas.drawPath(headPath, baseHeadPaint);

    // 3. Asymmetrical Left Forehead Slate Grey 3D Patch (matching reference image!)
    canvas.save();
    canvas.clipPath(headPath);

    final leftPatchPath = Path();
    leftPatchPath.moveTo(cx - 10, cy - 56);
    leftPatchPath.quadraticBezierTo(cx - 16, cy - 24, cx - 36, cy - 10);
    leftPatchPath.quadraticBezierTo(cx - 64, cy + 2, cx - 94, cy - 2);
    leftPatchPath.lineTo(cx - 96, cy - 58);
    leftPatchPath.close();

    canvas.drawPath(
      leftPatchPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF94A0B4),
            Color(0xFF7B879D),
            Color(0xFF667288),
          ],
        ).createShader(leftPatchPath.getBounds()),
    );

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
    final bool isClosingEyes = coverProgress > 0.12;
    final bool isSuccess = state == CatMascotState.success;
    final bool isError = state == CatMascotState.error;

    // During passwordHidden: both eyes closed then covered.
    // During passwordVisible (peek): left eye stays covered, right paw slides down to reveal right eye!
    final bool leftEyeCovered = coverProgress > 0.68;
    final bool rightEyeCovered = coverProgress > 0.68 && peekProgress < 0.45;
    final bool isPeekingRightEye = coverProgress > 0.5 && peekProgress > 0.4;

    // 1. LEFT EYE
    if (!leftEyeCovered) {
      if (isSleeping || isClosingEyes || isSuccess) {
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
      if (isSleeping || (isClosingEyes && !isPeekingRightEye) || (isSuccess && coverProgress < 0.5)) {
        _draw3DClosedEye(canvas, rightEyeCenter, isHappy: isSuccess, isLeftEye: false);
      } else {
        final effectiveLook = isPeekingRightEye ? 0.42 : lookProgress;
        _draw3DOpenEye(
          canvas,
          rightEyeCenter,
          eyeWidth,
          eyeHeight,
          effectiveLook,
          isError: isError,
          blink: isPeekingRightEye ? 0.0 : blinkProgress,
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

    // Pupil calculations: natural horizontal travel (-6.0px to +6.0px) + gentle downward gaze
    final pupilOffsetX = (look - 0.5) * 12.0;
    final pupilOffsetY = isError ? -1.5 : 3.5;
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
    final shadowPaint = Paint()
      ..color = const Color(0xFF3E3D4B).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);

    final arcPaint = Paint()
      ..color = const Color(0xFF424354)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isHappy) {
      path.moveTo(center.dx - 12, center.dy + 4);
      path.quadraticBezierTo(center.dx, center.dy - 8, center.dx + 12, center.dy + 4);
    } else {
      // Peaceful deep sleep eye curve matching 3D Frame 1
      if (isLeftEye) {
        path.moveTo(center.dx + 12, center.dy + 1);
        path.quadraticBezierTo(center.dx, center.dy + 9, center.dx - 14, center.dy + 3.5);
      } else {
        path.moveTo(center.dx - 12, center.dy + 1);
        path.quadraticBezierTo(center.dx, center.dy + 9, center.dx + 14, center.dy + 3.5);
      }
    }
    canvas.drawPath(path.shift(const Offset(0, 1.5)), shadowPaint);
    canvas.drawPath(path, arcPaint);
  }

  void _drawNoseAndMouth(Canvas canvas, double cx, double cy) {
    // 3D Rounded Button Nose
    final noseCenterY = cy + 12.5;
    final nosePath = Path();
    nosePath.moveTo(cx - 5.2, noseCenterY - 2.2);
    nosePath.quadraticBezierTo(cx, noseCenterY - 4.0, cx + 5.2, noseCenterY - 2.2);
    nosePath.quadraticBezierTo(cx + 5.5, noseCenterY + 0.5, cx + 1.2, noseCenterY + 3.6);
    nosePath.quadraticBezierTo(cx, noseCenterY + 4.4, cx - 1.2, noseCenterY + 3.6);
    nosePath.quadraticBezierTo(cx - 5.5, noseCenterY + 0.5, cx - 5.2, noseCenterY - 2.2);
    nosePath.close();

    // Soft shadow under nose
    canvas.drawPath(
      nosePath.shift(const Offset(0, 1.4)),
      Paint()
        ..color = const Color(0xFF3E3D4B).withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    final nosePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.15, -0.35),
        radius: 0.9,
        colors: [
          Color(0xFFFFA6B4),
          Color(0xFFF47A8F),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, noseCenterY), radius: 6));
    canvas.drawPath(nosePath, nosePaint);

    canvas.drawCircle(
      Offset(cx - 1.3, noseCenterY - 1.4),
      1.2,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // 3D Plush Mouth (:3)
    final mouthShadowPaint = Paint()
      ..color = const Color(0xFF3E3D4B).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    final mouthPaint = Paint()
      ..color = const Color(0xFF4A4552)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
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
      canvas.drawPath(mouthPath.shift(const Offset(0, 1.2)), mouthShadowPaint);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      final mouthPath = Path();
      mouthPath.moveTo(cx - 10, noseCenterY + 6.5);
      mouthPath.quadraticBezierTo(cx - 5, noseCenterY + 12.0, cx, noseCenterY + 5.5);
      mouthPath.quadraticBezierTo(cx + 5, noseCenterY + 12.0, cx + 10, noseCenterY + 6.5);
      canvas.drawPath(mouthPath.shift(const Offset(0, 1.2)), mouthShadowPaint);
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

    const pawWidth = 48.0;
    const pawHeight = 36.0;

    final restLeftPaw = Offset(cx - 48, cardRimY - pawHeight * 0.38);
    final restRightPaw = Offset(cx + 48, cardRimY - pawHeight * 0.38);

    // Synchronize vertical position with _CatHeadAndBodyPainter (including coverLift!)
    final sleepDip = (1.0 - headLiftProgress) * 10.0;
    final breathOffset = state == CatMascotState.idle ? breathProgress * 2.0 : 0.0;
    final coverLift = coverProgress * 18.0;
    final cy = (cardRimY - 56.0) + sleepDip + breathOffset - coverLift;
    final eyeY = cy - 4;

    // 0. Draw Smart City Tegal Blue Scarf with White Leaf Emblem on the neck
    // Overlapping slightly onto the top edge of the white card!
    _drawBlueScarf(canvas, cx, cy, cardRimY);

    // 1. When covering eyes (coverProgress > 0.05), render the short, rounded 3D plush arms + paws
    // whose elbows rest naturally on top of the white card's upper rim!
    if (coverProgress > 0.05) {
      canvas.save();
      final double clipBottom = cardRimY + 12.0;
      canvas.clipRect(Rect.fromLTRB(0, 0, size.width, clipBottom));

      // Draw Left Short Rounded 3D Arm + Paw cupping the left eye
      _drawSeamless3DCoverArm(
        canvas,
        cx: cx,
        cy: cy,
        eyeY: eyeY,
        cardRimY: cardRimY,
        progress: coverProgress,
        peekOffset: 0.0,
        isLeft: true,
      );

      // Draw Right Short Rounded 3D Arm + Paw
      _drawSeamless3DCoverArm(
        canvas,
        cx: cx,
        cy: cy,
        eyeY: eyeY,
        cardRimY: cardRimY,
        progress: coverProgress,
        peekOffset: peekProgress,
        isLeft: false,
      );

      canvas.restore();
    }

    // 2. Resting paws on top of the white card rim (fade out smoothly as cover arms take over)
    if (coverProgress < 0.35) {
      final double restOpacity = (1.0 - (coverProgress / 0.35)).clamp(0.0, 1.0);
      final happyLeftPaw = Offset(cx - 72, cy - 42);
      final happyRightPaw = Offset(cx + 72, cy - 42);

      Offset leftPos = restLeftPaw;
      Offset rightPos = restRightPaw;
      double leftAngle = 0.0;
      double rightAngle = 0.0;

      if (happyProgress > 0) {
        leftPos = Offset.lerp(leftPos, happyLeftPaw, happyProgress)!;
        rightPos = Offset.lerp(rightPos, happyRightPaw, happyProgress)!;
        leftAngle = -0.45 * happyProgress;
        rightAngle = 0.45 * happyProgress;
      }

      if (restOpacity < 1.0) {
        canvas.saveLayer(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = Colors.white.withValues(alpha: restOpacity),
        );
      }

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

      if (restOpacity < 1.0) {
        canvas.restore();
      }
    }
  }

  /// Renders the Smart City Tegal blue triangular scarf around the cat's neck
  /// with a crisp white leaf emblem in the center, overlapping slightly over the card rim.
  void _drawBlueScarf(Canvas canvas, double cx, double cy, double cardRimY) {
    final double scarfTopY = cy + 36;
    final double scarfTipY = cardRimY + 14;

    final scarfPath = Path();
    scarfPath.moveTo(cx - 50, scarfTopY);
    scarfPath.quadraticBezierTo(cx, scarfTopY + 12, cx + 50, scarfTopY);
    scarfPath.quadraticBezierTo(cx + 38, cardRimY - 2, cx + 5, scarfTipY);
    scarfPath.quadraticBezierTo(cx, scarfTipY + 3, cx - 5, scarfTipY);
    scarfPath.quadraticBezierTo(cx - 38, cardRimY - 2, cx - 50, scarfTopY);
    scarfPath.close();

    // Soft shadow cast onto the white card
    canvas.drawPath(
      scarfPath.shift(const Offset(0, 3.5)),
      Paint()
        ..color = const Color(0xFF0E2A47).withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );

    // Rich 3D blue fabric gradient
    canvas.drawPath(
      scarfPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2B82F6),
            Color(0xFF1565D8),
            Color(0xFF0C4A9E),
          ],
        ).createShader(scarfPath.getBounds()),
    );

    // White Smart City Tegal Leaf Emblem in the center of the scarf
    final double leafCx = cx;
    final double leafCy = (scarfTopY + scarfTipY) / 2 + 2;
    final leafPath = Path();
    leafPath.moveTo(leafCx - 8, leafCy + 6);
    leafPath.quadraticBezierTo(leafCx - 9, leafCy - 6, leafCx + 8, leafCy - 8);
    leafPath.quadraticBezierTo(leafCx + 9, leafCy + 5, leafCx - 8, leafCy + 6);
    leafPath.close();

    canvas.drawPath(
      leafPath,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    // Subtle blue vein inside the white leaf
    final veinPath = Path();
    veinPath.moveTo(leafCx - 6, leafCy + 4);
    veinPath.quadraticBezierTo(leafCx - 1, leafCy, leafCx + 5, leafCy - 5);
    canvas.drawPath(
      veinPath,
      Paint()
        ..color = const Color(0xFF1565D8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Renders a single continuous, short, rounded 3D plush arm + paw emerging from the shoulder
  /// with its elbow resting cleanly on the card rim and paw cupping the eye naturally!
  void _drawSeamless3DCoverArm(
    Canvas canvas, {
    required double cx,
    required double cy,
    required double eyeY,
    required double cardRimY,
    required double progress,
    required double peekOffset,
    required bool isLeft,
  }) {
    final double dir = isLeft ? -1.0 : 1.0;

    // Target paw tip (covering eye from outer/lower side inward)
    final double targetPawX = cx + dir * 24.0 + (isLeft ? 0.0 : peekOffset * 36.0);
    final double targetPawY = eyeY - 2.0 + (isLeft ? 0.0 : peekOffset * 30.0);

    // Interpolate paw tip from resting position on card rim to eye
    final double startX = cx + dir * 48.0;
    final double startY = cardRimY - 8.0;
    final double tipX = startX + (targetPawX - startX) * progress;
    final double tipY = startY + (targetPawY - startY) * progress;

    // Short rounded elbow resting gently on the white card rim (matching reference image!)
    final double elbowX = cx + dir * (84.0 + (isLeft ? 0.0 : peekOffset * 10.0));
    final double elbowY = cardRimY - 12.0;

    // Base resting on the card's upper rim
    final double baseOuterX = cx + dir * 72.0;
    final double baseInnerX = cx + dir * 44.0;
    final double baseY = cardRimY + 6.0;

    // Inner curve leaving blush cheeks & scarf visible
    final double innerElbowX = cx + dir * (56.0 + (isLeft ? 0.0 : peekOffset * 14.0));
    final double innerElbowY = cy + 28.0 + (isLeft ? 0.0 : peekOffset * 12.0);

    // Rounded 3-toe paw tip points
    final double topCrestX = tipX + dir * 18.0;
    final double topCrestY = tipY - 16.0;
    final double bottomPalmX = tipX + dir * 12.0;
    final double bottomPalmY = tipY + 15.0;

    final armPath = Path();
    armPath.moveTo(baseOuterX, baseY);
    armPath.cubicTo(
      elbowX + dir * 10.0,
      elbowY + 6.0,
      elbowX,
      elbowY - 24.0,
      topCrestX,
      topCrestY,
    );
    // Soft rounded toe lobes at the tip (3 plump fingers pointing inward!)
    armPath.quadraticBezierTo(tipX + dir * 4.0, tipY - 18.0, tipX, tipY - 8.0);
    armPath.quadraticBezierTo(tipX - dir * 5.0, tipY - 3.0, tipX - dir * 2.0, tipY + 2.0);
    armPath.quadraticBezierTo(tipX - dir * 5.0, tipY + 8.0, tipX + dir * 2.0, tipY + 13.0);
    armPath.quadraticBezierTo(bottomPalmX - dir * 4.0, bottomPalmY + 2.0, bottomPalmX, bottomPalmY);
    armPath.cubicTo(
      innerElbowX,
      innerElbowY - 4.0,
      innerElbowX - dir * 4.0,
      innerElbowY + 14.0,
      baseInnerX,
      baseY,
    );
    armPath.close();

    // 1. Soft 3D ambient shadow on the cat's face & card rim under the arm
    canvas.drawPath(
      armPath.shift(Offset(-dir * 2.5, 4.5)),
      Paint()
        ..color = const Color(0xFF3A2820).withValues(alpha: 0.16 * progress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0),
    );

    // 2. Volumetric 3D Soft-Clay Arm & Paw Gradient
    final armBounds = armPath.getBounds();
    final armPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(isLeft ? -0.25 : 0.25, -0.35),
        radius: 1.15,
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFFFFCF5),
          Color(0xFFF5EFE4),
          Color(0xFFE1D5C3),
        ],
        stops: const [0.0, 0.42, 0.78, 1.0],
      ).createShader(armBounds);

    canvas.drawPath(armPath, armPaint);

    // 3. Subtle soft finger indentation lines on the back of the paw
    final creasePaint = Paint()
      ..color = const Color(0xFFD6C8B6).withValues(alpha: 0.75 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(tipX - dir * 1.0, tipY - 5.5),
      Offset(tipX + dir * 8.0, tipY - 6.5),
      creasePaint,
    );
    canvas.drawLine(
      Offset(tipX - dir * 1.5, tipY + 3.0),
      Offset(tipX + dir * 7.5, tipY + 2.5),
      creasePaint,
    );
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

    // 1. Soft contact shadow cast on the cat's face behind the paw when covering eyes!
    if (coverProgress > 0.08) {
      final double faceShadowAlpha = (coverProgress * 0.22).clamp(0.0, 0.22);
      final faceShadowPaint = Paint()
        ..color = const Color(0xFF2C1E18).withValues(alpha: faceShadowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(isLeft ? 3.0 : -3.0, 6.0),
          width: width * 1.02,
          height: height * 0.92,
        ),
        faceShadowPaint,
      );
    }

    // 2. Contact shadow cast directly onto the white card surface below the paw!
    // Fades out when paws lift up off the card.
    final double cardShadowOpacity = (1.0 - coverProgress).clamp(0.0, 1.0) *
        (1.0 - happyProgress).clamp(0.0, 1.0);

    if (cardShadowOpacity > 0.05) {
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
          ..color = Colors.black.withValues(alpha: 0.14 * cardShadowOpacity)
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
      // 3D Glass Bubble Zzz Dream Stream while sleeping in standby
      const particleOffsets = [0.0, 0.28, 0.56];

      for (int i = 0; i < particleOffsets.length; i++) {
        final double t = (zzzProgress + particleOffsets[i]) % 1.0;

        final startP = Offset(cx + 52, cy);
        final controlP = Offset(cx + 76, cy - 38);
        final endP = Offset(cx + 98, cy - 86);

        final double oneMinusT = 1.0 - t;
        final double px = oneMinusT * oneMinusT * startP.dx +
            2 * oneMinusT * t * controlP.dx +
            t * t * endP.dx +
            math.sin(t * math.pi * 3) * 2.5;
        final double py = oneMinusT * oneMinusT * startP.dy +
            2 * oneMinusT * t * controlP.dy +
            t * t * endP.dy;

        double opacity = 1.0;
        if (t < 0.18) {
          opacity = t / 0.18;
        } else if (t > 0.78) {
          opacity = (1.0 - t) / 0.22;
        }

        final double bubbleRadius = 8.0 + t * 9.0;
        final double fontSize = 9.0 + t * 10.0;
        final String text = t < 0.32 ? 'z' : 'Z';
        final double rotation = -0.10 + t * 0.24 + math.sin(t * math.pi * 2) * 0.06;

        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(rotation);

        final bubbleRect = Rect.fromCircle(center: Offset.zero, radius: bubbleRadius);
        canvas.drawCircle(
          Offset.zero,
          bubbleRadius,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.35, -0.35),
              radius: 1.0,
              colors: [
                Colors.white.withValues(alpha: 0.85 * opacity),
                const Color(0xFFD6EAF8).withValues(alpha: 0.45 * opacity),
                const Color(0xFF9AC5E8).withValues(alpha: 0.35 * opacity),
              ],
            ).createShader(bubbleRect),
        );

        canvas.drawCircle(
          Offset.zero,
          bubbleRadius,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.75 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );

        canvas.drawCircle(
          Offset(-bubbleRadius * 0.38, -bubbleRadius * 0.38),
          bubbleRadius * 0.22,
          Paint()..color = Colors.white.withValues(alpha: 0.9 * opacity),
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: const Color(0xFF6B7B93).withValues(alpha: 0.85 * opacity),
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
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
    } else if (state == CatMascotState.passwordHidden) {
      // Cute yellow playful reaction lines on the left side of the cat's head (matching reference!)
      final sparkPaint = Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(cx - 102, cy - 36), Offset(cx - 114, cy - 42), sparkPaint);
      canvas.drawLine(Offset(cx - 105, cy - 22), Offset(cx - 120, cy - 22), sparkPaint);
      canvas.drawLine(Offset(cx - 100, cy - 8), Offset(cx - 112, cy - 2), sparkPaint);
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

