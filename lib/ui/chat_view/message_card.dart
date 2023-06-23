import 'package:bubble/bubble.dart';
import 'package:chatify/assets/circular_button.dart';
import 'package:chatify/assets/confirm.dart';
import 'package:chatify/models/controller.dart';
import 'package:chatify/models/theme.dart';
import 'package:chatify/models/user.dart';
import 'package:chatify/ui/chat_view/chatting_room.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/models/chats.dart';
import 'package:chatify/ui/chat_view/image.dart';
import 'package:chatify/ui/chat_view/image_preview.dart';
import 'package:chatify/ui/chat_view/send_at.dart';
import 'package:chatify/ui/chat_view/swipe.dart';
import 'package:chatify/ui/chat_view/voice_message.dart';
import 'package:chatify/models/message.dart';
import 'package:kr_extensions/kr_extensions.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';

bool preventEmoji = false;

class MessageCard extends StatelessWidget {
  final MessageModel message;
  final bool linkedWithBottom;
  final bool linkedWithTop;
  final ChatModel chat;
  final ChatUser user;
  final TextEditingController textController;
  const MessageCard(
      {Key? key,
      required this.message,
      required this.linkedWithBottom,
      required this.linkedWithTop,
      required this.chat,
      required this.user,
      required this.textController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = message.isMine ? Colors.white : Colors.black;
    Color bkColor =
        message.isMine ? currentTheme.primary : Colors.grey.shade100;
    double width = Get.width - 100;
    return Padding(
      padding: EdgeInsets.only(top: !linkedWithTop ? 10 : 0),
      child: Directionality(
        textDirection: message.isMine ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  bottom: 2,
                  end: message.isText || message.hasAudio ? 8 : 13,
                  start: message.isText || message.hasAudio ? 8 : 13,
                ),
                child: ClipRRect(
                  borderRadius: message.isText || message.hasAudio
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
                        backgroundColor: Colors.grey.shade200),
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
                                  spreadRadius: 5)
                            ]),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ['❤', '😍', '😂', '😢', '👍'].map((e) {
                            return AnimatedScale(
                              duration: const Duration(milliseconds: 150),
                              scale: message.myEmoji == e ? 1.3 : 1,
                              child: CircularButton(
                                  highlightColor: Colors.transparent,
                                  icon: Text(
                                    e,
                                    style: const TextStyle(
                                        fontSize: 22, height: 1),
                                  ),
                                  onPressed: () {
                                    if (message.myEmoji == e) {
                                      message
                                        ..emojis.remove(ChatUser.current?.id)
                                        ..save();
                                    } else {
                                      message
                                        ..emojis
                                            .addAll({ChatUser.current!.id: e})
                                        ..save();
                                    }
                                    Get.back();
                                  }),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    itemBuilder: (context) => [
                      if (message.isText)
                        PullDownMenuItem(
                          title: 'Edit'.tr,
                          icon: Icons.edit,
                          onTap: () async {
                            chat.replyMessage.value = null;
                            chat.editedMessage.value = message;
                            textController.text = message.message;
                          },
                        ),
                      const PullDownMenuDivider(),
                      PullDownMenuItem(
                        title: 'Reply'.tr,
                        icon: Icons.reply,
                        onTap: () {
                          chat.editedMessage.value = null;
                          chat.replyMessage.value = message;
                        },
                      ),
                      const PullDownMenuDivider(),
                      PullDownMenuItem(
                          title: 'Delete'.tr,
                          icon: Icons.delete,
                          iconColor: Colors.red,
                          onTap: () async {
                            if (await showConfirm(
                                message: 'Delete selcetd message?',
                                textOK: 'Yes',
                                textCancel: 'No',
                                isKeyboardShown: isKeyboardOpen)) {
                              message.delete();
                            }
                          }),
                    ],
                    position: PullDownMenuPosition.automatic,
                    applyOpacity: false,
                    buttonBuilder: (context, showMenu) => InkWell(
                      onTap: () {
                        if (message.hasImage) {
                          showImage(msg: message, user: user);
                        } else {
                          FocusScope.of(context).unfocus();
                          showMenu();
                        }
                      },
                      onLongPress: () {
                        if (message.hasImage) {
                          showMenu();
                        }
                      },
                      mouseCursor: MouseCursor.defer,
                      child: LayoutBuilder(builder: (context, s) {
                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: SwipeTo(
                            onLeftSwipe: () {
                              chat.replyMessage.value = message;
                            },
                            onRightSwipe: () {
                              chat.replyMessage.value = message;
                            },
                            child: Directionality(
                              textDirection: message.isMine
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: width, minWidth: 80),
                                      child: message.hasAudio
                                          ? MyBubble(
                                              bkColor: bkColor,
                                              linkedWithBottom:
                                                  linkedWithBottom,
                                              message: message,
                                              child: MyVoiceMessage(
                                                  message: message))
                                          : message.hasImage
                                              ? ImageCard(
                                                  message: message,
                                                  width: width,
                                                )
                                              : message.hasCustom
                                                  ? options.customeMessages
                                                          .firstWhereOrNull(
                                                              (e) =>
                                                                  e.key ==
                                                                  message.type)
                                                          ?.builder(context,
                                                              message) ??
                                                      TextMessage(
                                                          widget: this,
                                                          bkColor: bkColor,
                                                          textColor: textColor)
                                                  : TextMessage(
                                                      widget: this,
                                                      bkColor: bkColor,
                                                      textColor: textColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
  });

  final Color bkColor;
  final Color textColor;
  final MessageCard widget;

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
                  right: GetPlatform.isIOS ? 15 : 15,
                  left: GetPlatform.isIOS ? 15 : 15,
                  top: GetPlatform.isIOS ? 8 : 8,
                  bottom: GetPlatform.isIOS ? 8 : 8),
              child: Directionality(
                textDirection: Directionality.of(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.reply != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 27,
                              width: 2,
                              decoration: BoxDecoration(
                                  color: widget.message.isMine
                                      ? Colors.white70
                                      : currentTheme.primary,
                                  borderRadius: BorderRadius.circular(4)),
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
                                            ChatUser.current?.id
                                        ? ChatUser.current!.name
                                        : widget.user.name,
                                    style: TextStyle(
                                        color: textColor.withOpacity(0.8),
                                        fontSize: 14),
                                  ),
                                  Text(
                                    widget.message.reply ?? '',
                                    style: TextStyle(
                                        color: textColor.withOpacity(0.8),
                                        fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                          color: textColor),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: bkColor.withOpacity(widget.message.isMine ? 0.2 : 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.message.emojis.entries
                    .map((e) => Text(
                          e.value,
                          style: const TextStyle(height: 1.3),
                        ))
                    .toList(),
              ),
            ),
          )
      ],
    );
  }
}

class MyBubble extends StatelessWidget {
  const MyBubble({
    super.key,
    required this.message,
    required this.bkColor,
    required this.linkedWithBottom,
    required this.child,
  });

  final MessageModel message;
  final Color bkColor;
  final bool linkedWithBottom;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Bubble(
        radius: const Radius.circular(12),
        nip: message.isMine ? BubbleNip.rightBottom : BubbleNip.leftBottom,
        nipWidth: 5,
        color: bkColor,
        elevation: 0,
        shadowColor: currentTheme.primary,
        showNip: !linkedWithBottom,
        padding: const BubbleEdges.all(0),
        child: child);
  }
}
