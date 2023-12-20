import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final double scale;

  const LoadingWidget({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30 * scale,
      width: 60 * scale,
      child: Lottie.asset(
        'assets/lottie/typing.json',
        key: ValueKey('typing'),
        package: 'chatify',
        fit: BoxFit.fitHeight,
        delegates: LottieDelegates(
          values: [
            ValueDelegate.color(
              const ['**'],
              value: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
