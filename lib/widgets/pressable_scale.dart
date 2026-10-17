import 'package:flutter/material.dart';

/// Tactile feedback widget with spring-like scale animation
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final double scaleDownFactor;
  final Duration duration;
  final HitTestBehavior behavior;

  const PressableScale({
    super.key,
    required this.child,
    this.onPressed,
    this.onTap,
    this.scaleDownFactor = 0.965,
    this.duration = const Duration(milliseconds: 130),
    this.behavior = HitTestBehavior.opaque,
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
      reverseDuration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_effectiveAction != null) {
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
