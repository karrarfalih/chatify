import 'dart:math' as math;
import 'package:chatify/src/ui/chat_view/message/widgets/voice/utils.dart';
import 'package:flutter/material.dart';

/// document will be added
class Noises extends StatelessWidget {
  const Noises({Key? key, required this.count, required this.isMe})
      : super(key: key);
  final int count;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < count; i++)
          isMe ? const _SingleWhiteNoise() : const _SingleGreyNoise()
      ],
    );
  }
}

class _SingleWhiteNoise extends StatelessWidget {
  const _SingleWhiteNoise();

  @override
  Widget build(BuildContext context) {
    final double height = 5.74.w() * math.Random().nextDouble() + .26.w();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: .2.w()),
      width: .4.w(),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: Colors.white,
      ),
    );
  }
}

class _SingleGreyNoise extends StatelessWidget {
  const _SingleGreyNoise();

  @override
  Widget build(BuildContext context) {
    final double height = 5.74.w() * math.Random().nextDouble() + .26.w();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: .2.w()),
      width: .4.w(),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: Colors.grey,
      ),
    );
  }
}
