import 'dart:ui';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/body/action_header.dart';
import 'package:chatify/src/ui/chat_view/body/bottom_space.dart';
import 'package:chatify/src/ui/chat_view/body/emojis_keyboard.dart';
import 'package:chatify/src/ui/chat_view/body/input_box.dart';
import 'package:chatify/src/ui/chat_view/body/messages.dart';
import 'package:chatify/src/ui/chat_view/body/recording/thumb.dart';
import 'package:chatify/src/ui/chat_view/body/recording/lock.dart';
import 'package:chatify/src/ui/chat_view/body/voice_palyer.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/body/app_bar.dart';
import 'package:chatify/src/ui/chat_view/controllers/pending_messages.dart';
import 'package:chatify/src/ui/chats/connectivity.dart';
import 'package:chatify/src/ui/common/keyboard_size.dart';
import 'package:chatify/src/utils/context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
    required this.chat,
    required this.user,
    this.pendingMessagesHandler,
    this.connectivity,
  }) : super(key: key);
  final Chat chat;
  final ChatifyUser user;
  final PendingMessagesHandler? pendingMessagesHandler;
  final ChatifyConnectivity? connectivity;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatController controller;
  late final ChatifyConnectivity connectivity;

  @override
  void initState() {
    controller = ChatController(widget.chat, widget.pendingMessagesHandler);
    connectivity = widget.connectivity ?? ChatifyConnectivity();
    super.initState();
  }

  @override
  dispose() {
    controller.dispose();
    if (widget.connectivity == null) connectivity.dispose();
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
                        color: Chatify.theme.primaryColor.withOpacity(0.05),
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
                                  Chatify.theme.primaryColor.withOpacity(0.1),
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
                      ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Chatify.theme.isChatDark
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.4),
                              border: Border(
                                top: BorderSide(
                                  color: (Chatify.theme.isChatDark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(0.07),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                ChatInputBox(
                                  controller: controller,
                                  chat: widget.chat,
                                ),
                                ChatBottomSpace(controller: controller),
                                EmojisKeyboard(controller: controller)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatAppBar(
                        user: widget.user,
                        chatController: controller,
                        connectivity: connectivity,
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
