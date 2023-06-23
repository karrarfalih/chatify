import 'package:chatify/models/theme.dart';
import 'package:chatify/voice_player/voice_message_package.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kr_extensions/kr_extensions.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/ui/chat_view/message_card.dart';
import 'package:chatify/ui/chat_view/send_at.dart';

class MyVoiceMessage extends StatelessWidget {
  const MyVoiceMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return VoiceMessage(
      onSeek: () => preventEmoji = true,
      onPlay: () => message
        ..data = true
        ..save(),
      sendAt: SendAtWidget(message: message),
      duration: message.duration,
      height: 50,
      width: Get.width,
      audioSrc: message.messageAttachment ?? '',
      played: message.data == true,
      me: message.isMine,
      meBgColor: currentTheme.primary,
      contactPlayIconColor: Colors.white,
      contactBgColor: Theme.of(context).scaffoldBackgroundColor,
      contactFgColor: Theme.of(context).primaryColor,
    );
  }
}

class MyVoiceMessageBloc extends StatelessWidget {
  const MyVoiceMessageBloc({
    Key? key,
    required this.linkedWithTop,
    required this.linkedWithBottom,
  }) : super(key: key);

  final bool linkedWithTop;
  final bool linkedWithBottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: currentTheme.primary,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(linkedWithTop ? 0 : 12),
          bottomStart: Radius.circular(linkedWithBottom ? 0 : 12),
          topEnd: const Radius.circular(12),
          bottomEnd: const Radius.circular(12),
        ),
      ),
      child: VoiceMessage(
        sendAt: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              DateTime.now().format('h:mm a'),
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  height: 1),
              textDirection: TextDirection.ltr,
            )),
        isLoading: true,
        duration: Duration.zero,
        height: 50,
        width: Get.width,
        audioSrc: '',
        played: true,
        me: true,
        meBgColor: Theme.of(context).primaryColor,
        contactBgColor: Theme.of(context).scaffoldBackgroundColor,
        contactFgColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
