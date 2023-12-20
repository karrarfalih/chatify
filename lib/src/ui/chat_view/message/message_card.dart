import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/text_message.dart';
import 'package:chatify/src/ui/chats/chat_image.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:chatify/src/ui/common/confirm.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/bubble.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/image/image.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice_message.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';

final key = GlobalKey();

class MessageCard extends StatefulWidget {
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
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  final messagePos = 0.0.obs;
  double _startPos = 0;
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
    widget.controller.isSelecting.value = true;
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
    final width = MediaQuery.of(context).size.width - 100;
    final myEmoji = widget.message.emojis
        .cast<MessageEmoji?>()
        .firstWhere((e) => e?.uid == Chatify.currentUserId, orElse: () => null);
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
      builder: (context, value, child) {
        isSelected = value.containsKey(widget.message.id);
        return GestureDetector(
          onTap: () {
            if (widget.controller.selecetdMessages.value.isNotEmpty) {
              toggleSelect();
            }
          },
          onLongPress: startSwipe,
          onLongPressEnd: (details) =>
              widget.controller.isSelecting.value = false,
          child: Container(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            child: Row(
              children: [
                WillPopScope(
                  onWillPop: () async {
                    if (value.isNotEmpty) {
                      widget.controller.selecetdMessages.value = {};
                      return false;
                    }
                    return true;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: value.isNotEmpty ? 40 : 0,
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
                            )
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
                                onPressed: () {
                                  if (myEmoji?.emoji == e) {
                                    Chatify.datasource
                                        .removeMessageEmojis(widget.message.id);
                                  } else {
                                    Chatify.datasource
                                        .addMessageEmojis(widget.message.id, e);
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
                    title: 'Edit',
                    icon: Iconsax.edit,
                    itemTheme: PullDownMenuItemTheme(
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      widget.controller.edit(widget.message);
                    },
                  ),
                if (widget.message is TextMessage) ...[
                  const PullDownMenuDivider(),
                  PullDownMenuItem(
                    title: 'Copy',
                    icon: Iconsax.copy,
                    itemTheme: PullDownMenuItemTheme(
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      widget.controller.copy(widget.message);
                    },
                  ),
                ],
                if (!widget.isSending) ...[
                  const PullDownMenuDivider(),
                  PullDownMenuItem(
                    title: 'Reply',
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
                    title: 'Delete',
                    icon: Iconsax.trash,
                    iconColor: Colors.red,
                    itemTheme: PullDownMenuItemTheme(
                      textStyle: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    onTap: () async {
                      final deleteForAll = await showConfirmDialog(
                        context: context,
                        message:
                            'Are you sure you want to delete this message?',
                        textOK: 'Delete',
                        textCancel: 'Cancel',
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
                    title: 'Cancel',
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
                ]
              ],
              position: PullDownMenuPosition.automatic,
              applyOpacity: false,
              buttonBuilder: (context, showMenu) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (widget.controller.selecetdMessages.value.isNotEmpty) {
                    toggleSelect();
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  showMenu();
                },
                onLongPress: startSwipe,
                onLongPressEnd: (details) =>
                    widget.controller.isSelecting.value = false,
                onHorizontalDragStart: (x) {
                  _startPos = x.globalPosition.dx;
                  hasVibrated = false;
                },
                onHorizontalDragUpdate: (x) {
                  if (-x.globalPosition.dx + _startPos < 0) return;
                  if (-x.globalPosition.dx + _startPos > 100) return;
                  messagePos.value = -x.globalPosition.dx + _startPos;
                  if (messagePos.value > 80 && !hasVibrated) {
                    hasVibrated = true;
                    widget.controller.vibrate();
                  }
                },
                onHorizontalDragEnd: (x) {
                  if (messagePos.value > 80) {
                    messagePos.value = 0;
                    widget.controller.reply(widget.message);
                    return;
                  }
                  messagePos.value = 0;
                },
                onHorizontalDragCancel: () {
                  messagePos.value = 0;
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: ValueListenableBuilder<double>(
                        valueListenable: messagePos,
                        builder: (context, value, child) => Row(
                          children: [
                            if (isMine)
                              AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                width: value,
                                child: value > 20
                                    ? Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Icon(Icons.reply),
                                      )
                                    : SizedBox.shrink(),
                              ),
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
                        child: Dismissible(
                          key: ValueKey('dismissible-${widget.message.id}'),
                          direction: isMine
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          onUpdate: (details) {
                            if (details.progress > 0.1 && !hasVibrated) {
                              hasVibrated = true;
                              widget.controller.vibrate();
                            }
                            messagePos.value = details.progress * 70;
                          },
                          dismissThresholds: {
                            DismissDirection.endToStart: 0.1,
                          },
                          confirmDismiss: (direction) {
                            widget.controller.reply(widget.message);
                            return Future.value(false);
                          },
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
                                          )
                                        : TextMessageCard(
                                            widget: widget,
                                            bkColor: bkColor,
                                            textColor: textColor,
                                            controller: widget.controller,
                                            isMine: isMine,
                                            isSending: widget.isSending,
                                          ),
                              ),
                            ],
                          ),
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
    );
  }
}
