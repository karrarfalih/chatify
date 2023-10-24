import 'dart:math' as math;
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/utils.dart';
import 'package:flutter/material.dart';

List<double> adjustSampleCount(
  List<double> input,
  int requiredSampleCount,
  double max,
) {
  final samples = input;

  final int inputSampleCount = samples.length;

  if (requiredSampleCount == inputSampleCount) {
    return normalize(samples, max);
  }

  final List<double> result = [];
  final double step = (inputSampleCount - 1) / (requiredSampleCount - 1);

  for (int i = 0; i < requiredSampleCount; i++) {
    final double index = i * step;
    final int lowerIndex = index.floor();
    final int upperIndex = index.ceil();

    if (lowerIndex == upperIndex) {
      result.add(samples[lowerIndex]);
    } else {
      final double fraction = index - lowerIndex;
      result.add(
        samples[lowerIndex] +
            (samples[upperIndex] - samples[lowerIndex]) * fraction,
      );
    }
  }

  return normalize(result, max);
}

List<double> normalize(List<double> input, double upperValue) {
  final List<double> result = [];
  final min = input.reduce(math.min);
  final smaples = input.map((e) => e - min).toList();
  final max = smaples.reduce(math.max);
  for (int i = 0; i < input.length; i++) {
    result.add((smaples[i] / max) * upperValue);
  }
  return result;
}

class Noises extends StatelessWidget {
  const Noises({
    Key? key,
    required this.count,
    required this.isMe,
    required this.samples,
  }) : super(key: key);
  final int count;
  final bool isMe;
  final List<double> samples;

  @override
  Widget build(BuildContext context) {
    final List<double> samples = adjustSampleCount(this.samples, count, 14);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < samples.length; i++)
          _SingleNoise(samples.elementAt(i), isMe)
      ],
    );
  }
}

class _SingleNoise extends StatelessWidget {
  const _SingleNoise(this.height, this.isMe);
  final double height;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: .2.w()),
      width: .3.w(),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: isMe ? Colors.white : Chatify.theme.primaryColor,
      ),
    );
  }
}
