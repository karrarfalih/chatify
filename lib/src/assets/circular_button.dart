library circular_button;

import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final double size;
  final EdgeInsets padding;
  final String? tooltip;
  final Color? highlightColor;
  final FocusNode? focusNode;
  final Color? hoverColor;
  const CircularButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 24.0,
    this.padding = const EdgeInsets.all(8),
    this.tooltip,
    this.hoverColor,
    this.focusNode,
    this.highlightColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        highlightColor: highlightColor,
        focusNode: focusNode,
        mouseCursor: MouseCursor.defer,
        hoverColor: hoverColor ?? Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
        customBorder: const CircleBorder(),
        onTap: onPressed,
        focusColor: Colors.transparent,
        child: Padding(
          padding: padding,
          child: icon,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip ?? '',
        child: button,
      );
    }

    return button;
  }
}
