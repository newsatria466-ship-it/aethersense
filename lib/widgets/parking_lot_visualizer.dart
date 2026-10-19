import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ParkingSlotConfig {
  final int id;
  final String name;
  final double leftRatio;
  final double topRatio;
  final double widthRatio;
  final double heightRatio;
  final bool isTopRow;
  final String carAsset;
  final String carModelName;
  final String plateNumber;

  const ParkingSlotConfig({
    required this.id,
    required this.name,
    required this.leftRatio,
    required this.topRatio,
    required this.widthRatio,
    required this.heightRatio,
    required this.isTopRow,
    required this.carAsset,
    required this.carModelName,
    required this.plateNumber,
  });

  double get centerX => leftRatio + widthRatio / 2;
  double get centerY => topRatio + heightRatio / 2;
}

class ParkingLotVisualizer extends StatefulWidget {
  final int occupiedCount;
  final Set<int>? occupiedSlots;
  final int totalCount;
  final bool isEntryGateOpen;
  final bool isExitGateOpen;
  final Function(ParkingSlotConfig slot, bool isOccupied)? onSlotTap;
  final VoidCallback? onEntryGateTap;
  final VoidCallback? onExitGateTap;

  const ParkingLotVisualizer({
    super.key,
    required this.occupiedCount,
    this.occupiedSlots,
    this.totalCount = 9,
    this.isEntryGateOpen = false,
    this.isExitGateOpen = false,
    this.onSlotTap,
    this.onEntryGateTap,
    this.onExitGateTap,
  });

  @override
  State<ParkingLotVisualizer> createState() => ParkingLotVisualizerState();
}

class ParkingLotVisualizerState extends State<ParkingLotVisualizer> with TickerProviderStateMixin {
  // 9 Slots definition strictly mapped to the user diagram
  static const List<ParkingSlotConfig> slots = [
    // Top Row: 1 to 5
    ParkingSlotConfig(
      id: 1,
      name: 'Slot 1',
      leftRatio: 0.0215,
      topRatio: 0.0454,
      widthRatio: 0.1914,
      heightRatio: 0.3175,
      isTopRow: true,
      carAsset: 'assets/images/cars/car_1.png',
      carModelName: 'White Sedan',
      plateNumber: 'G 1042 TG',
    ),
    ParkingSlotConfig(
      id: 2,
      name: 'Slot 2',
      leftRatio: 0.2129,
      topRatio: 0.0454,
      widthRatio: 0.1895,
      heightRatio: 0.3175,
      isTopRow: true,
      carAsset: 'assets/images/cars/car_2.png',
      carModelName: 'Black Executive',
      plateNumber: 'G 8820 AA',
    ),
    ParkingSlotConfig(
      id: 3,
      name: 'Slot 3',
      leftRatio: 0.4023,
      topRatio: 0.0454,
      widthRatio: 0.1914,
      heightRatio: 0.3175,
      isTopRow: true,
      carAsset: 'assets/images/cars/car_3.png',
      carModelName: 'Silver Coupe',
      plateNumber: 'G 3190 BB',
    ),
    ParkingSlotConfig(
      id: 4,
      name: 'Slot 4',
      leftRatio: 0.5938,
      topRatio: 0.0454,
      widthRatio: 0.1914,
      heightRatio: 0.3175,
      isTopRow: true,
      carAsset: 'assets/images/cars/car_4.png',
      carModelName: 'Sport Crimson',
      plateNumber: 'G 4512 TT',
    ),
    ParkingSlotConfig(
      id: 5,
      name: 'Slot 5',
      leftRatio: 0.7852,
      topRatio: 0.0454,
      widthRatio: 0.1914,
      heightRatio: 0.3175,
      isTopRow: true,
      carAsset: 'assets/images/cars/car_5.png',
      carModelName: 'Electric Blue',
      plateNumber: 'G 9021 ZA',
    ),
    // Bottom Row: 6 to 9
    ParkingSlotConfig(
      id: 6,
      name: 'Slot 6',
      leftRatio: 0.0215,
      topRatio: 0.6122,
      widthRatio: 0.1768,
      heightRatio: 0.3515,
      isTopRow: false,
      carAsset: 'assets/images/cars/car_7.png',
      carModelName: 'Dark Grey SUV',
      plateNumber: 'G 7741 BG',
    ),
    ParkingSlotConfig(
      id: 7,
      name: 'Slot 7',
      leftRatio: 0.1982,
      topRatio: 0.6122,
      widthRatio: 0.1689,
      heightRatio: 0.3515,
      isTopRow: false,
      carAsset: 'assets/images/cars/car_8.png',
      carModelName: 'Sunset Orange',
      plateNumber: 'G 2108 LK',
    ),
    ParkingSlotConfig(
      id: 8,
      name: 'Slot 8',
      leftRatio: 0.3672,
      topRatio: 0.6122,
      widthRatio: 0.1689,
      heightRatio: 0.3515,
      isTopRow: false,
      carAsset: 'assets/images/cars/car_10.png',
      carModelName: 'Lime Green GT',
      plateNumber: 'G 5519 PT',
    ),
    ParkingSlotConfig(
      id: 9,
      name: 'Slot 9',
      leftRatio: 0.5361,
      topRatio: 0.6122,
      widthRatio: 0.1719,
      heightRatio: 0.3515,
      isTopRow: false,
      carAsset: 'assets/images/cars/car_11.png',
      carModelName: 'Blue Pickup',
      plateNumber: 'G 6400 DD',
    ),
  ];

