import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/body/action_header.dart';
import 'package:chatify/src/ui/chat_view/body/emojis_keyboard.dart';
import 'package:chatify/src/ui/chat_view/body/input_box.dart';
import 'package:chatify/src/ui/chat_view/body/messages.dart';
import 'package:chatify/src/ui/chat_view/body/recording/thumb.dart';
import 'package:chatify/src/ui/chat_view/body/recording/lock.dart';
import 'package:chatify/src/ui/chat_view/body/voice_palyer.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/body/app_bar.dart';
import 'package:chatify/src/ui/common/keyboard_size.dart';
import 'package:chatify/src/utils/context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
    required this.chat,
    required this.user,
  }) : super(key: key);
  final Chat chat;
  final ChatifyUser user;
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatController controller;

  @override
  void initState() {
    controller = ChatController(widget.chat);
    super.initState();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Chatify.theme.isChatDark
            ? SystemUiOverlayStyle.light.copyWith(
                systemNavigationBarDividerColor: Colors.black,
                systemNavigationBarColor: Colors.black,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                systemNavigationBarDividerColor: Colors.white,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        child: KeyboardSizeProvider(
          child: Scaffold(
            key: ContextProvider.chatKey,
            resizeToAvoidBottomInset: false,
            body: Container(
              decoration: Chatify.theme.backgroundImage == null
                  ? null
                  : BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          Chatify.theme.backgroundImage!,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  if (Chatify.theme.backgroundImage == null) ...[
                    Positioned.fill(
                      child: ColoredBox(
                        color: Chatify.theme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Chatify.theme.primaryColor.withOpacity(0.2),
                              blurRadius: MediaQuery.of(context).size.width / 2,
                              spreadRadius:
                                  MediaQuery.of(context).size.width / 2,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                  Column(
                    children: [
                      Expanded(
                        child: ChatMessages(
                          chat: widget.chat,
                          user: widget.user,
                          controller: controller,
                        ),
                      ),
                      MessageActionHeader(
                        controller: controller,
                        user: widget.user,
                      ),
                      ChatInputBox(
                        controller: controller,
                        chat: widget.chat,
                      ),
                      EmojisKeyboard(controller: controller)
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatAppBar(
                        user: widget.user,
                        chatController: controller,
                      ),
                      CurrentVoicePlayer(),
                    ],
                  ),
                  RecordThumb(controller: controller),
                  RecordingLock(controller: controller)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
