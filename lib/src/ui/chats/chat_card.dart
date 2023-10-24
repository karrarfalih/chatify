import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/common/bloc.dart';
import 'package:chatify/src/ui/common/kr_builder.dart';
import 'package:chatify/src/ui/common/shimmer_bloc.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:chatify/src/ui/common/image.dart';
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
        future: Chatify.config.getUserById(
          chat.members
              .where((e) => e != Chatify.currentUserId)
              .firstWhere((_) => true, orElse: () => Chatify.currentUserId),
        ),
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
                        fit: BoxFit.cover,
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
                                    const Spacer(),
                                    KrStreamBuilder<Message?>(
                                      stream: Chatify.datasource
                                          .lastMessageStream(chat),
                                      onLoading: const SizedBox.shrink(),
                                      builder: (message) {
                                        if (!message!.isMine)
                                          return SizedBox.shrink();
                                        return Image.asset(
                                          message.seenBy
                                                  .where(
                                                    (e) =>
                                                        e !=
                                                        Chatify.currentUserId,
                                                  )
                                                  .isNotEmpty
                                              ? 'assets/icons/seen.png'
                                              : 'assets/icons/sent.png',
                                          package: 'chatify',
                                          height: 17,
                                          color: Chatify.theme.primaryColor
                                              .withOpacity(.5),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      chat.updatedAt?.format(
                                            context,
                                            DateTime.now()
                                                        .difference(
                                                          chat.updatedAt!,
                                                        )
                                                        .inHours <
                                                    24
                                                ? 'h:mm a'
                                                : 'd MMM',
                                          ) ??
                                          '',
                                      style: TextStyle(
                                        height: 1,
                                        color: Chatify
                                            .theme.recentChatsForegroundColor
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
                                        .lastMessageStream(chat),
                                    onLoading: const Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: ShimmerBloc(
                                        size: Size(200, 18),
                                        radius: 5,
                                      ),
                                    ),
                                    builder: (message) {
                                      return Expanded(
                                        child: Text(
                                          message?.message ?? '',
                                          style: TextStyle(
                                            height: 1.4,
                                            color: Chatify.theme
                                                .recentChatsForegroundColor
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
                                          start: 5,
                                          top: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Chatify.theme.primaryColor,
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
