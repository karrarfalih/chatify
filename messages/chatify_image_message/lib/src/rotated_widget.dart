import 'package:flutter/material.dart';

class AnimatedRotatingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedRotatingWidget({
    super.key,
    required this.child,
    required this.duration,
  });

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
