import 'package:chatify/chatify.dart';
import 'package:chatify/src/assets/bloc.dart';
import 'package:flutter/material.dart';
import 'package:chatify/src/ui/chats/chat_card.dart';
import 'package:kr_builder/future_builder.dart';
import 'package:shimmer/shimmer.dart';

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
              child: ChatCard(
                user: user!,
                chat: chat,
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
