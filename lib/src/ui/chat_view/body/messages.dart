import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:chatify/src/ui/chat_view/body/date.dart';
import 'package:kr_paginate_firestore/paginate_firestore.dart';
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
          Chatify.datasource.markAsSeen(msg.id);
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
          return Column(
            children: [
              if (showTime)
                ChatDateWidget(
                  date: date ?? DateTime.now(),
                ),
              MessageCard(
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
                ValueListenableBuilder<List<Message>>(
                  valueListenable: controller.pendingMessages,
                  builder: (context, value, cild) {
                    final width = MediaQuery.of(context).size.width;
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        children: [
                          ...value.map(
                            (e) => Row(
                              children: [
                                if (e.type.isVoice)
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.only(
                                      bottom: 4,
                                      end: 12,
                                      start: 12,
                                    ),
                                    child: MyVoiceMessageBloc(
                                      linkedWithTop: true,
                                      linkedWithBottom:
                                          i != value.length - 1,
                                    ),
                                  ),
                                if (e.type.isImage)
                                  Container(
                                    margin:
                                        const EdgeInsetsDirectional.only(
                                      bottom: 4,
                                      end: 12,
                                      start: 12,
                                    ),
                                    constraints: BoxConstraints.tightFor(
                                      width: width - 100,
                                      height: width - 100,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                      color: Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor,
                                    ),
                                    child: Center(
                                      child: SpinKitRing(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor,
                                        size: 32,
                                        lineWidth: 5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                  color: ChatifyTheme.of(context).chatBackgroundColor,
                ),
              ),
            ],
          ),
        ),
        header: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return const SizedBox(
                height: 5,
              );
            },
            childCount: 1,
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
