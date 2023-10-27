import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/models/chat.dart';
import 'package:chatify/src/ui/chats/connectivity.dart';
import 'package:chatify/src/ui/common/paginate_firestore/paginate_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatify/src/ui/chats/chat_card.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({
    Key? key, required this.connectivity,
  }) : super(key: key);

  final ChatifyConnectivity connectivity;

  @override
  Widget build(BuildContext context) {
    return KrPaginateFirestore(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, docs, i) {
        Chat room = docs.elementAt(i).data() as Chat;
        return ChatRoomCard(
          key: ValueKey(room),
          chat: room,
          connectivity: connectivity,
        );
      },
      separator: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Divider(
          height: 1,
          color: Colors.black.withOpacity(0.08),
        ),
      ),
      query: Chatify.datasource.chatsQuery,
      onEmpty: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.chat_bubble,
                color:
                    Chatify.theme.recentChatsForegroundColor.withOpacity(0.7),
                size: 50,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'No messages',
                style: TextStyle(
                  color:
                      Chatify.theme.recentChatsForegroundColor.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
      itemBuilderType: PaginateBuilderType.listView,
      isLive: true,
      initialLoader: const ChatRoomBloc(),
      bottomLoader: const ChatRoomBloc(),
    );
  }
}