  // Drive animation controller for cars driving through gate into a slot
  late AnimationController _driveAnimController;
  late Animation<double> _driveProgress;
  int? _simulatedTargetSlot;
  bool _isDrivingCar = false;

  // Pulse animation for vacant/available indicator LEDs
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _driveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _driveProgress = CurvedAnimation(
      parent: _driveAnimController,
      curve: Curves.easeInOutSine,
    );

    _driveAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isDrivingCar = false;
            _simulatedTargetSlot = null;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(ParkingLotVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If occupied count increased from outside (e.g. real MQTT event or manual), trigger drive-in animation
    if (widget.occupiedSlots != null && oldWidget.occupiedSlots != null) {
      final diff = widget.occupiedSlots!.difference(oldWidget.occupiedSlots!);
      if (diff.isNotEmpty && !_isDrivingCar) {
        animateCarEnteringSlot(diff.first);
      }
    } else if (widget.occupiedCount > oldWidget.occupiedCount && !_isDrivingCar) {
      final targetSlotId = widget.occupiedCount;
      if (targetSlotId <= slots.length) {
        animateCarEnteringSlot(targetSlotId);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _driveAnimController.dispose();
    super.dispose();
  }

  /// Trigger full car entry animation through IN gate to a specific slot
  void animateCarEnteringSlot(int slotId) {
    if (slotId < 1 || slotId > slots.length) return;
    setState(() {
      _simulatedTargetSlot = slotId;
      _isDrivingCar = true;
    });
    _driveAnimController.forward(from: 0.0);
  }

  /// Calculate position and heading along waypoint path
  Map<String, double> _calculateDrivePath(double t, ParkingSlotConfig target) {
    // Stage 1: (0.0 to 0.25) -> Enter from IN gate: from (0.78, 0.98) to (0.78, 0.65)
    // Stage 2: (0.25 to 0.45) -> Drive into center driving lane: to (0.78, 0.46)
    // Stage 3: (0.45 to 0.80) -> Turn left and drive west along center lane: to (target.centerX, 0.46)
    // Stage 4: (0.80 to 1.00) -> Steer into slot: to (target.centerX, target.centerY)

    double x = 0.78;
    double y = 0.98;
    double angle = 0.0; // facing UP

    if (t < 0.25) {
      final segT = t / 0.25;
      x = 0.78;
      y = 0.98 - segT * (0.98 - 0.65);
      angle = 0.0;
    } else if (t < 0.45) {
      final segT = (t - 0.25) / 0.20;
      x = 0.78;
      y = 0.65 - segT * (0.65 - 0.46);
      angle = 0.0;
    } else if (t < 0.80) {
      final segT = (t - 0.45) / 0.35;
      const startX = 0.78;
      final endX = target.centerX;
      x = startX + segT * (endX - startX);
      y = 0.46;
      angle = -math.pi / 2; // facing WEST (left)
    } else {
      final segT = (t - 0.80) / 0.20;
      x = target.centerX;
      if (target.isTopRow) {
        // Drive north into top bay
        y = 0.46 - segT * (0.46 - target.centerY);
        angle = 0.0; // facing UP
      } else {
        // Drive south into bottom bay
        y = 0.46 + segT * (target.centerY - 0.46);
        angle = math.pi; // facing DOWN
      }
    }

    return {'x': x, 'y': y, 'angle': angle};
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // Diagram aspect ratio: 1024 / 882 = ~1.161
        final double height = width * (882.0 / 1024.0);

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 1. Base Parking Map Image (Retouched crisp base diagram)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/parking_map_base.png',
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),

              // 2. Interactive Parking Bays (Slots 1 to 9)
              for (final slot in slots)
                _buildParkingSlot(slot, width, height),

              // 3. IN Barrier Gate (Animated Boom Barrier on IN lane)
              _buildBarrierGate(
                isOpen: widget.isEntryGateOpen || _isDrivingCar,
                pivotX: 0.758 * width,
                pivotY: 0.902 * height,
                armLength: 0.076 * width,
                isEntry: true,
                onTap: widget.onEntryGateTap,
              ),

              // 4. OUT Barrier Gate (Animated Boom Barrier on OUT lane)
              _buildBarrierGate(
                isOpen: widget.isExitGateOpen,
                pivotX: 0.898 * width,
                pivotY: 0.902 * height,
                armLength: 0.076 * width,
                isEntry: false,
                onTap: widget.onExitGateTap,
              ),

              // 5. Active Car Drive-in Animation (when simulated or MQTT vehicle entry occurs)
              if (_isDrivingCar && _simulatedTargetSlot != null)
                AnimatedBuilder(
                  animation: _driveProgress,
                  builder: (context, child) {
                    final target = slots.firstWhere((s) => s.id == _simulatedTargetSlot);
                    final state = _calculateDrivePath(_driveProgress.value, target);
                    final carW = target.widthRatio * width * 0.72;
                    final carH = target.heightRatio * height * 0.78;

                    return Positioned(
                      left: state['x']! * width - carW / 2,
                      top: state['y']! * height - carH / 2,
                      child: Transform.rotate(
                        angle: state['angle']!,
                        child: SizedBox(
                          width: carW,
                          height: carH,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Moving drop shadow
                              Positioned(
                                bottom: 2,
                                child: Container(
                                  width: carW * 0.85,
                                  height: carH * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Image.asset(
                                target.carAsset,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build individual parking bay overlay with top-down car and LED corner indicators
  Widget _buildParkingSlot(ParkingSlotConfig slot, double totalW, double totalH) {
    final bool isBaseOccupied = widget.occupiedSlots != null
        ? widget.occupiedSlots!.contains(slot.id)
        : slot.id <= widget.occupiedCount;

    final isOccupied = isBaseOccupied &&
        !(_isDrivingCar && _simulatedTargetSlot == slot.id && _driveProgress.value < 0.95);

    final slotLeft = slot.leftRatio * totalW;
    final slotTop = slot.topRatio * totalH;
    final slotW = slot.widthRatio * totalW;
    final slotH = slot.heightRatio * totalH;

    return Positioned(
      left: slotLeft,
      top: slotTop,
      width: slotW,
      height: slotH,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.onSlotTap != null) {
            widget.onSlotTap!(slot, isOccupied);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle glow highlight when empty / available
            if (!isOccupied)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.green.withValues(alpha: 0.03 * _pulseAnimation.value),
                    ),
                  );
                },
              ),

            // Top-down parked car (with smooth drive-in arrival animation)
            if (isOccupied)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, animVal, child) {
                  // For top row: slide up from lane (0.35 -> 0.0)
                  // For bottom row: slide down from lane (-0.35 -> 0.0)
                  final slideOffset = slot.isTopRow
                      ? Offset(0, (1.0 - animVal) * 0.35)
                      : Offset(0, -(1.0 - animVal) * 0.35);

                  final carWidth = slotW * 0.72;
                  final carHeight = slotH * 0.78;

                  return Transform.translate(
                    offset: Offset(
                      slideOffset.dx * slotW,
                      slideOffset.dy * slotH,
                    ),
                    child: Transform.rotate(
                      // Top row faces UP (0), bottom row faces DOWN (180 deg / pi)
                      angle: slot.isTopRow ? 0.0 : math.pi,
                      child: Opacity(
                        opacity: animVal.clamp(0.0, 1.0),
                        child: SizedBox(
                          width: carWidth,
                          height: carHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Realistic soft asphalt shadow
                              Positioned(
                                bottom: 1,
                                child: Container(
                                  width: carWidth * 0.88,
                                  height: carHeight * 0.72,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // High-res transparent top-down car
                              Image.asset(
                                slot.carAsset,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Slot status badge overlay in the bay
            Positioned(
              bottom: slot.isTopRow ? 6 : null,
              top: !slot.isTopRow ? 6 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isOccupied
                      ? AppColors.danger.withValues(alpha: 0.85)
                      : AppColors.green.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  isOccupied ? 'TERISI' : 'KOSONG',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dynamic Barrier Gate with animated rotating boom arm & housing indicator
  Widget _buildBarrierGate({
    required bool isOpen,
    required double pivotX,
    required double pivotY,
    required double armLength,
    required bool isEntry,
    VoidCallback? onTap,
  }) {
    // When closed: 0 rad (horizontal)
    // When open: -82 degrees (~ -1.43 rad, swinging up along lane)
    final targetAngle = isOpen ? -1.43 : 0.0;

    return Positioned(
      left: pivotX - 8,
      top: pivotY - 14,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: armLength + 20,
          height: 32,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Animated Boom Barrier Arm with Red/White Stripes
              Positioned(
                left: 10,
                top: 13,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: targetAngle),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  builder: (context, angle, child) {
                    return Transform(
                      transform: Matrix4.rotationZ(angle),
                      origin: const Offset(0, 3),
                      child: Container(
                        width: armLength,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: StripedBarrierArmPainter(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Gate Servo Housing Box with Status LED
              Positioned(
                left: 2,
                top: 7,
                child: Container(
                  width: 16,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isOpen ? AppColors.green : const Color(0xFF475569),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isOpen ? AppColors.green : AppColors.danger).withValues(alpha: 0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOpen ? const Color(0xFF00E676) : const Color(0xFFFF3B30),
                        boxShadow: [
                          BoxShadow(
                            color: isOpen ? const Color(0xFF00E676) : const Color(0xFFFF3B30),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for classic red-and-white diagonal striped boom gate arm
class StripedBarrierArmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintWhite = Paint()..color = Colors.white;

    // Background white base
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(2)),
      paintWhite,
    );

    // Diagonal red stripes
    const stripeWidth = 6.0;
    final paintStripe = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = stripeWidth
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(2)),
    );

    for (double x = -size.height; x < size.width + size.height; x += stripeWidth * 2) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paintStripe,
      );
    }

    // Black tip on the end of the arm
    canvas.drawRect(
      Rect.fromLTWH(size.width - 2, 0, 2, size.height),
      Paint()..color = Colors.black87,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
