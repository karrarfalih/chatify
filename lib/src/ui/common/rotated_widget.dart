library animated_rotating_widget;

import 'package:flutter/material.dart';

/// Rotates [child] widget in specified [duration] duration.
///
/// [child] and [duration] arguments must not be null.
class AnimatedRotatingWidget extends StatefulWidget {
  /// the widget to rotate
  final Widget child;

  /// duration to complete a single rotation
  final Duration duration;

  const AnimatedRotatingWidget({
    Key? key,
    required this.child,
    required this.duration,
  }) : super(key: key);

  @override
  State<AnimatedRotatingWidget> createState() => _AnimatedRotatingWidgetState();
}

class _AnimatedRotatingWidgetState extends State<AnimatedRotatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: widget.child,
    );
  }
}
