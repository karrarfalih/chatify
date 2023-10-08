import 'package:chatify/src/theme/theme_widget.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.size = 22,
    this.lineWidth = 2,
    this.color,
  });

  final Color? color;
  final double size;
  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        backgroundColor: Colors.transparent,
        strokeWidth: lineWidth,
        color: color ?? ChatifyTheme.of(context).primaryColor,
      ),
    );
  }
}
