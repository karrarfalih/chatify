import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.icon,
    this.svg,
    this.onPressed,
  });

  final IconData? icon;
  final String? svg;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: 44,
      width: 44,
      child: TextButton(
        onPressed: () {
          onPressed?.call();
        },
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(foregroundColor),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.25)),
          textStyle: WidgetStateProperty.all(
              Theme.of(context).textTheme.labelLarge),
          alignment: Alignment.center,
          shape: WidgetStateProperty.all(
            const CircleBorder(),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, size: 20, color: foregroundColor),
                if (svg != null)
                  SvgPicture.asset(
                    'assets/$svg.svg',
                    package: 'chatify',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      foregroundColor,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
          
          ],
        ),
      ),
    );
  }
}
