import 'package:chatify/chatify.dart';
import 'package:chatify/src/assets/image.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/send_at.dart';
import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    Key? key,
    required this.message,
    required this.width,
  }) : super(key: key);

  final Message message;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        ConstrainedBox(
            constraints: BoxConstraints(maxHeight: width, minHeight: 200),
            child: Hero(
              tag: message.attachment ?? '',
              child: CustomImage(
                url: message.attachment,
                fit: BoxFit.cover,
                radius: 15,
                width: width,
              ),
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
