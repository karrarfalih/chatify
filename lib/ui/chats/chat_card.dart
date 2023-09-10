import 'dart:math';

import 'package:chatify/assets/image.dart';
import 'package:chatify/models/chats.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/models/theme.dart';
import 'package:chatify/models/user.dart';
import 'package:flutter/material.dart';
import 'package:kr_builder/kr_builder.dart';
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
    chat.getLastMessage();
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
                child: Column(
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
                        KrStreamBuilder<MessageModel?>(
                            stream: chat.lastMessageStream,
                            onLoading: const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child:
                                  ShimmerBloc(size: Size(200, 18), radius: 5),
                            ),
                            builder: (message) {
                              return Expanded(
                                child: Text(
                                  message?.message ?? '',
                                  style: TextStyle(
                                      height: 1.4,
                                      color: currentTheme.subTitleStyle.color),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }),
                        KrStreamBuilder<int>(
                            stream: chat.unSeenMessagesCount,
                            onLoading: const SizedBox(),
                            builder: (count) {
                              if (count == 0) return const SizedBox();
                              return Container(
                                height: 20,
                                width: 20,
                                margin:
                                    const EdgeInsetsDirectional.only(start: 5),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentTheme.primary),
                                alignment: Alignment.center,
                                child: Text(
                                  (min(count, 99)).toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              );
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
