import 'dart:async';

import 'package:flutter/material.dart';

class EntranceMotion extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const EntranceMotion({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 20),
    this.duration = const Duration(milliseconds: 210),
  });

  @override
  State<EntranceMotion> createState() => _EntranceMotionState();
}

class _EntranceMotionState extends State<EntranceMotion> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final visible = reduceMotion || _visible;
    final duration = reduceMotion ? Duration.zero : widget.duration;

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.035),
        duration: duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
