import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:chatify/src/ui/common/circular_loading.dart';
import 'package:chatify/src/ui/common/confirm.dart';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/bubble.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/image/image.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/send_at.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice_message.dart';
import 'package:chatify/src/ui/common/kr_builder.dart';
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
  final ChatifyUser user;
  final ChatController controller;

  const MessageCard({
    Key? key,
    required this.message,
    required this.linkedWithBottom,
    required this.linkedWithTop,
    required this.chat,
    required this.user,
    required this.controller,
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
    final bkColor = isMine ? theme.primaryColor : theme.chatGreyForegroundColor;
    final width = MediaQuery.of(context).size.width - 100;
    final myEmoji = widget.message.emojis
        .cast<MessageEmoji?>()
        .firstWhere((e) => e?.uid == Chatify.currentUserId, orElse: () => null);
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
                AnimatedContainer(
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
              topWidget: Padding(
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
                if (widget.message.type.isTextOrUnsupported && isMine)
                  PullDownMenuItem(
                    title: 'Edit',
                    icon: Iconsax.edit,
                    onTap: () {
                      widget.controller.edit(widget.message);
                    },
                  ),
                const PullDownMenuDivider(),
                PullDownMenuItem(
                  title: 'Copy',
                  icon: Iconsax.copy,
                  onTap: () {
                    widget.controller.copy(widget.message);
                  },
                ),
                const PullDownMenuDivider(),
                PullDownMenuItem(
                  title: 'Reply',
                  icon: Iconsax.undo,
                  onTap: () {
                    widget.controller.reply(widget.message);
                  },
                ),
                const PullDownMenuDivider(),
                PullDownMenuItem(
                  title: 'Delete',
                  icon: Icons.delete,
                  iconColor: Colors.red,
                  onTap: () async {
                    if (await showConfirm(
                      context: context,
                      message: 'Delete selected message?',
                      textOK: 'Yes',
                      textCancel: 'No',
                      isKeyboardShown:
                          widget.controller.keyboardController.isKeybaordOpen,
                    )) {
                      Chatify.datasource.deleteMessageForAll(widget.message.id);
                    }
                  },
                ),
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
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: width,
                              minWidth: 80,
                            ),
                            child: widget.message is VoiceMessage
                                ? MyBubble(
                                    bkColor: bkColor,
                                    linkedWithBottom: widget.linkedWithBottom,
                                    linkedWithTop: widget.linkedWithTop,
                                    message: widget.message,
                                    child: MyVoiceMessage(
                                      message: widget.message as VoiceMessage,
                                      controller: widget.controller,
                                      user: widget.user,
                                    ),
                                  )
                                : widget.message is ImageMessage
                                    ? ImageCard(
                                        message: widget.message as ImageMessage,
                                        chatController: widget.controller,
                                        user: widget.user,
                                      )
                                    : TextMessage(
                                        widget: widget,
                                        bkColor: bkColor,
                                        textColor: textColor,
                                        controller: widget.controller,
                                        isMine: isMine,
                                      ),
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

class TextMessage extends StatefulWidget {
  const TextMessage({
    super.key,
    required this.widget,
    required this.bkColor,
    required this.textColor,
    required this.controller,
    required this.isMine,
  });

  final Color bkColor;
  final Color textColor;
  final bool isMine;
  final MessageCard widget;
  final ChatController controller;

  @override
  State<TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  Message? repliedMsg;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: widget.widget.message.emojis.isEmpty ? 0 : 14,
          ),
          child: MyBubble(
            message: widget.widget.message,
            bkColor: widget.bkColor,
            linkedWithBottom: widget.widget.linkedWithBottom,
            linkedWithTop: widget.widget.linkedWithTop,
            child: Padding(
              padding: EdgeInsets.only(
                right: widget.isMine ? 8 : 16,
                left: widget.isMine ? 16 : 8,
                top: 8,
                bottom: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.widget.message.replyId != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: SizedBox(
                        height: 37,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 27,
                              width: 2,
                              decoration: BoxDecoration(
                                color: widget.isMine
                                    ? Colors.white70
                                    : Chatify.theme.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.widget.message.replyUid ==
                                            Chatify.currentUserId
                                        ? 'Me'
                                        : widget.widget.user.name,
                                    style: TextStyle(
                                      color: widget.textColor.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Expanded(
                                    child: repliedMsg != null
                                        ? Text(
                                            repliedMsg?.message ?? '',
                                            style: TextStyle(
                                              color: widget.textColor
                                                  .withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : KrFutureBuilder<Message?>(
                                            future:
                                                Chatify.datasource.readMessage(
                                              widget.widget.message.replyId!,
                                            ),
                                            onEmpty: Text(
                                              'An error occured!',
                                              style: TextStyle(
                                                color: widget.textColor
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            onError: (_) => Text(
                                              'An error occured!',
                                              style: TextStyle(
                                                color: widget.textColor
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            onLoading: SizedBox(
                                              width: 20,
                                              child: Center(
                                                child: LoadingWidget(
                                                  size: 10,
                                                  lineWidth: 1,
                                                  color: widget.isMine
                                                      ? Colors.white
                                                      : Chatify
                                                          .theme.primaryColor,
                                                ),
                                              ),
                                            ),
                                            builder: (message) {
                                              repliedMsg = message;
                                              return Text(
                                                message?.message ?? '',
                                                style: TextStyle(
                                                  color: widget.textColor
                                                      .withOpacity(0.8),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.widget.message.message.length < 35)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(),
                          child: SendAtWidget(message: widget.widget.message),
                        ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Wrap(
                            children: widget.widget.message.message.urls
                                .map(
                                  (e) => Text(
                                    e,
                                    style: TextStyle(
                                      decoration: e.isURL
                                          ? TextDecoration.underline
                                          : null,
                                      color: widget.textColor,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.widget.message.message.length >= 35)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(),
                      child: SendAtWidget(message: widget.widget.message),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.widget.message.emojis.isNotEmpty)
          Container(
            margin: const EdgeInsetsDirectional.only(end: 10),
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: widget.bkColor.withOpacity(widget.isMine ? 0.2 : 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.widget.message.emojis
                    .map(
                      (e) => Text(
                        e.emoji,
                        style: const TextStyle(height: 1.3),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
      ],
    );
  }
}
