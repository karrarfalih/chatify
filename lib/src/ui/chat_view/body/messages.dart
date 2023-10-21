import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice_message.dart';
import 'package:chatify/src/ui/common/paginate_firestore/paginate_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatify/src/ui/chat_view/body/date.dart';
import 'package:chatify/src/ui/chat_view/message/message_card.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.chat,
    required this.user,
    required this.controller,
  });

  final Chat chat;
  final ChatifyUser user;
  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (x) {
        controller.preventEmoji = true;
        return false;
      },
      child: KrPaginateFirestore(
        key: const ValueKey('chat'),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, docs, i) {
          Message msg = docs.elementAt(i).data() as Message;
          if (msg.unSeenBy.contains(Chatify.currentUserId)) {
            Chatify.datasource.markAsSeen(msg.id);
          }
          Message? prevMsg;
          Message? nextMsg;
          if (docs.length != i + 1) {
            prevMsg = docs.elementAt(i + 1).data() as Message;
          }
          if (i != 0) {
            nextMsg = docs.elementAt(i - 1).data() as Message;
          }
          DateTime? date = msg.sendAt;
          DateTime? prevDate = prevMsg?.sendAt;
          bool showTime = false;
          if (date != null) {
            DateTime d = DateTime(date.year, date.month, date.day);
            DateTime prevD = prevDate == null
                ? DateTime(19000)
                : DateTime(
                    prevDate.year,
                    prevDate.month,
                    prevDate.day,
                  );
            showTime = d.toString() != prevD.toString();
          }
          if (controller.pendingMessages.value.any((e) => e.id == msg.id)) {
            controller.pendingMessages.value.removeWhere((e) => e.id == msg.id);
            controller.pendingMessages.refresh();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (i == docs.length - 1)
                SizedBox(
                  key: ValueKey('chat padding bottom'),
                  height: MediaQuery.of(context).padding.top + 70,
                ),
              if (showTime)
                Center(
                  key: ValueKey(msg.sendAt),
                  child: ChatDateWidget(
                    date: date ?? DateTime.now(),
                  ),
                ),
              MessageCard(
                key: ValueKey(msg.id),
                chat: chat,
                message: msg,
                user: user,
                controller: controller,
                linkedWithBottom: (nextMsg != null &&
                    nextMsg.sender == msg.sender &&
                    nextMsg.sendAt?.day == msg.sendAt?.day),
                linkedWithTop: !showTime &&
                    prevMsg != null &&
                    prevMsg.sender == msg.sender,
              ),
              if (i == 0)
                PendingMessages(
                  key: ValueKey('pending messages'),
                  controller: controller,
                  chat: chat,
                  user: user,
                  linkedWithBottom: false,
                  linkedWithTop: msg.isMine,
                )
            ],
          );
        },
        query: Chatify.datasource.messagesQuery(chat.id),
        onEmpty: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Say Hi',
                style: TextStyle(
                  color: ChatifyTheme.of(context).chatForegroundColor,
                ),
              ),
            ],
          ),
        ),
        header: SliverToBoxAdapter(
          child: SizedBox(
            height: 5,
          ),
        ),
        itemBuilderType: PaginateBuilderType.listView,
        initialLoader: ListView(
          children: [],
        ),
        reverse: true,
        isLive: true,
      ),
    );
  }
}

class PendingMessages extends StatelessWidget {
  const PendingMessages({
    super.key,
    required this.controller,
    required this.chat,
    required this.user,
    required this.linkedWithTop,
    required this.linkedWithBottom,
  });

  final ChatController controller;
  final Chat chat;
  final ChatifyUser user;
  final bool linkedWithTop;
  final bool linkedWithBottom;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Message>>(
      valueListenable: controller.pendingMessages,
      builder: (context, value, cild) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...value.map(
                (e) => Column(
                  children: [
                    if (e is VoiceMessage)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: 4,
                          end: 12,
                          start: 12,
                        ),
                        child: MyVoiceMessageBloc(
                          linkedWithTop: true,
                          linkedWithBottom: false,
                          message: e,
                          controller: controller,
                        ),
                      ),
                    if (e is ImageMessage)
                      MessageCard(
                        key: ValueKey(e.id),
                        chat: chat,
                        message: e,
                        user: user,
                        controller: controller,
                        linkedWithBottom: linkedWithBottom,
                        linkedWithTop: linkedWithTop,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
