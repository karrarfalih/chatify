import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat/models/message.dart';
import 'package:kr_extensions/kr_extensions.dart';

class SendAtWidget extends StatelessWidget {
  const SendAtWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  final MessageModel message;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(message.isMine) Image.asset(message.isSeen ? 'lib/assets/icons/seen.png': 'lib/assets/icons/sent.png', package: 'chat', height: 14, color: !message.isMine && message.isText
                    ? Colors.black.withOpacity(message.isText || message.hasAudio ? 0.7:1)
                    : Colors.white.withOpacity(message.isText || message.hasAudio ? 0.7:1),),
          Text(
            (message.sendAt ?? DateTime.now()).format('h:mm a'),
            style: TextStyle(
                fontSize: 12,
                color: !message.isMine && message.isText
                    ? Colors.black.withOpacity(message.isText || message.hasAudio ? 0.7:1)
                    : Colors.white.withOpacity(message.isText || message.hasAudio ? 0.7:1),
                height: 1),
            textDirection: TextDirection.ltr,
          ),
          Text(
            message.isEdited ? ' ${'edited'.tr} ' : '',
            style: TextStyle(
                fontSize: 12,
                color: !message.isMine && message.isText
                    ? Colors.black.withOpacity(message.isText || message.hasAudio ? 0.7:1)
                    : Colors.white.withOpacity(message.isText || message.hasAudio ? 0.7:1),
                height: 1),
          ),
          // Text('${message.emoji ?? ''} ',
          //     style: const TextStyle(fontSize: 15, height: 1)),
        ],
      ),
    );
  }
}
