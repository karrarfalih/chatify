import 'dart:io';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:chatify/src/ui/common/confirm.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/bubble.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/image.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/send_at.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice_message.dart';
import 'package:chatify/src/ui/common/image_preview.dart';
import 'package:chatify/src/ui/common/kr_builder.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/swipe.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';

class MessageCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = ChatifyTheme.of(context);
    final isMine = message.sender == Chatify.currentUserId;
    message.type == MessageType.unSupported;
    final textColor = isMine ? Colors.white : theme.chatForegroundColor;
    final bkColor = isMine ? theme.primaryColor : theme.chatGreyForegroundColor;
    final width = MediaQuery.of(context).size.width - 100;
    final myEmoji = message.emojis
        .cast<MessageEmoji?>()
        .firstWhere((e) => e?.uid == Chatify.currentUserId, orElse: () => null);
    return Animate(
      effects: [
        SlideEffect(begin: Offset(0, 0.5)),
        ScaleEffect(
          alignment: Alignment.centerRight,
        ),
      ],
      child: Padding(
        padding: EdgeInsets.only(top: !linkedWithTop ? 10 : 0),
        child: Directionality(
          textDirection: isMine ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    bottom: 2,
                    end:
                        message.type.isTextOrUnsupported || message.type.isVoice
                            ? 8
                            : 13,
                    start:
                        message.type.isTextOrUnsupported || message.type.isVoice
                            ? 8
                            : 13,
                  ),
                  child: ClipRRect(
                    borderRadius: message.type.isTextOrUnsupported ||
                            message.type.isVoice
                        ? BorderRadius.zero
                        : BorderRadiusDirectional.only(
                            topStart: Radius.circular(linkedWithTop ? 0 : 12),
                            bottomStart:
                                Radius.circular(linkedWithBottom ? 0 : 12),
                            topEnd: const Radius.circular(12),
                            bottomEnd: const Radius.circular(12),
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
                                          .removeMessageEmojis(message.id);
                                    } else {
                                      Chatify.datasource
                                          .addMessageEmojis(message.id, e);
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
                        if (message.type.isTextOrUnsupported && isMine)
                          PullDownMenuItem(
                            title: 'Edit',
                            icon: Iconsax.edit,
                            onTap: () {
                              controller.edit(message);
                            },
                          ),
                        const PullDownMenuDivider(),
                        PullDownMenuItem(
                          title: 'Copy',
                          icon: Iconsax.copy,
                          onTap: () {
                            controller.copy(message);
                          },
                        ),
                        const PullDownMenuDivider(),
                        PullDownMenuItem(
                          title: 'Reply',
                          icon: Iconsax.undo,
                          onTap: () {
                            controller.reply(message);
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
                              message: 'Delete selcetd message?',
                              textOK: 'Yes',
                              textCancel: 'No',
                              isKeyboardShown: controller.isKeyboardOpen,
                            )) {}
                          },
                        ),
                      ],
                      position: PullDownMenuPosition.automatic,
                      applyOpacity: false,
                      buttonBuilder: (context, showMenu) => InkWell(
                        onTap: () {
                          if (message.type == MessageType.image) {
                            Navigator.of(context).push(
                              ImagePreview.route(message: message, user: user),
                            );
                          } else {
                            FocusScope.of(context).unfocus();
                            showMenu();
                          }
                        },
                        onLongPress: () {
                          if (message.type == MessageType.image) {
                            showMenu();
                          }
                        },
                        mouseCursor: MouseCursor.defer,
                        child: LayoutBuilder(
                          builder: (context, s) {
                            return Directionality(
                              textDirection: TextDirection.ltr,
                              child: SwipeTo(
                                onLeftSwipe: () {
                                  controller.reply(message);
                                },
                                onRightSwipe: () {
                                  controller.reply(message);
                                },
                                child: Directionality(
                                  textDirection: isMine
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Flexible(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: width,
                                            minWidth: 80,
                                          ),
                                          child: message.type.isVoice
                                              ? MyBubble(
                                                  bkColor: bkColor,
                                                  linkedWithBottom:
                                                      linkedWithBottom,
                                                  message: message,
                                                  child: MyVoiceMessage(
                                                    message: message,
                                                    controller: controller,
                                                  ),
                                                )
                                              : message.type.isImage
                                                  ? ImageCard(
                                                      message: message,
                                                      width: width,
                                                    )
                                                  : TextMessage(
                                                      widget: this,
                                                      bkColor: bkColor,
                                                      textColor: textColor,
                                                      controller: controller,
                                                      isMine: isMine,
                                                    ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: widget.message.emojis.isEmpty ? 0 : 14),
          child: MyBubble(
            message: widget.message,
            bkColor: bkColor,
            linkedWithBottom: widget.linkedWithBottom,
            child: Padding(
              padding: EdgeInsets.only(
                right: Platform.isIOS ? 15 : 15,
                left: Platform.isIOS ? 15 : 15,
                top: Platform.isIOS ? 8 : 8,
                bottom: Platform.isIOS ? 8 : 8,
              ),
              child: Directionality(
                textDirection: Directionality.of(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.replyId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 27,
                              width: 2,
                              decoration: BoxDecoration(
                                color: isMine
                                    ? Colors.white70
                                    : ChatifyTheme.of(context).primaryColor,
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
                                    widget.message.replyUid ==
                                            Chatify.currentUserId
                                        ? 'Me'
                                        : widget.user.name,
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  KrFutureBuilder<Message?>(
                                    future: Chatify.datasource
                                        .readMessage(widget.message.replyId!),
                                    onEmpty: Text(
                                      'An error occured!',
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onError: (_) => Text(
                                      'An error occured!',
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    builder: (message) {
                                      return Text(
                                        message?.message ?? '',
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.message.message.length < 35)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(),
                            child: SendAtWidget(message: widget.message),
                          ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Wrap(
                              children: widget.message.message.urls
                                  .map(
                                    (e) => Text(
                                      e,
                                      style: TextStyle(
                                        decoration: e.isURL
                                            ? TextDecoration.underline
                                            : null,
                                        color: textColor,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.message.message.length >= 35)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(),
                        child: SendAtWidget(message: widget.message),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.message.emojis.isNotEmpty)
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
                color: bkColor.withOpacity(isMine ? 0.2 : 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.message.emojis
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
