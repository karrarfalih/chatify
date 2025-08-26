import '../../../../../../chatify.dart';
import 'package:flutter/material.dart';

class MessageConstraints extends StatelessWidget {
  const MessageConstraints(
      {super.key, required this.child, required this.message});

  final Widget child;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: (() {
          final provider =
              MessageProviderRegistry.instance.getByMessage(message.content);
          return ((provider?.isMedia ?? false) ? 300.0 : 1200.0);
        })(),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 8,
            child: child,
          ),
          const Expanded(
            flex: 2,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}
