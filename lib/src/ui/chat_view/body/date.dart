import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';

class ChatDateWidget extends StatefulWidget {
  const ChatDateWidget({
    Key? key,
    required this.date,
  }) : super(key: key);

  final DateTime date;

  @override
  State<ChatDateWidget> createState() => _ChatDateWidgetState();
}

class _ChatDateWidgetState extends State<ChatDateWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            widget.date.format(context, 'd MMMM'),
            style:
                const TextStyle(fontSize: 12, color: Colors.white, height: 1),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
