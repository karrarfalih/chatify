import 'dart:async';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/chatting_room.dart';
import 'package:chatify/src/ui/chat_view/controllers/pending_messages.dart';
import 'package:chatify/src/ui/chats/chat_image.dart';
import 'package:chatify/src/ui/chats/connectivity.dart';
import 'package:chatify/src/ui/common/bloc.dart';
import 'package:chatify/src/ui/common/kr_builder.dart';
import 'package:chatify/src/ui/common/shimmer_bloc.dart';
import 'package:chatify/src/ui/common/swipeable_page_route.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

class ChatRoomCard extends StatefulWidget {
  final Chat chat;

  const ChatRoomCard({
    Key? key,
    required this.chat,
    required this.connectivity,
  }) : super(key: key);

  final ChatifyConnectivity connectivity;

  @override
  State<ChatRoomCard> createState() => _ChatRoomCardState();
}

class _ChatRoomCardState extends State<ChatRoomCard> {
  late final PendingMessagesHandler pendingMessages;
  final BehaviorSubject<Message?> pendingMessagesSubject =
      BehaviorSubject.seeded(null);

  final BehaviorSubject<_PendingMessage?> lastMessageSubject =
      BehaviorSubject.seeded(null);
  late final StreamSubscription<_PendingMessage?> lastMessageSubscription;

  @override
  void initState() {
    pendingMessages = ChatScreen.pendingMessagesHandlers[widget.chat.id] ??
        PendingMessagesHandler(chat: widget.chat);
    ChatScreen.pendingMessagesHandlers[widget.chat.id] = pendingMessages;
    pendingMessages.messages.addListener(_listenToPendingMessages);
    var lastMessage = Rx.combineLatest2<Message?, Message?, _PendingMessage?>(
        Chatify.datasource.lastMessageStream(widget.chat),
        pendingMessagesSubject, (actual, pending) {
      if (pending == null || pending.id == actual?.id) {
        return _PendingMessage(actual, true);
      }
      return _PendingMessage(pending, false);
    });
    lastMessageSubscription = lastMessage.listen((event) {
      lastMessageSubject.add(event);
    });
    super.initState();
  }

  void _listenToPendingMessages() {
    if (pendingMessages.messages.value.isEmpty)
      return pendingMessagesSubject.add(null);
    pendingMessagesSubject.add(pendingMessages.messages.value.last);
  }

  @override
  void dispose() {
    pendingMessages.messages.removeListener(_listenToPendingMessages);
    lastMessageSubscription.cancel();
    pendingMessagesSubject.close();
    super.dispose();
  }

  Future<List<ChatifyUser>> getUsers() async {
    return await Future.wait(
      widget.chat.members.map((e) => Chatify.config.getUserById(e)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: KrFutureBuilder<List<ChatifyUser>>(
        future: getUsers(),
        onLoading: const ChatRoomBloc(),
        onError: (e) {
          return Text(e.toString());
        },
        builder: (users) {
          return InkWell(
            highlightColor: Colors.transparent,
            onTap: () async {
              Navigator.of(context).push(
                SwipeablePageRoute(
                  builder: (context) => ChatView(
                    chat: widget.chat,
                    users: users,
                    pendingMessagesHandler: pendingMessages,
                    connectivity: widget.connectivity,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          ChatImage(users: users.withoutMeOrMe),
                          if (users.length == 1 &&
                              users.first != Chatify.currentUserId)
                            KrStreamBuilder<UserLastSeen>(
                              stream: Chatify.datasource.getUserLastSeen(
                                users.first.id,
                                widget.chat.id,
                              ),
                              builder: (lastSeen) {
                                if (!lastSeen.isActive) return const SizedBox();
                                return Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                        ],
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
                                    Expanded(
                                      child: Text(
                                        users.withoutMeOrMe
                                            .map((e) => e.name.split(' ').first)
                                            .join(', '),
                                        style: const TextStyle(height: 1),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    KrStreamBuilder<_PendingMessage?>(
                                      stream: lastMessageSubject,
                                      onLoading: const SizedBox.shrink(),
                                      builder: (message) {
                                        return ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: 20,
                                            maxWidth: 120,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (!message!.isSent)
                                                Lottie.asset(
                                                  'assets/lottie/sending${Chatify.theme.isRecentChatsDark ? '' : '_black'}.json',
                                                  package: 'chatify',
                                                  fit: BoxFit.fitHeight,
                                                  height: 12,
                                                )
                                              else
                                                Image.asset(
                                                  message.message!.seenBy
                                                          .where(
                                                            (e) =>
                                                                e !=
                                                                Chatify
                                                                    .currentUserId,
                                                          )
                                                          .isNotEmpty
                                                      ? 'assets/icons/seen.png'
                                                      : 'assets/icons/sent.png',
                                                  package: 'chatify',
                                                  height: 17,
                                                  color: Chatify
                                                      .theme.primaryColor
                                                      .withOpacity(.5),
                                                ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight: 20,
                                                  maxWidth: 70,
                                                ),
                                                child: Text(
                                                  (message.message?.sendAt ??
                                                              message.message
                                                                  ?.pendingTime)
                                                          ?.format(
                                                        context,
                                                        DateTime.now()
                                                                    .difference(
                                                                      (message.message
                                                                              ?.sendAt ??
                                                                          message
                                                                              .message
                                                                              ?.pendingTime)!,
                                                                    )
                                                                    .inHours <
                                                                24
                                                            ? 'h:mm a'
                                                            : 'd MMM',
                                                      ) ??
                                                      '',
                                                  style: TextStyle(
                                                    height: 1,
                                                    color: Chatify.theme
                                                        .recentChatsForegroundColor
                                                        .withOpacity(.5),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: KrStreamBuilder<_PendingMessage?>(
                                      stream: lastMessageSubject,
                                      onLoading: Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 3),
                                          child: ShimmerBloc(
                                            size: Size(200, 18),
                                            radius: 5,
                                          ),
                                        ),
                                      ),
                                      builder: (message) {
                                        return Text(
                                          message!.message?.message ?? '',
                                          style: TextStyle(
                                            height: 1.4,
                                            color: Chatify.theme
                                                .recentChatsForegroundColor
                                                .withOpacity(.5),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        );
                                      },
                                    ),
                                  ),
                                  KrStreamBuilder<int>(
                                    stream: Chatify.datasource
                                        .unSeenMessagesCount(widget.chat.id),
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

class _PendingMessage {
  final Message? message;
  final bool isSent;

  _PendingMessage(this.message, this.isSent);
}
