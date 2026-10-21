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

class InteractiveCatMascot extends StatefulWidget {
  final CatMascotState state;
  final double lookProgress; // 0.0 (far left) to 1.0 (far right)
  final double size;

  const InteractiveCatMascot({
    super.key,
    required this.state,
    this.lookProgress = 0.5,
    this.size = 150.0,
  });

  @override
  State<InteractiveCatMascot> createState() => _InteractiveCatMascotState();
}

class _InteractiveCatMascotState extends State<InteractiveCatMascot>
    with TickerProviderStateMixin {
  // Animation controllers for smooth physical transitions
  late AnimationController _coverAnimController; // Paws raising to cover eyes
  late AnimationController _peekAnimController; // Right paw lowering to peek
  late AnimationController _happyAnimController; // Success celebration
  late AnimationController _blinkAnimController; // Natural idle blinking
  late AnimationController _wobbleAnimController; // Subtle breathing/idle
  late AnimationController _headPoseAnimController; // Head lifting from sleep

  // Animated values
  late Animation<double> _coverAnimation;
  late Animation<double> _peekAnimation;
  late Animation<double> _happyAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _headPoseAnimation;

  // Smooth pupil tracking interpolation
  double _currentLookProgress = 0.5;

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
    _wobbleAnimController = AnimationController(
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

    _updateStateAnimations(widget.state, isInit: true);
  }

  @override
  void didUpdateWidget(InteractiveCatMascot oldWidget) {
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
    _wobbleAnimController.dispose();
    _headPoseAnimController.dispose();
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
            _wobbleAnimController,
            _headPoseAnimation,
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size * 1.30, widget.size),
              painter: _CatMascot3DPainter(
                state: widget.state,
                lookProgress: lookVal,
                coverProgress: _coverAnimation.value,
                peekProgress: _peekAnimation.value,
                happyProgress: _happyAnimation.value,
                blinkProgress: _blinkAnimation.value,
                breathProgress: _wobbleAnimController.value,
                headLiftProgress: _headPoseAnimation.value,
              ),
            );
          },
        );
      },
    );
  }
}

class _CatMascot3DPainter extends CustomPainter {
  final CatMascotState state;
  final double lookProgress;
  final double coverProgress;
  final double peekProgress;
  final double happyProgress;
  final double blinkProgress;
  final double breathProgress;
  final double headLiftProgress; // 0.0 = nestled sleeping pose, 1.0 = alert upright

