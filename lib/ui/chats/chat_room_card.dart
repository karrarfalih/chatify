import 'dart:async';

import 'package:chatify/models/user.dart';
import 'package:chatify/ui/common/bloc.dart';
import 'package:flutter/material.dart';
import 'package:chatify/ui/chats/chat_card.dart';
import 'package:kr_builder/future_builder.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chatify/models/chats.dart';

class ChatRoomCard extends StatefulWidget {
  final ChatModel chat;
  const ChatRoomCard({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<ChatRoomCard> createState() => _ChatRoomCardState();
}

class _ChatRoomCardState extends State<ChatRoomCard> {
  late StreamSubscription<ChatModel?> stream;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Colors.transparent,
        child: KrFutureBuilder<ChatUser?>(
            future: widget.chat.getReceiverAccount(),
            onLoading: const ChatRoomBloc(),
            builder: (data) {
              return _card(data!);
            }));
  }

  Widget _card(ChatUser user) {
    return InkWell(
        highlightColor: Colors.transparent,
        onTap: () async {
          await widget.chat.open(user);
          widget.chat.markAsSeen();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
          child: ChatCard(
            user: user,
            chat: widget.chat,
          ),
        ));
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
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
              children: const [
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
