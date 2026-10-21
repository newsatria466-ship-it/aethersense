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

  // Animated values
  late Animation<double> _coverAnimation;
  late Animation<double> _peekAnimation;
  late Animation<double> _happyAnimation;
  late Animation<double> _blinkAnimation;

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

    // 4. Idle natural blink (loops every 3.5s with a quick 180ms blink)
    _blinkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _blinkAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 92),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 4),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 4),
    ]).animate(_blinkAnimController);

    // 5. Idle breathing wobble
    _wobbleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

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
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size * 1.25, widget.size),
              painter: _CatMascotPainter(
                state: widget.state,
                lookProgress: lookVal,
                coverProgress: _coverAnimation.value,
                peekProgress: _peekAnimation.value,
                happyProgress: _happyAnimation.value,
                blinkProgress: _blinkAnimation.value,
                breathProgress: _wobbleAnimController.value,
              ),
            );
          },
        );
      },
    );
  }
}

class _CatMascotPainter extends CustomPainter {
  final CatMascotState state;
  final double lookProgress;
  final double coverProgress;
  final double peekProgress;
  final double happyProgress;
  final double blinkProgress;
  final double breathProgress;

  _CatMascotPainter({
    required this.state,
    required this.lookProgress,
    required this.coverProgress,
    required this.peekProgress,
    required this.happyProgress,
    required this.blinkProgress,
    required this.breathProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Breathing motion shifts head vertically by ~1.5px
    final cy = size.height * 0.58 + (state == CatMascotState.idle ? breathProgress * 1.8 : 0.0);
    final cardEdgeY = size.height * 0.96; // Where the cat touches the top of the card

    // 1. Draw Decorative Accents (Sleep Zzz, Error Sweat/Question, Success Confetti)
    _drawDecorations(canvas, cx, cy);

    // 2. Ears
    _drawEars(canvas, cx, cy);

    // 3. Head & Grey Patch
    _drawHead(canvas, cx, cy);

    // 4. Blushing Cheeks
    _drawCheeks(canvas, cx, cy);

    // 5. Eyes & Pupils
    _drawEyes(canvas, cx, cy);

    // 6. Nose & Mouth
    _drawNoseAndMouth(canvas, cx, cy);

    // 7. Paws / Hands (Layered on top to cover eyes or rest on card edge)
    _drawPaws(canvas, cx, cy, cardEdgeY);
  }

  void _drawDecorations(Canvas canvas, double cx, double cy) {
    if (state == CatMascotState.idle) {
      // Draw gentle blue "Zzz"
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'z',
          style: TextStyle(
            color: const Color(0xFF00A3E0).withValues(alpha: 0.6 + breathProgress * 0.3),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(cx + 42, cy - 42 - breathProgress * 4));

      final textPainterBig = TextPainter(
        text: TextSpan(
          text: 'Z',
          style: TextStyle(
            color: const Color(0xFF00A3E0).withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterBig.paint(canvas, Offset(cx + 52, cy - 56 - breathProgress * 5));
    } else if (state == CatMascotState.error) {
      // Draw blue sweat drop on right temple
      final paintDrop = Paint()..color = const Color(0xFF00A3E0);
      final dropPath = Path();
      const dropX = 46.0;
      final dropY = cy - 24;
      dropPath.moveTo(cx + dropX, dropY);
      dropPath.quadraticBezierTo(cx + dropX + 5, dropY + 6, cx + dropX + 4, dropY + 11);
      dropPath.arcToPoint(Offset(cx + dropX - 4, dropY + 11), radius: const Radius.circular(4));
      dropPath.quadraticBezierTo(cx + dropX - 5, dropY + 6, cx + dropX, dropY);
      canvas.drawPath(dropPath, paintDrop);
    } else if (state == CatMascotState.success) {
      // Draw green leaves/confetti floating around
      final leavesPaint = Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.85);
      final goldPaint = Paint()..color = const Color(0xFFFBBF24);

      canvas.drawCircle(Offset(cx - 58, cy - 36), 4.5, leavesPaint);
      canvas.drawCircle(Offset(cx + 62, cy - 30), 4.0, leavesPaint);
      canvas.drawCircle(Offset(cx - 48, cy - 54), 3.0, goldPaint);
      canvas.drawCircle(Offset(cx + 50, cy - 58), 3.5, goldPaint);
    }
  }

  void _drawEars(Canvas canvas, double cx, double cy) {
    // Left Ear (Dark Slate Grey patch side)
    final leftEarPath = Path();
    leftEarPath.moveTo(cx - 48, cy - 18);
    leftEarPath.lineTo(cx - 58, cy - 56); // Tip of left ear
    leftEarPath.quadraticBezierTo(cx - 28, cy - 48, cx - 18, cy - 36);
    leftEarPath.close();

    final leftEarPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawPath(leftEarPath, leftEarPaint);

    // Left Inner Ear (Muted pink)
    final leftInnerEar = Path();
    leftInnerEar.moveTo(cx - 44, cy - 22);
    leftInnerEar.lineTo(cx - 52, cy - 50);
    leftInnerEar.quadraticBezierTo(cx - 30, cy - 44, cx - 24, cy - 34);
    leftInnerEar.close();
    canvas.drawPath(leftInnerEar, Paint()..color = const Color(0xFFD69BA6));

    // Right Ear (Cream/White side)
    final rightEarPath = Path();
    rightEarPath.moveTo(cx + 48, cy - 18);
    rightEarPath.lineTo(cx + 58, cy - 56); // Tip of right ear
    rightEarPath.quadraticBezierTo(cx + 28, cy - 48, cx + 18, cy - 36);
    rightEarPath.close();

    final rightEarPaint = Paint()..color = const Color(0xFFFFFDF9);
    canvas.drawPath(rightEarPath, rightEarPaint);

    // Right Inner Ear (Cute pastel pink)
    final rightInnerEar = Path();
    rightInnerEar.moveTo(cx + 44, cy - 22);
    rightInnerEar.lineTo(cx + 52, cy - 50);
    rightInnerEar.quadraticBezierTo(cx + 30, cy - 44, cx + 24, cy - 34);
    rightInnerEar.close();
    canvas.drawPath(rightInnerEar, Paint()..color = const Color(0xFFFFAEBC));
  }

  void _drawHead(Canvas canvas, double cx, double cy) {
    // Chubby, rounded cat head path
    final headRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(cx, cy), width: 114, height: 86),
      topLeft: const Radius.circular(46),
      topRight: const Radius.circular(46),
      bottomLeft: const Radius.circular(42),
      bottomRight: const Radius.circular(42),
    );

    // Base fur: Soft cream/white
    final baseHeadPaint = Paint()..color = const Color(0xFFFFFDF9);
    canvas.drawRRect(headRect, baseHeadPaint);

    // Left Ear & Forehead Slate Grey Patch
    canvas.save();
    canvas.clipRRect(headRect);

    final patchPath = Path();
    patchPath.moveTo(cx - 60, cy - 50);
    patchPath.lineTo(cx - 5, cy - 50);
    patchPath.quadraticBezierTo(cx - 6, cy - 12, cx - 34, cy + 2);
    patchPath.quadraticBezierTo(cx - 58, cy - 6, cx - 60, cy - 15);
    patchPath.close();

    final patchPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawPath(patchPath, patchPaint);
    canvas.restore();

    // Subtle gentle outline for definition
    final outlinePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(headRect, outlinePaint);
  }

  void _drawCheeks(Canvas canvas, double cx, double cy) {
    final blushPaint = Paint()
      ..color = const Color(0xFFFF9AA2).withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;

    // Left blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 36, cy + 14), width: 14, height: 8),
      blushPaint,
    );
    // Right blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 36, cy + 14), width: 14, height: 8),
      blushPaint,
    );
  }

  void _drawEyes(Canvas canvas, double cx, double cy) {
    final eyeCenterY = cy - 2;
    const eyeDistX = 22.0;
    const eyeWidth = 18.0;
    const eyeHeight = 22.0;

    final leftEyeCenter = Offset(cx - eyeDistX, eyeCenterY);
    final rightEyeCenter = Offset(cx + eyeDistX, eyeCenterY);

    final bool isSleeping = state == CatMascotState.idle;
    final bool isSuccess = state == CatMascotState.success;
    final bool isError = state == CatMascotState.error;

    // Both eyes covered by paws?
    // Left eye is covered if coverProgress > 0.6
    final bool leftEyeCovered = coverProgress > 0.65;
    // Right eye is covered if coverProgress > 0.65 UNLESS peeking!
    final bool rightEyeCovered = coverProgress > 0.65 && peekProgress < 0.45;

    // 1. LEFT EYE
    if (!leftEyeCovered) {
      if (isSleeping || isSuccess) {
        _drawClosedEyeArc(canvas, leftEyeCenter, isHappy: isSuccess);
      } else {
        _drawOpenEye(
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
        _drawClosedEyeArc(canvas, rightEyeCenter, isHappy: isSuccess);
      } else {
        // If peeking, right eye looks slightly downward & curious
        final effectiveLook = (coverProgress > 0.5 && peekProgress > 0.4) ? 0.35 : lookProgress;
        _drawOpenEye(
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

  void _drawOpenEye(
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
    // Clip to eye shape
    final scleraRRect = RRect.fromRectAndRadius(scleraRect, Radius.circular(w / 2));
    canvas.clipRRect(scleraRRect);

    // Sclera background (clean white)
    canvas.drawRRect(scleraRRect, Paint()..color = Colors.white);

    // Pupil movement calculations:
    // lookProgress goes 0.0 (left) to 1.0 (right)
    // Horizontal travel: -4.5px to +4.5px
    final pupilOffsetX = (look - 0.5) * 9.0;
    // Vertical travel: looking slightly downward toward the keyboard (+2.5px)
    final pupilOffsetY = isError ? -1.0 : 2.5;

    final pupilCenter = Offset(center.dx + pupilOffsetX, center.dy + pupilOffsetY);

    // Glossy Dark Iris/Pupil
    final irisPaint = Paint()..color = const Color(0xFF1E293B);
    final pupilRadius = isError ? 5.5 : 7.2;
    canvas.drawCircle(pupilCenter, pupilRadius, irisPaint);

    // Primary Specular Glint (big white dot, top-left)
    final glintPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(pupilCenter.dx - pupilRadius * 0.36, pupilCenter.dy - pupilRadius * 0.38),
      pupilRadius * 0.38,
      glintPaint,
    );

    // Secondary Specular Glint (tiny white dot, bottom-right)
    canvas.drawCircle(
      Offset(pupilCenter.dx + pupilRadius * 0.36, pupilCenter.dy + pupilRadius * 0.36),
      pupilRadius * 0.20,
      glintPaint,
    );

    // Blink eyelid (covers top of eye during blink)
    if (blink > 0.05) {
      final lidPaint = Paint()..color = const Color(0xFFFFFDF9);
      final lidHeight = h * blink;
      canvas.drawRect(
        Rect.fromLTWH(scleraRect.left, scleraRect.top, scleraRect.width, lidHeight),
        lidPaint,
      );
      // Eyelash line
      final lashPaint = Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(scleraRect.left, scleraRect.top + lidHeight),
        Offset(scleraRect.right, scleraRect.top + lidHeight),
        lashPaint,
      );
    }

    canvas.restore();

    // Eye outline
    canvas.drawRRect(
      scleraRRect,
      Paint()
        ..color = const Color(0xFF334155).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawClosedEyeArc(Canvas canvas, Offset center, {required bool isHappy}) {
    final arcPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isHappy) {
      // Happy squinting eyes: ^ curve
      path.moveTo(center.dx - 9, center.dy + 3);
      path.quadraticBezierTo(center.dx, center.dy - 6, center.dx + 9, center.dy + 3);
    } else {
      // Gentle sleeping eyes: ⌒ curve
      path.moveTo(center.dx - 9, center.dy - 1);
      path.quadraticBezierTo(center.dx, center.dy + 7, center.dx + 9, center.dy - 1);
    }
    canvas.drawPath(path, arcPaint);
  }

  void _drawNoseAndMouth(Canvas canvas, double cx, double cy) {
    // Nose (Soft pink triangle)
    final noseCenterY = cy + 9.5;
    final nosePath = Path();
    nosePath.moveTo(cx - 3.5, noseCenterY - 2.0);
    nosePath.lineTo(cx + 3.5, noseCenterY - 2.0);
    nosePath.lineTo(cx, noseCenterY + 2.5);
    nosePath.close();

    final nosePaint = Paint()..color = const Color(0xFFFF8DA1);
    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    if (state == CatMascotState.success) {
      // Open joyful smile (D shape)
      final mouthPath = Path();
      mouthPath.moveTo(cx - 7, noseCenterY + 4);
      mouthPath.quadraticBezierTo(cx, noseCenterY + 14, cx + 7, noseCenterY + 4);
      mouthPath.close();

      final openMouthPaint = Paint()..color = const Color(0xFFFF6B8B);
      canvas.drawPath(mouthPath, openMouthPaint);
      canvas.drawPath(mouthPath, mouthPaint);
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
      // Left curve
      mouthPath.moveTo(cx - 7, noseCenterY + 5);
      mouthPath.quadraticBezierTo(cx - 3.5, noseCenterY + 8.5, cx, noseCenterY + 4.5);
      // Right curve
      mouthPath.quadraticBezierTo(cx + 3.5, noseCenterY + 8.5, cx + 7, noseCenterY + 5);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  void _drawPaws(Canvas canvas, double cx, double cy, double cardEdgeY) {
    // Paw dimensions
    const pawWidth = 32.0;
    const pawHeight = 24.0;

    // Resting positions (resting on card edge)
    final restLeftPaw = Offset(cx - 36, cardEdgeY - pawHeight * 0.55);
    final restRightPaw = Offset(cx + 36, cardEdgeY - pawHeight * 0.55);

    // Covered positions (covering eyes at cx ± 22, cy - 2)
    final coverLeftPaw = Offset(cx - 22, cy - 2);
    final coverRightPaw = Offset(cx + 22, cy - 2);

    // Peeking position for right paw (lowered by ~28px and tilted slightly right)
    final peekRightPaw = Offset(cx + 38, cy + 24);

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

    // DRAW LEFT PAW
    _drawSinglePaw(canvas, leftPos, pawWidth, pawHeight, angle: leftAngle);

    // DRAW RIGHT PAW
    _drawSinglePaw(canvas, rightPos, pawWidth, pawHeight, angle: rightAngle);
  }

  void _drawSinglePaw(
    Canvas canvas,
    Offset center,
    double width,
    double height, {
    double angle = 0.0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (angle != 0.0) {
      canvas.rotate(angle);
    }

    final pawRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      Radius.circular(height / 2),
    );

    // Soft drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRRect(pawRect.shift(const Offset(0, 2)), shadowPaint);

    // Paw fur (soft clean cream/white)
    final pawPaint = Paint()..color = const Color(0xFFFFFDF9);
    canvas.drawRRect(pawRect, pawPaint);

    // Thin gentle outline
    final outlinePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(pawRect, outlinePaint);

    // Cute pink paw pads / toe creases
    final padPaint = Paint()..color = const Color(0xFFFFB8C2).withValues(alpha: 0.55);
    // Center main pad
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 3), width: 10, height: 7),
      padPaint,
    );
    // 3 toe pads
    canvas.drawCircle(const Offset(-7, -3), 2.3, padPaint);
    canvas.drawCircle(const Offset(0, -5), 2.5, padPaint);
    canvas.drawCircle(const Offset(7, -3), 2.3, padPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CatMascotPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.lookProgress != lookProgress ||
        oldDelegate.coverProgress != coverProgress ||
        oldDelegate.peekProgress != peekProgress ||
        oldDelegate.happyProgress != happyProgress ||
        oldDelegate.blinkProgress != blinkProgress ||
        oldDelegate.breathProgress != breathProgress;
  }
}
