import '../../../../common/bubble.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.child,
    required this.isFirst,
    required this.isLast,
    required this.isMine,
    required this.isError,
  });

  final Widget child;
  final bool isFirst;
  final bool isLast;
  final bool isMine;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Bubble(
        radius: 20,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: Radius.circular(isFirst ? 20 : 10),
          bottomLeft: const Radius.circular(20),
          bottomRight: Radius.circular(isLast ? 20 : 10),
        ),
        color: isError && isMine
            ? Theme.of(context)
                .colorScheme
                .errorContainer
                .withValues(alpha: 0.5)
            : isMine
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.surfaceContainerLowest,
        flip: !isMine,
        showNip: isLast,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 300),
            child: child,
          ),
        ),
      ),
    );
  }
}
