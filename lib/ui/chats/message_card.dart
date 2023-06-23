import 'package:chat/models/theme.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  const MessageCard(
      {Key? key,
      required this.isOwner,
      required this.message,
      required this.time})
      : super(key: key);
  final bool isOwner;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrain) {
      return Container(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 8),
        child: Align(
          alignment: (isOwner ? Alignment.topRight : Alignment.topLeft),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: isOwner
                    ? const Radius.circular(0)
                    : const Radius.circular(20),
                topLeft: isOwner
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
              color: (isOwner ? currentTheme.primary : Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment:
                  isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: currentTheme.titleStyle.copyWith(
                      color: isOwner
                          ? Colors.white
                          : Colors.black),
                ),
                Text(
                  time,
                  style: TextStyle(
                      color: isOwner
                          ? Colors.white
                          : Colors.black),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
