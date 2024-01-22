import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/text_message.dart';
import 'package:chatify/src/ui/chats/chat_image.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:chatify/src/ui/common/confirm.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/bubble.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/image/image.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice_message.dart';
import 'package:chatify/src/ui/common/media_query.dart';
import 'package:chatify/src/ui/common/pull_down_button.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:iconsax/iconsax.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

final key = GlobalKey();

Map<String, bool> _animatedMessages = {};

class MessageCard extends StatelessWidget {
  final Message message;
  final bool linkedWithBottom;
  final bool linkedWithTop;
  final Chat chat;
  final List<ChatifyUser> users;
  final ChatController controller;
  final bool isSending;

  const MessageCard({
    Key? key,
    required this.message,
    required this.linkedWithBottom,
    required this.linkedWithTop,
    required this.chat,
    required this.controller,
    this.isSending = false,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool canAnimate = (message.sendAt
                ?.isAfter(DateTime.now().subtract(Durations.extralong4)) ??
            true) &&
        _animatedMessages[message.id] != true;
    _animatedMessages[message.id] = true;
    final child = MessageCardWidget(
      message: message,
      linkedWithBottom: linkedWithBottom,
      linkedWithTop: linkedWithTop,
      chat: chat,
      controller: controller,
      users: users,
    );
    if (canAnimate) {
      return Animate(
        effects: [
          FadeEffect(),
          ScaleEffect(
            curve: Curves.easeOutQuart,
            duration: Duration(milliseconds: 700),
          ),
          SlideEffect(
            begin: Offset(0.5, 0.5),
            curve: Curves.easeOutQuart,
            duration: Duration(milliseconds: 700),
          ),
        ],
        child: child,
      );
    }
    return child;
  }
}

class MessageCardWidget extends StatefulWidget {
  final Message message;
  final bool linkedWithBottom;
  final bool linkedWithTop;
  final Chat chat;
  final List<ChatifyUser> users;
  final ChatController controller;
  final bool isSending;

  const MessageCardWidget({
    Key? key,
    required this.message,
    required this.linkedWithBottom,
    required this.linkedWithTop,
    required this.chat,
    required this.controller,
    this.isSending = false,
    required this.users,
  }) : super(key: key);

  @override
  State<MessageCardWidget> createState() => _MessageCardWidgetState();
}

class _MessageCardWidgetState extends State<MessageCardWidget> {
  final messagePos = 0.0.obs;
  bool hasVibrated = false;
  late bool isSelected;

  @override
  void dispose() {
    messagePos.dispose();
    super.dispose();
  }

  toggleSelect() {
    if (isSelected) {
      widget.controller.selecetdMessages
        ..value.remove(widget.message.id)
        ..refresh();
    } else {
      widget.controller.selecetdMessages
        ..value[widget.message.id] = widget.message
        ..refresh();
    }
  }

