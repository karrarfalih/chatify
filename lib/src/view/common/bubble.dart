import 'package:flutter/material.dart';

enum BubbleNip {
  no,
  left,
  right,
}

class Bubble extends StatelessWidget {
  Bubble({
    super.key,
    this.child,
    this.borderRadius,
    double? radius,
    bool? showNip,
    BubbleNip? nip,
    Color? color,
    this.flip = false,
  })  : color = color ?? Colors.white,
        bubbleClipper = _BubbleClipper(
          borderRadius: borderRadius ?? BorderRadius.zero,
          radius: radius ?? 8,
          showNip: showNip ?? true,
          nip: nip ?? BubbleNip.right,
        );

  final Widget? child;
  final Color color;
  final _BubbleClipper bubbleClipper;
  final BorderRadius? borderRadius;
  final bool flip;

  @override
  Widget build(BuildContext context) => Transform.flip(
        flipX: flip,
        child: CustomPaint(
          painter: _BubblePainter(
            clipper: bubbleClipper,
            color: color,
          ),
          child: Container(
            padding: bubbleClipper.edgeInsets,
            child: Transform.flip(
              flipX: flip,
              child: child,
            ),
          ),
        ),
      );
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.clipper,
    required Color color,
  }) : _fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  final CustomClipper<Path> clipper;

  final Paint _fillPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final clip = clipper.getClip(size);

    canvas.drawPath(clip, _fillPaint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => false;
}

class _BubbleClipper extends CustomClipper<Path> {
  _BubbleClipper({
    required this.borderRadius,
    required this.radius,
    required this.showNip,
    required this.nip,
  }) : super() {
    if (nip == BubbleNip.no) return;
    _leftOffset = nip == BubbleNip.left ? 10 : 0;
    _rightOffset = nip == BubbleNip.right ? 10 : 0;
  }

  final double radius;
  final BorderRadius borderRadius;
  final bool showNip;
  final BubbleNip nip;

  double _leftOffset = 0;
  double _rightOffset = 0;

  EdgeInsets get edgeInsets {
    return EdgeInsets.only(
      left: _leftOffset,
      right: _rightOffset,
    );
  }

  @override
  Path getClip(Size size) {
    var path = Path();

    path.addRRect(
      RRect.fromLTRBAndCorners(
        _leftOffset,
        0,
        size.width - _rightOffset,
        size.height,
        bottomLeft: nip == BubbleNip.left && showNip
            ? Radius.zero
            : borderRadius.bottomLeft,
        bottomRight: nip == BubbleNip.right && showNip
            ? Radius.zero
            : borderRadius.bottomRight,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
      ),
    );

    if (showNip) {
      switch (nip) {
        case BubbleNip.left:
          final path2 = Path()
            ..moveTo(2, size.height)
            ..lineTo(
              _leftOffset,
              size.height,
            )
            ..lineTo(
              _leftOffset,
              size.height - radius,
            );

          path2
            ..conicTo(
              12,
              size.height - 12,
              2,
              size.height - 2,
              1,
            )
            ..conicTo(
              0,
              size.height - 1,
              2,
              size.height,
              1,
            );

          path2.close();
          path = Path.combine(PathOperation.union, path, path2);
          break;

        case BubbleNip.right:
          final path2 = Path()
            ..moveTo(
              size.width - 2,
              size.height,
            )
            ..lineTo(
              size.width - _rightOffset,
              size.height,
            )
            ..lineTo(
              size.width - _rightOffset,
              size.height - radius,
            );

          path2
            ..conicTo(
              size.width - 12,
              size.height - 12,
              size.width - 2,
              size.height - 2,
              1,
            )
            ..conicTo(
              size.width,
              size.height - 1,
              size.width - 2,
              size.height,
              1,
            );

          path2.close();
          path = Path.combine(PathOperation.union, path, path2);
          break;

        default:
      }
    }

    return path;
  }

  @override
  bool shouldReclip(_BubbleClipper oldClipper) => false;
}
