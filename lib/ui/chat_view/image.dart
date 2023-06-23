import 'package:chatify/assets/image.dart';
import 'package:flutter/material.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/ui/chat_view/send_at.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    Key? key,
    required this.message,
    required this.width,
  }) : super(key: key);

  final MessageModel message;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        ConstrainedBox(
            constraints: BoxConstraints(maxHeight: width, minHeight: 200),
            child: Hero(
              tag: message.messageAttachment ?? '',
              child: MyImage(
                  url: message.messageAttachment,
                  fit: BoxFit.cover,
                  isCircle: false,
                  radius: 15,
                  width: width),
            )),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50)),
            child: SendAtWidget(message: message),
          ),
        )
      ],
    );
  }
}
