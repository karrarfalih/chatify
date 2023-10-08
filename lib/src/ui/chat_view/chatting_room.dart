import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/body/action_header.dart';
import 'package:chatify/src/ui/chat_view/body/input_box.dart';
import 'package:chatify/src/ui/chat_view/body/messages.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:chatify/src/ui/chat_view/body/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

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
  final controller = ChatController();

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ChatifyTheme.of(context).isChatDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: KeyboardSizeProvider(
        smallSize: 500.0,
        child: Consumer<ScreenHeight>(
          builder: (context, _res, child) {
            controller.isKeyboardOpen = _res.isOpen;
            return child!;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Container(
              decoration: ChatifyTheme.of(context).backgroundImage == null
                  ? null
                  : BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          ChatifyTheme.of(context).backgroundImage!,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
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
                      ChatInputBox(controller: controller, chat: widget.chat),
                    ],
                  ),
                  ChatAppBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