  startSwipe() {
    widget.controller.preventChatScroll.value = true;
    widget.controller.initialSelecetdMessages =
        Map.from(widget.controller.selecetdMessages.value);
    toggleSelect();
    widget.controller.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Chatify.theme;
    final isMine = widget.message.isMine;
    widget.message.type == MessageType.unSupported;
    final textColor = isMine ? Colors.white : theme.chatForegroundColor;
    final bkColor = isMine
        ? theme.primaryColor
        : theme.chatBrightness == Brightness.light
            ? Colors.white
            : Colors.black;
    final width = mediaQuery(context).size.width - 100;
    final myEmoji = widget.message.emojis.cast<MessageEmoji?>().firstWhere(
          (e) =>
              e?.uid == Chatify.currentUserId ||
              (Chatify.config.showSupportMessages && e?.uid == 'support'),
          orElse: () => null,
        );
    final sender = widget.users.firstWhere(
      (e) => e.id == widget.message.sender,
      orElse: () => ChatifyUser(
        id: widget.message.sender,
        name: 'Unknown',
        profileImage: null,
      ),
    );
    return ValueListenableBuilder<Map<String, Message>>(
      valueListenable: widget.controller.selecetdMessages,
      builder: (context, selecetdMessages, child) {
        isSelected = selecetdMessages.containsKey(widget.message.id);
        return GestureDetector(
          onTap: () {
            if (widget.controller.selecetdMessages.value.isNotEmpty) {
              toggleSelect();
            }
          },
          onLongPress: startSwipe,
          onLongPressEnd: (details) =>
              widget.controller.preventChatScroll.value = false,
          child: Container(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            child: Row(
              children: [
                PopScope(
                  canPop: selecetdMessages.isEmpty,
                  onPopInvoked: (didPop) {
                    widget.controller.selecetdMessages.value = {};
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: selecetdMessages.isNotEmpty ? 40 : 0,
                    height: 20,
                    child: Center(
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: SizedBox(
                              width: 50,
                              child: Center(
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            ),
          ),
        );
      },
      child: Expanded(
        child: Directionality(
          textDirection: isMine ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            padding: EdgeInsetsDirectional.only(
              top: !widget.linkedWithTop ? 10 : 0,
              bottom: 2,
              end: widget.message.type.isTextOrUnsupported ||
                      widget.message.type.isVoice
                  ? 4
                  : 13,
              start: widget.message.type.isTextOrUnsupported ||
                      widget.message.type.isVoice
                  ? 4
                  : 13,
            ),
            child: PullDownButton(
              routeTheme: PullDownMenuRouteTheme(
                width: 140,
                topWidgetWidth: 250,
                backgroundColor: Colors.grey.shade200,
              ),
              topWidget: widget.isSending
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 3, top: 3),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ['❤', '😍', '😂', '😢', '👍'].map((e) {
                            return AnimatedScale(
                              duration: const Duration(milliseconds: 150),
                              scale: myEmoji?.emoji == e ? 1.3 : 1,
                              child: CircularButton(
                                highlightColor: Colors.transparent,
                                icon: Text(
                                  e,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    height: 1,
                                  ),
                                ),
                                onPressed: () async {
                                  if (myEmoji?.emoji == e) {
                                    Chatify.datasource
                                        .removeMessageEmojis(widget.message.id);
                                  } else {
                                    if (myEmoji != null)
                                      Chatify.datasource
                                          .removeMessageEmojis(
                                            widget.message.id,
                                          )
                                          .then(
                                            (value) => Chatify.datasource
                                                .addMessageEmojis(
                                              widget.message.id,
                                              e,
                                            ),
                                          );
                                    else {
                                      Chatify.datasource.addMessageEmojis(
                                        widget.message.id,
                                        e,
                                      );
                                    }
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
              itemBuilder: (context) => [
                if (widget.message is TextMessage &&
                    isMine &&
                    !widget.isSending)
                  PullDownMenuItem(
                    title: localization(context).edit,
                    icon: Iconsax.edit,
                    itemTheme: PullDownMenuItemTheme(
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      widget.controller.edit(widget.message, context);
                    },
                  ),
                if (widget.message is TextMessage) ...[
                  const PullDownMenuDivider(),
                  PullDownMenuItem(
                    title: localization(context).copy,
                    icon: Iconsax.copy,
                    itemTheme: PullDownMenuItemTheme(
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      widget.controller.copy(widget.message, context);
                    },
                  ),
                ],
                if (!widget.isSending) ...[
                  const PullDownMenuDivider(),
                  PullDownMenuItem(
                    title: localization(context).reply,
                    icon: Iconsax.undo,
                    itemTheme: PullDownMenuItemTheme(
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      widget.controller.reply(widget.message);
                    },
                  ),
                ],
                if (!widget.isSending) ...[
                  const PullDownMenuDivider(),
                  PullDownMenuItem(
                    title: localization(context).delete,
                    icon: Iconsax.trash,
                    iconColor: Colors.red,
                    itemTheme: PullDownMenuItemTheme(
                      textStyle: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    onTap: () async {
                      final deleteForAll = await showConfirmDialog(
                        context: context,
                        message: localization(context).confirmDeleteMessage,
                        textOK: localization(context).delete,
                        textCancel: localization(context).cancel,
                        showDeleteForAll: true,
                        isKeyboardShown:
                            widget.controller.keyboardController.isKeybaordOpen,
                      );
                      if (deleteForAll == true) {
                        Chatify.datasource
                            .deleteMessageForAll(widget.message.id);
                      } else if (deleteForAll == false) {
                        Chatify.datasource
                            .deleteMessageForMe(widget.message.id);
                      }
                    },
                  ),
                ] else if (widget.message is TextMessage) ...[
                  const PullDownMenuDivider(),
                  PullDownMenuItem(
                    title: localization(context).cancel,
                    icon: Iconsax.trash,
                    iconColor: Colors.red,
                    itemTheme: PullDownMenuItemTheme(
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    onTap: () async {
                      Chatify.datasource.deleteMessageForAll(widget.message.id);
                      widget.controller.pending.remove(widget.message);
                    },
                  ),
                ],
              ],
              position: PullDownMenuPosition.automatic,
              applyOpacity: false,
              buttonBuilder: (context, showMenu) => Bounce(
                duration: Duration(milliseconds: 110),
                onPressed: () {
                  if (widget.controller.selecetdMessages.value.isNotEmpty) {
                    toggleSelect();
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  showMenu();
                },
                child: SwipeableTile.swipeToTrigger(
                  behavior: HitTestBehavior.translucent,
                  isElevated: false,
                  color: Colors.transparent,
                  swipeThreshold: 0.2,
                  direction: isMine
                      ? SwipeDirection.startToEnd
                      : SwipeDirection.endToStart,
                  onSwiped: (direction) {
                    widget.controller.reply(widget.message);
                  },
                  backgroundBuilder: (context, direction, progress) {
                    bool triggered = false;
                    return AnimatedBuilder(
                      animation: progress,
                      builder: (_, __) {
                        if (progress.value > 0.9999 && !triggered) {
                          widget.controller.vibrate();
                          triggered = true;
                        }
                        if (progress.value < 0.2) {
                          return SizedBox();
                        }
                        return Container(
                          alignment: isMine
                              ? AlignmentDirectional.centerStart
                              : AlignmentDirectional.centerEnd,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 6.0,
                              end: 6,
                            ),
                            child: Animate(
                              effects: [
                                FadeEffect(),
                                ScaleEffect(),
                              ],
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Transform.flip(
                                      flipX: true,
                                      child: Icon(
                                        Icons.reply,
                                        color: Colors.black.withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  if (progress.value < 1 && !triggered)
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        value: progress.value,
                                        strokeWidth: 2,
                                        color: theme.chatForegroundColor
                                            .withOpacity(0.3),
                                      ),
                                    )
                                  else
                                    Animate(
                                      effects: [
                                        ScaleEffect(
                                          curve: Curves.easeOutBack,
                                          duration: Duration(milliseconds: 400),
                                        ),
                                      ],
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: theme.chatForegroundColor
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  // confirmSwipe: (direction) async => false,
                  key: ValueKey('dismissible-${widget.message.id}'),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: ValueListenableBuilder<double>(
                          valueListenable: messagePos,
                          builder: (context, value, child) => Row(
                            children: [
                              child!,
                              if (!isMine) ...[
                                Spacer(),
                                if (value != 0)
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 100),
                                    width: value.withRange(0, 100),
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Icon(Icons.reply),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.users.length > 2 && !isMine)
                                widget.linkedWithBottom
                                    ? SizedBox(
                                        width: 30,
                                      )
                                    : UserProfileImage(
                                        url: sender.profileImage,
                                        firstLetter: sender.name[0],
                                        size: 30,
                                      ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: width,
                                  minWidth: 80,
                                ),
                                child: widget.message is VoiceMessage
                                    ? MyBubble(
                                        bkColor: bkColor,
                                        linkedWithBottom:
                                            widget.linkedWithBottom,
                                        linkedWithTop: widget.linkedWithTop,
                                        message: widget.message,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: 100,
                                          ),
                                          child: MyVoiceMessage(
                                            message:
                                                widget.message as VoiceMessage,
                                            controller: widget.controller,
                                            user: sender,
                                          ),
                                        ),
                                      )
                                    : widget.message is ImageMessage
                                        ? ImageCard(
                                            message:
                                                widget.message as ImageMessage,
                                            chatController: widget.controller,
                                            user: sender,
                                            bkColor: bkColor,
                                            textColor: textColor,
                                          )
                                        : TextMessageCard(
                                            widget: widget,
                                            bkColor: bkColor,
                                            textColor: textColor,
                                            controller: widget.controller,
                                            isMine: isMine,
                                            isSending: widget.isSending,
                                            isSelected: isSelected,
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
