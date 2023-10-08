import 'package:chatify/chatify.dart';
import 'package:chatify/src/assets/bloc.dart';
import 'package:chatify/src/ui/common/kr_builder.dart';
import 'package:chatify/src/ui/common/shimmer_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:chatify/src/assets/date_format.dart';
import 'package:chatify/src/assets/image.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';

class ChatRoomCard extends StatelessWidget {
  final Chat chat;
  const ChatRoomCard({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: KrFutureBuilder<ChatifyUser?>(
        future: Chatify.config.getUserById(chat.id),
        onLoading: const ChatRoomBloc(),
        builder: (user) {
          return InkWell(
            highlightColor: Colors.transparent,
            onTap: () async {
              await Chatify.openChat(context, chat: chat, user: user!);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomImage(
                        url: chat.imageUrl ?? user?.profileImage ?? '',
                        height: 50,
                        width: 50,
                        radius: 50,
                        onError: const Icon(Icons.person, color: Colors.grey),
                      ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      user?.name ?? 'Deleted User',
                                      style: const TextStyle(height: 1),
                                    ),
                                    Text(
                                      chat.updatedAt?.format(
                                            context,
                                            DateTime.now()
                                                        .difference(
                                                            chat.updatedAt!)
                                                        .inHours <
                                                    24
                                                ? 'h:mm a'
                                                : 'd MMMM',
                                          ) ??
                                          '',
                                      style: TextStyle(
                                        height: 1,
                                        color: ChatifyTheme.of(context)
                                            .recentChatsBackgroundColor
                                            .withOpacity(.5),
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  KrStreamBuilder<Message?>(
                                    stream: Chatify.datasource
                                        .lastMessageStream(chat.id),
                                    onLoading: const Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: ShimmerBloc(
                                          size: Size(200, 18), radius: 5),
                                    ),
                                    onEmpty: Container(
                                      height: 300,
                                      width: 300,
                                      color: Colors.red,
                                    ),
                                    onError: (p0) => Text(p0?.toString() ?? ''),
                                    builder: (message) {
                                      return Expanded(
                                        child: Text(
                                          message?.message ?? '',
                                          style: TextStyle(
                                            height: 1.4,
                                            color: ChatifyTheme.of(context)
                                                .recentChatsBackgroundColor
                                                .withOpacity(.5),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      );
                                    },
                                  ),
                                  KrStreamBuilder<int>(
                                    stream: Chatify.datasource
                                        .unSeenMessagesCount(chat.id),
                                    onLoading: const SizedBox(),
                                    builder: (count) {
                                      if (count == 0) return const SizedBox();
                                      return Container(
                                        height: 20,
                                        width: 20,
                                        margin:
                                            const EdgeInsetsDirectional.only(
                                                start: 5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ChatifyTheme.of(context)
                                              .primaryColor,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          (min(count, 99)).toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatRoomBloc extends StatelessWidget {
  const ChatRoomBloc({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.2),
        highlightColor: Colors.grey.withOpacity(0.4),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 10),
              child: MyBlock(
                height: 50,
                width: 50,
                radius: 25,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyBlock(height: 15, width: 60, space: 5),
                MyBlock(height: 12, width: 150),
              ],
            )
          ],
        ),
      ),
    );
  }
}