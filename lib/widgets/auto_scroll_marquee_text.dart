import 'dart:async';
import 'package:flutter/material.dart';

/// Reusable horizontal auto-scrolling marquee text widget.
/// When the text width exceeds the available container width, it smoothly scrolls
/// forward to the end, pauses, scrolls back to start, and loops every few seconds.
/// If the text fits comfortably within bounds, it remains static.
class AutoScrollMarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration pauseDuration;
  final Duration scrollDuration;

  const AutoScrollMarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.pauseDuration = const Duration(milliseconds: 3500),
    this.scrollDuration = const Duration(milliseconds: 4000),
  });

  @override
  State<AutoScrollMarqueeText> createState() => _AutoScrollMarqueeTextState();
}

class _AutoScrollMarqueeTextState extends State<AutoScrollMarqueeText> {
  late final ScrollController _scrollController;
  Timer? _timer;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLoop();
    });
  }

  void _startLoop() {
    if (!mounted) return;
    _scheduleNext();
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(widget.pauseDuration, () async {
      if (!mounted || !_scrollController.hasClients) return;

      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0.5) {
        // Fits comfortably without scroll needed, retry in case of relayout
        _scheduleNext();
        return;
      }

      final target = _isForward ? maxExtent : 0.0;
      try {
        await _scrollController.animateTo(
          target,
          duration: widget.scrollDuration,
          curve: Curves.easeInOutCubic,
        );
        _isForward = !_isForward;
      } catch (_) {
        // Ignored if interrupted or unmounted
      }

      if (mounted) {
        _scheduleNext();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AutoScrollMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
      _isForward = true;
      _scheduleNext();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