  _CatMascot3DPainter({
    required this.state,
    required this.lookProgress,
    required this.coverProgress,
    required this.peekProgress,
    required this.happyProgress,
    required this.blinkProgress,
    required this.breathProgress,
    required this.headLiftProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Card rim reference: The bottom edge where the cat rests onto the white card
    final cardEdgeY = size.height * 0.94;

    // Head vertical positioning:
    // When sleeping (headLiftProgress = 0), the head dips down by ~6px so the chin
    // nestles comfortably between the paws. When alert (1.0), it lifts up slightly.
    final sleepDip = (1.0 - headLiftProgress) * 6.5;
    final breathOffset = state == CatMascotState.idle ? breathProgress * 1.6 : 0.0;
    final cy = size.height * 0.54 + sleepDip + breathOffset;

    // 1. Draw Decorative Accents (Sleep Zzz, Error Sweat/Question, Success Confetti)
    _drawDecorations(canvas, cx, cy);

    // 2. Ears with 3D Depth & Gradients
    _draw3DEars(canvas, cx, cy);

    // 3. Volumetric 3D Head & Soft Shading
    _draw3DHead(canvas, cx, cy);

    // 4. Soft Blushing Airbrush Cheeks
    _drawCheeks(canvas, cx, cy);

    // 5. 3D Glossy Anime Eyes & Pupils
    _draw3DEyes(canvas, cx, cy);

    // 6. 3D Button Nose & Expressive Cat Mouth
    _drawNoseAndMouth(canvas, cx, cy);

    // 7. 3D Chubby Paws resting/hanging naturally over the card edge
    _draw3DPaws(canvas, cx, cy, cardEdgeY);
  }

  void _drawDecorations(Canvas canvas, double cx, double cy) {
    if (state == CatMascotState.idle) {
      // Soft glowing blue "Zzz"
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'z',
          style: TextStyle(
            color: const Color(0xFF00A3E0).withValues(alpha: 0.55 + breathProgress * 0.3),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(cx + 44, cy - 42 - breathProgress * 4));

      final textPainterBig = TextPainter(
        text: TextSpan(
          text: 'Z',
          style: TextStyle(
            color: const Color(0xFF00A3E0).withValues(alpha: 0.85),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterBig.paint(canvas, Offset(cx + 56, cy - 58 - breathProgress * 5));
    } else if (state == CatMascotState.error) {
      // 3D glossy blue sweat drop on right temple
      final dropPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.8,
          colors: [
            Color(0xFF67E8F9),
            Color(0xFF0284C7),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx + 48, cy - 20), radius: 8));

      final dropPath = Path();
      const dropX = 48.0;
      final dropY = cy - 24;
      dropPath.moveTo(cx + dropX, dropY);
      dropPath.quadraticBezierTo(cx + dropX + 5.5, dropY + 7, cx + dropX + 4.5, dropY + 12);
      dropPath.arcToPoint(Offset(cx + dropX - 4.5, dropY + 12), radius: const Radius.circular(4.5));
      dropPath.quadraticBezierTo(cx + dropX - 5.5, dropY + 7, cx + dropX, dropY);
      canvas.drawPath(dropPath, dropPaint);

      // Highlight on drop
      canvas.drawCircle(Offset(cx + dropX - 1.5, dropY + 8), 1.5, Paint()..color = Colors.white);
    } else if (state == CatMascotState.success) {
      // Festive leaves and golden confetti
      final leavesPaint = Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.88);
      final goldPaint = Paint()..color = const Color(0xFFFBBF24);

      canvas.drawCircle(Offset(cx - 62, cy - 36), 5.0, leavesPaint);
      canvas.drawCircle(Offset(cx + 64, cy - 30), 4.5, leavesPaint);
      canvas.drawCircle(Offset(cx - 50, cy - 56), 3.5, goldPaint);
      canvas.drawCircle(Offset(cx + 52, cy - 60), 4.0, goldPaint);
    }
  }

  void _draw3DEars(Canvas canvas, double cx, double cy) {
    // --- LEFT EAR (Slate Grey Patch side with 3D gradient) ---
    final leftEarPath = Path();
    leftEarPath.moveTo(cx - 50, cy - 16);
    leftEarPath.lineTo(cx - 62, cy - 58); // Tip of left ear
    leftEarPath.quadraticBezierTo(cx - 30, cy - 50, cx - 18, cy - 36);
    leftEarPath.close();

    final leftEarRect = leftEarPath.getBounds();
    final leftEarPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5D6F82), // Soft 3D highlight
          Color(0xFF455566),
          Color(0xFF334151), // Ambient shadow
        ],
      ).createShader(leftEarRect);

    canvas.drawPath(leftEarPath, leftEarPaint);

    // Left Inner Ear (Muted pink cavity)
    final leftInnerEar = Path();
    leftInnerEar.moveTo(cx - 46, cy - 20);
    leftInnerEar.lineTo(cx - 55, cy - 52);
    leftInnerEar.quadraticBezierTo(cx - 32, cy - 44, cx - 24, cy - 34);
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
    rightEarPath.moveTo(cx + 50, cy - 16);
    rightEarPath.lineTo(cx + 62, cy - 58); // Tip of right ear
    rightEarPath.quadraticBezierTo(cx + 30, cy - 50, cx + 18, cy - 36);
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
    rightInnerEar.moveTo(cx + 46, cy - 20);
    rightInnerEar.lineTo(cx + 55, cy - 52);
    rightInnerEar.quadraticBezierTo(cx + 32, cy - 44, cx + 24, cy - 34);
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
    // Chubby, rounded 3D cat head with pillowed cheeks
    // When sleeping (headLiftProgress = 0), cheeks squish out slightly wider (122 vs 116)
    final headWidth = 116.0 + (1.0 - headLiftProgress) * 6.0;
    final headHeight = 88.0 - (1.0 - headLiftProgress) * 4.0;

    final headRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(cx, cy), width: headWidth, height: headHeight),
      topLeft: const Radius.circular(48),
      topRight: const Radius.circular(48),
      bottomLeft: const Radius.circular(44),
      bottomRight: const Radius.circular(44),
    );

    // Soft 3D drop shadow behind head
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.09)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawRRect(headRect.shift(const Offset(0, 4)), shadowPaint);

    // Base fur: 3D Volumetric Radial Gradient (Key light from top-left)
    final headGradientRect = headRect.outerRect;
    final baseHeadPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 1.15,
        colors: [
          Color(0xFFFFFFFF), // Direct specular diffuse highlight
          Color(0xFFFFFDF8),
          Color(0xFFF7F1E7),
          Color(0xFFE9DECf), // Ambient occlusion shadow at base/chin
        ],
        stops: [0.0, 0.45, 0.82, 1.0],
      ).createShader(headGradientRect);

    canvas.drawRRect(headRect, baseHeadPaint);

    // Left Ear & Forehead Slate Grey 3D Patch
    canvas.save();
    canvas.clipRRect(headRect);

    final patchPath = Path();
    patchPath.moveTo(cx - 64, cy - 54);
    patchPath.lineTo(cx - 4, cy - 54);
    patchPath.quadraticBezierTo(cx - 5, cy - 10, cx - 34, cy + 4);
    patchPath.quadraticBezierTo(cx - 62, cy - 4, cx - 64, cy - 14);
    patchPath.close();

    final patchRect = patchPath.getBounds();
    final patchPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5D6F82), // Soft 3D highlight
          Color(0xFF455566),
          Color(0xFF334151), // Ambient shadow
        ],
      ).createShader(patchRect);

    canvas.drawPath(patchPath, patchPaint);
    canvas.restore();
  }

  void _drawCheeks(Canvas canvas, double cx, double cy) {
    // Soft airbrush pink blush with Gaussian blur
    final blushPaint = Paint()
      ..color = const Color(0xFFFF8DA1).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    // Left blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 36, cy + 13), width: 16, height: 9),
      blushPaint,
    );
    // Right blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 36, cy + 13), width: 16, height: 9),
      blushPaint,
    );
  }

  void _draw3DEyes(Canvas canvas, double cx, double cy) {
    final eyeCenterY = cy - 2;
    const eyeDistX = 22.0;
    const eyeWidth = 19.0;
    const eyeHeight = 23.0;

    final leftEyeCenter = Offset(cx - eyeDistX, eyeCenterY);
    final rightEyeCenter = Offset(cx + eyeDistX, eyeCenterY);

    final bool isSleeping = state == CatMascotState.idle;
    final bool isSuccess = state == CatMascotState.success;
    final bool isError = state == CatMascotState.error;

    // Left eye is covered if coverProgress > 0.65
    final bool leftEyeCovered = coverProgress > 0.65;
    // Right eye is covered if coverProgress > 0.65 UNLESS peeking!
    final bool rightEyeCovered = coverProgress > 0.65 && peekProgress < 0.45;

    // 1. LEFT EYE
    if (!leftEyeCovered) {
      if (isSleeping || isSuccess) {
        _draw3DClosedEye(canvas, leftEyeCenter, isHappy: isSuccess);
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
        _draw3DClosedEye(canvas, rightEyeCenter, isHappy: isSuccess);
      } else {
        // If peeking, right eye looks slightly downward & curious
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
    // Clip to rounded eye shape
    final scleraRRect = RRect.fromRectAndRadius(scleraRect, Radius.circular(w / 2));
    canvas.clipRRect(scleraRRect);

    // Sclera with subtle top ambient shadow
    final scleraPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE2E8F0), // Subtle shadow under eyelid
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
        ],
        stops: [0.0, 0.35, 1.0],
      ).createShader(scleraRect);
    canvas.drawRRect(scleraRRect, scleraPaint);

    // Pupil movement calculations:
    // lookProgress goes 0.0 (left) to 1.0 (right)
    final pupilOffsetX = (look - 0.5) * 9.5;
    final pupilOffsetY = isError ? -1.0 : 2.2;
    final pupilCenter = Offset(center.dx + pupilOffsetX, center.dy + pupilOffsetY);

    // 3D Volumetric Glossy Iris / Pupil
    final pupilRadius = isError ? 5.8 : 7.6;
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

    // Corneal reflection arc at bottom of iris (giving luminous 3D anime look)
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
        ..strokeWidth = 1.3,
    );

    // Primary Specular Glint (big bright white reflection, top-left)
    canvas.drawCircle(
      Offset(pupilCenter.dx - pupilRadius * 0.36, pupilCenter.dy - pupilRadius * 0.38),
      pupilRadius * 0.38,
      Paint()..color = Colors.white,
    );

    // Secondary Specular Glint (tiny white reflection, bottom-right)
    canvas.drawCircle(
      Offset(pupilCenter.dx + pupilRadius * 0.36, pupilCenter.dy + pupilRadius * 0.36),
      pupilRadius * 0.20,
      Paint()..color = Colors.white,
    );

    // Blink eyelid (covers top of eye during blink)
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

      // Eyelash contour
      final lashPaint = Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(scleraRect.left, scleraRect.top + lidHeight),
        Offset(scleraRect.right, scleraRect.top + lidHeight),
        lashPaint,
      );
    }

    canvas.restore();
  }

  void _draw3DClosedEye(Canvas canvas, Offset center, {required bool isHappy}) {
    final arcPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isHappy) {
      // Happy squinting eyes: ^ curve
      path.moveTo(center.dx - 9, center.dy + 3);
      path.quadraticBezierTo(center.dx, center.dy - 6, center.dx + 9, center.dy + 3);
    } else {
      // Cozy, blissful sleeping eyes: ⌒ curve with slight upward flick (manja)
      path.moveTo(center.dx - 10, center.dy - 1);
      path.quadraticBezierTo(center.dx, center.dy + 7.5, center.dx + 8, center.dy - 0.5);
      path.quadraticBezierTo(center.dx + 10, center.dy - 2, center.dx + 11.5, center.dy - 3.5);
    }
    canvas.drawPath(path, arcPaint);
  }

  void _drawNoseAndMouth(Canvas canvas, double cx, double cy) {
    // 3D Button Nose (Coral pink with top highlight)
    final noseCenterY = cy + 9.5;
    final nosePath = Path();
    nosePath.moveTo(cx - 3.8, noseCenterY - 2.2);
    nosePath.lineTo(cx + 3.8, noseCenterY - 2.2);
    nosePath.lineTo(cx, noseCenterY + 2.8);
    nosePath.close();

    final nosePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.4),
        radius: 0.8,
        colors: [
          Color(0xFFFF9EA9),
          Color(0xFFFF6B81),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, noseCenterY), radius: 4));
    canvas.drawPath(nosePath, nosePaint);

    // Tiny specular dot on nose
    canvas.drawCircle(Offset(cx - 0.8, noseCenterY - 1.2), 0.9, Paint()..color = Colors.white);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;

    if (state == CatMascotState.success) {
      // Open joyful smile (D shape) with tongue
      final mouthPath = Path();
      mouthPath.moveTo(cx - 7, noseCenterY + 4);
      mouthPath.quadraticBezierTo(cx, noseCenterY + 14, cx + 7, noseCenterY + 4);
      mouthPath.close();

      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFFF5277));
      canvas.drawPath(mouthPath, mouthPaint);

      // Tongue
      final tonguePath = Path();
      tonguePath.moveTo(cx - 4, noseCenterY + 10);
      tonguePath.quadraticBezierTo(cx, noseCenterY + 7, cx + 4, noseCenterY + 10);
      tonguePath.quadraticBezierTo(cx, noseCenterY + 13.5, cx - 4, noseCenterY + 10);
      canvas.drawPath(tonguePath, Paint()..color = const Color(0xFFFF8DA1));
    } else if (state == CatMascotState.error) {
      // Worried wavy mouth
      final mouthPath = Path();
      mouthPath.moveTo(cx - 6, noseCenterY + 8);
      mouthPath.quadraticBezierTo(cx - 2, noseCenterY + 4, cx, noseCenterY + 7);
      mouthPath.quadraticBezierTo(cx + 3, noseCenterY + 10, cx + 6, noseCenterY + 6);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Classic cute 'w' cat mouth
      final mouthPath = Path();
      mouthPath.moveTo(cx - 7, noseCenterY + 5);
      mouthPath.quadraticBezierTo(cx - 3.5, noseCenterY + 8.5, cx, noseCenterY + 4.5);
      mouthPath.quadraticBezierTo(cx + 3.5, noseCenterY + 8.5, cx + 7, noseCenterY + 5);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  void _draw3DPaws(Canvas canvas, double cx, double cy, double cardEdgeY) {
    // 3D Paw dimensions (pillowy, rounded with 3 lobes)
    const pawWidth = 36.0;
    const pawHeight = 28.0;

    // Natural resting posture:
    // Paws sit directly ON TOP of the white card's upper rim (cardEdgeY),
    // with the bottom lobes slightly overlapping over the card front!
    final restLeftPaw = Offset(cx - 38, cardEdgeY - pawHeight * 0.42);
    final restRightPaw = Offset(cx + 38, cardEdgeY - pawHeight * 0.42);

    // Eye covering posture
    final coverLeftPaw = Offset(cx - 22, cy - 2);
    final coverRightPaw = Offset(cx + 22, cy - 2);

    // Peeking posture for right paw (lowered by ~28px and tilted slightly right)
    final peekRightPaw = Offset(cx + 38, cy + 26);

    // Happy celebrated positions (raised in air)
    final happyLeftPaw = Offset(cx - 52, cy - 32);
    final happyRightPaw = Offset(cx + 52, cy - 32);

    // 1. CALCULATE LEFT PAW POSITION & ROTATION
    Offset leftPos = Offset.lerp(restLeftPaw, coverLeftPaw, coverProgress)!;
    if (happyProgress > 0) {
      leftPos = Offset.lerp(leftPos, happyLeftPaw, happyProgress)!;
    }
    final double leftAngle = math.sin(coverProgress * math.pi) * 0.25 - happyProgress * 0.4;

    // 2. CALCULATE RIGHT PAW POSITION & ROTATION
    Offset rightPos = Offset.lerp(restRightPaw, coverRightPaw, coverProgress)!;
    if (peekProgress > 0) {
      rightPos = Offset.lerp(rightPos, peekRightPaw, peekProgress)!;
    }
    if (happyProgress > 0) {
      rightPos = Offset.lerp(rightPos, happyRightPaw, happyProgress)!;
    }
    final double rightAngle = -math.sin(coverProgress * math.pi) * 0.25 +
        peekProgress * 0.35 +
        happyProgress * 0.4;

    // DRAW LEFT 3D PAW
    _drawSingle3DPaw(canvas, leftPos, pawWidth, pawHeight, angle: leftAngle, isLeft: true);

    // DRAW RIGHT 3D PAW
    _drawSingle3DPaw(canvas, rightPos, pawWidth, pawHeight, angle: rightAngle, isLeft: false);
  }

  void _drawSingle3DPaw(
    Canvas canvas,
    Offset center,
    double width,
    double height, {
    required double angle,
    required bool isLeft,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (angle != 0.0) {
      canvas.rotate(angle);
    }

    // 1. Soft Ambient Cast Shadow onto the white card below the paw
    final shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCenter(center: const Offset(0, 8), width: width * 0.95, height: height * 0.55),
    );
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );

    // 2. 3D Pillowy Paw Shape with 3 rounded toe lobes
    // We construct a custom smooth path representing a chubby cat paw resting over an edge
    final pawPath = Path();
    final halfW = width / 2;
    final halfH = height / 2;

    // Top wrist/arm curve
    pawPath.moveTo(-halfW * 0.85, -halfH * 0.6);
    pawPath.quadraticBezierTo(0, -halfH * 0.9, halfW * 0.85, -halfH * 0.6);

    // Right side down to right toe lobe
    pawPath.quadraticBezierTo(halfW * 1.05, 0, halfW * 0.9, halfH * 0.6);
    pawPath.quadraticBezierTo(halfW * 0.65, halfH * 1.05, halfW * 0.35, halfH * 0.9);

    // Middle toe lobe
    pawPath.quadraticBezierTo(0, halfH * 1.15, -halfW * 0.35, halfH * 0.9);

    // Left toe lobe
    pawPath.quadraticBezierTo(-halfW * 0.65, halfH * 1.05, -halfW * 0.9, halfH * 0.6);
    pawPath.quadraticBezierTo(-halfW * 1.05, 0, -halfW * 0.85, -halfH * 0.6);
    pawPath.close();

    // 3. Volumetric 3D Gradient Fill
    final pawBounds = pawPath.getBounds();
    final pawPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.4),
        radius: 1.0,
        colors: [
          Color(0xFFFFFFFF), // Specular light on top knuckle
          Color(0xFFFFFDF9),
          Color(0xFFF5EEE3),
          Color(0xFFE2D6C5), // Ambient occlusion underneath toe cushions
        ],
        stops: [0.0, 0.45, 0.8, 1.0],
      ).createShader(pawBounds);

    canvas.drawPath(pawPath, pawPaint);

    // 4. Subtle Toe Crease Lines (giving defined plump 3D finger lobes)
    final creasePaint = Paint()
      ..color = const Color(0xFFD6C8B5).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Crease between left & middle lobe
    canvas.drawLine(
      Offset(-halfW * 0.32, halfH * 0.25),
      Offset(-halfW * 0.35, halfH * 0.85),
      creasePaint,
    );
    // Crease between middle & right lobe
    canvas.drawLine(
      Offset(halfW * 0.32, halfH * 0.25),
      Offset(halfW * 0.35, halfH * 0.85),
      creasePaint,
    );

    // 5. Cute soft pink toe pad glow
    final padPaint = Paint()
      ..color = const Color(0xFFFFB8C2).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 3), width: 10, height: 7),
      padPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CatMascot3DPainter oldDelegate) {
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
