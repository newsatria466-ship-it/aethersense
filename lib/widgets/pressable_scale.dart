import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tactile feedback widget with spring-like scale animation & subtle haptics
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final double scaleDownFactor;
  final Duration duration;
  final HitTestBehavior behavior;
  final bool enableHaptic;

  const PressableScale({
    super.key,
    required this.child,
    this.onPressed,
    this.onTap,
    this.scaleDownFactor = 0.94,
    this.duration = const Duration(milliseconds: 110),
    this.behavior = HitTestBehavior.opaque,
    this.enableHaptic = true,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  VoidCallback? get _effectiveAction => widget.onTap ?? widget.onPressed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_effectiveAction != null) {
      if (widget.enableHaptic) {
        HapticFeedback.lightImpact();
      }
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_effectiveAction != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (_effectiveAction != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _effectiveAction,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
