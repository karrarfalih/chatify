import 'package:flutter/material.dart';

part 'bubble_painter.dart';

enum BubbleNip {
  no,
  left,
  right,
}

class Bubble extends StatelessWidget {
  Bubble({
    Key? key,
    this.child,
    this.borderRadius,
    double? radius,
    bool? showNip,
    BubbleNip? nip,
    Color? color,
  })  : color = color ?? Colors.white,
        bubbleClipper = _BubbleClipper(
          borderRadius: borderRadius ?? BorderRadius.zero,
          radius: radius ?? 8,
          showNip: showNip ?? true,
          nip: nip ?? BubbleNip.right,
        ),
        super(key: key);

  final Widget? child;
  final Color color;
  final _BubbleClipper bubbleClipper;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _BubblePainter(
          clipper: bubbleClipper,
          color: color,
        ),
        child: Container(
          padding: bubbleClipper.edgeInsets,
          child: child,
        ),
      );
}
