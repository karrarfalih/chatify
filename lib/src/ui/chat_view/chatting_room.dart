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
import 'package:chatify/src/ui/chat_view/input_status.dart';
import 'package:chatify/src/ui/chats/connectivity.dart';
import 'package:chatify/src/ui/common/keyboard_size.dart';
import 'package:chatify/src/ui/common/media_query.dart';
import 'package:chatify/src/utils/context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'message/message_card.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
    required this.chat,
    required this.users,
    this.pendingMessagesHandler,
    this.connectivity,
  }) : super(key: key);
  final Chat chat;
  final List<ChatifyUser> users;
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
    controller = ChatController(
      widget.chat,
      widget.pendingMessagesHandler,
      widget.users,
    );
    connectivity = widget.connectivity ?? ChatifyConnectivity();
    Chatify.config.onOpenChat?.call(widget.chat);
    super.initState();
  }

  @override
  dispose() {
    controller.dispose();
    if (widget.connectivity == null) connectivity.dispose();
    super.dispose();
  }

  Map<String, Message> get initialSelecetdMessages =>
      controller.initialSelecetdMessages;

  set initialSelecetdMessages(Map<String, Message> value) =>
      controller.initialSelecetdMessages = value;

  Map<int, Message> addedMessages = {};
  Offset offset = Offset.zero;
  bool isRemove = false;

  _detectTapedItem(PointerEvent event) {
    if (!controller.preventChatScroll.value) return;
    if (controller.voiceController.isRecording.value) return;
    final RenderBox box =
        key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is SelectedMessage) {
          final initialList = Map.from(controller.selecetdMessages.value);
          final selectedMessages = controller.selecetdMessages.value;
          bool isScrollUp = offset.dy > local.dy;
          addedMessages.putIfAbsent(target.index, () => target.message);
          addedMessages.removeWhere(
            (key, value) =>
                isScrollUp ? key > target.index : key < target.index,
          );
          if (isRemove) {
            selectedMessages.addAll(initialSelecetdMessages);
            selectedMessages.removeWhere(
              (key, value) => addedMessages.containsValue(value),
            );
          } else {
            selectedMessages.clear();
            selectedMessages.addAll(
              addedMessages.map((key, value) => MapEntry(value.id, value)),
            );
            selectedMessages.addAll(initialSelecetdMessages);
          }
          if (initialList.length != selectedMessages.length) {
            controller.selecetdMessages.refresh();
          }
        }
      }
    }
  }

  _detectStart(PointerEvent event) {
    addedMessages.clear();
    final RenderBox box =
        key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
    offset = box.globalToLocal(event.position);
    final result = BoxHitTestResult();
    if (box.hitTest(result, position: offset)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is SelectedMessage) {
          isRemove = initialSelecetdMessages.containsKey(target.message.id);
        }
      }
    }
  }

  DateTime lastDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final navBarColor = Chatify.theme.isChatDark ? Colors.black : Colors.white;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // value: Chatify.theme.isChatDark
        //     ? SystemUiOverlayStyle.light.copyWith(
        //         systemNavigationBarDividerColor: Colors.black,
        //         systemNavigationBarColor: Colors.black,
        //         systemNavigationBarIconBrightness: Brightness.light,
        //       )
        //     : SystemUiOverlayStyle.dark.copyWith(
        //         systemNavigationBarDividerColor: Colors.white,
        //         systemNavigationBarColor: Colors.white,
        //         systemNavigationBarIconBrightness: Brightness.dark,
        //       ),
        value: FlexColorScheme.themedSystemNavigationBar(
          context,
          opacity: androidVersion > 29 ? 0 : 1,
          useDivider: false,
          systemNavigationBarColor: navBarColor,
          systemNavigationBarDividerColor: navBarColor,
        ),
        child: KeyboardSizeProvider(
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              elevation: 0,
              backgroundColor: Colors.transparent,
              systemOverlayStyle: Chatify.theme.isChatDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
            ),
            key: ContextProvider.chatKey,
            resizeToAvoidBottomInset: false,
            extendBody: true,
            extendBodyBehindAppBar: true,
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
                        width: mediaQuery(context).size.width / 2,
                        height: mediaQuery(context).size.width / 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Chatify.theme.primaryColor.withOpacity(0.1),
                              blurRadius: mediaQuery(context).size.width / 2,
                              spreadRadius: mediaQuery(context).size.width / 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Listener(
                    onPointerMove: _detectTapedItem,
                    onPointerDown: _detectStart,
                    child: ValueListenableBuilder<bool>(
                      key: key,
                      valueListenable: controller.preventChatScroll,
                      builder: (context, isPrevented, child) {
                        return CustomScrollView(
                          reverse: true,
                          physics: isPrevented
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          slivers: [
                            SliverStickyHeader(
                              sticky: true,
                              header: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  UsersInputStatus(
                                    chatId: widget.chat.id,
                                    users: widget.users,
                                  ),
                                  MessageActionHeader(
                                    controller: controller,
                                    users: widget.users,
                                  ),
                                  ClipRRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 30,
                                        sigmaY: 30,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Chatify.theme.isChatDark
                                              ? Colors.black.withOpacity(0.5)
                                              : Colors.white.withOpacity(0.5),
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
                                            ChatBottomSpace(
                                              controller: controller,
                                            ),
                                            EmojisKeyboard(
                                              controller: controller,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              sliver: ChatMessages(
                                chat: widget.chat,
                                users: widget.users,
                                controller: controller,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatAppBar(
                        users: widget.users,
                        chatController: controller,
                        connectivity: connectivity,
                      ),
                      CurrentVoicePlayer(),
                    ],
                  ),
                  RecordThumb(controller: controller),
                  RecordingLock(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
