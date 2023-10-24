import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/voice_message.dart';
import 'package:flutter/material.dart';

class MyVoiceMessage extends StatelessWidget {
  const MyVoiceMessage({
    Key? key,
    required this.message,
    required this.controller,
    required this.user,
  }) : super(key: key);

  final VoiceMessage message;
  final ChatController controller;
  final ChatifyUser user;

  @override
  Widget build(BuildContext context) {
    return VoiceMessageWidget(
      key: ValueKey(message.id),
      onSeek: () => controller.preventEmoji = true,
      user: message.isMine ? 'Me' : user.name,
      meBgColor: Chatify.theme.primaryColor,
      contactPlayIconColor: Colors.white,
      contactBgColor: Chatify.theme.chatBrightness == Brightness.light
          ? Colors.white
          : Colors.black,
      contactFgColor: Chatify.theme.primaryColor,
      message: message,
      chatController: controller,
      width: MediaQuery.of(context).size.width,
    );
  }
}

class MyVoiceMessageBloc extends StatelessWidget {
  const MyVoiceMessageBloc({
    Key? key,
    required this.linkedWithTop,
    required this.linkedWithBottom,
    required this.message,
    required this.controller,
  }) : super(key: key);

  final bool linkedWithTop;
  final bool linkedWithBottom;
  final VoiceMessage message;
  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Chatify.theme.primaryColor,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(linkedWithTop ? 0 : 12),
          bottomStart: Radius.circular(linkedWithBottom ? 0 : 12),
          topEnd: const Radius.circular(12),
          bottomEnd: const Radius.circular(12),
        ),
      ),
      child: VoiceMessageWidget(
        meBgColor: theme.primaryColor,
        contactBgColor: theme.scaffoldBackgroundColor,
        contactFgColor: theme.primaryColor,
        user: '',
        message: message,
        chatController: controller,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
