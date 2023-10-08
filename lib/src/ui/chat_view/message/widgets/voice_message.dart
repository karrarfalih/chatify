import 'package:chatify/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/send_at.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:chatify/src/packages/voice_player/voice_message_package.dart';
import 'package:flutter/material.dart';

class MyVoiceMessage extends StatelessWidget {
  const MyVoiceMessage({
    Key? key,
    required this.message,
    required this.controller,
  }) : super(key: key);

  final Message message;
  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return VoiceMessage(
      onSeek: () => controller.preventEmoji = true,
      onPlay: () {
        if (message.data != true) {
          Chatify.datasource.addMessage(message.copyWith(data: true));
        }
      },
      sendAt: SendAtWidget(message: message),
      duration: message.duration,
      height: 50,
      width: MediaQuery.of(context).size.width,
      audioSrc: message.attachment ?? '',
      played: message.data == true,
      me: message.sender == Chatify.currentUserId,
      meBgColor: ChatifyTheme.of(context).primaryColor,
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
        color: ChatifyTheme.of(context).primaryColor,
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
              DateTime.now().format(context, 'h:mm a'),
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  height: 1),
              textDirection: TextDirection.ltr,
            )),
        isLoading: true,
        duration: Duration.zero,
        height: 50,
        width: MediaQuery.of(context).size.width,
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
