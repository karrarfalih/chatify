import 'dart:math';

import 'package:chatify/assets/image.dart';
import 'package:chatify/models/chats.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/models/theme.dart';
import 'package:chatify/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kr_builder/future_builder.dart';
import 'package:kr_builder/shimmer_bloc.dart';
import 'package:kr_extensions/kr_extensions.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.user,
    required this.chat,
    this.margin,
  }) : super(key: key);
  final ChatUser user;
  final ChatModel chat;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MyImage(
                url: chat.imageUrl ?? user.profileImage ?? '',
                height: 50,
                width: 50,
                isCircle: true,
                onError: const Icon(Icons.person, color: Colors.grey)),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FutureBuilder<QuerySnapshot<MessageModel>>(
                    future: chat.unSeenMessages.get(),
                    builder: (ctx, docs) {
                      int? count = docs.data?.docs.length ?? chat.count;
                      chat.count = count;
                      MessageModel? lastMsg = ((docs.data?.docs.isEmpty ?? true)
                              ? null
                              : docs.data?.docs.first.data()) ??
                          chat.lastMessage;
                      chat.lastMessage = lastMsg;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(height: 1),
                                ),
                                Text(
                                  chat.updatedAt?.format(DateTime.now()
                                                  .difference(chat.updatedAt!)
                                                  .inHours <
                                              24
                                          ? 'h:mm a'
                                          : 'd MMMM') ??
                                      '',
                                  style: TextStyle(
                                      height: 1,
                                      color: currentTheme.subTitleStyle.color,
                                      fontSize: 12),
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (lastMsg != null)
                                Expanded(
                                  child: Text(
                                    lastMsg.message,
                                    style: TextStyle(
                                        height: 1.4,
                                        color:
                                            currentTheme.subTitleStyle.color),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )
                              else if (docs.connectionState ==
                                  ConnectionState.done)
                                KrFutureBuilder<QuerySnapshot<MessageModel>>(
                                  future: chat.messages.limit(1).get(),
                                  onLoading: const Padding(
                                    padding: EdgeInsets.only(top: 3),
                                    child: ShimmerBloc(
                                        size: Size(200, 18), radius: 5),
                                  ),
                                  builder: (data) {
                                    return Expanded(
                                      child: Text(
                                        data.docs.isEmpty
                                            ? ''
                                            : data.docs.first.data().message,
                                        style: TextStyle(
                                            height: 1.4,
                                            color: currentTheme
                                                .subTitleStyle.color),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    );
                                  },
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: ShimmerBloc(
                                      size: Size(200, 18), radius: 5),
                                ),
                              if (count != null && count != 0)
                                Container(
                                  height: 20,
                                  width: 20,
                                  margin: const EdgeInsetsDirectional.only(
                                      start: 5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentTheme.primary),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (min(count, 99)).toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
            )
          ],
        ),
      ],
    );
  }
}
