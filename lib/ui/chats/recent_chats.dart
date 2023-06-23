import 'package:chat/models/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat/ui/chats/chat_room_card.dart';
import 'package:chat/models/chats.dart';
import 'package:kr_paginate_firestore/paginate_firestore.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KrPaginateFirestore(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, docs, i) {
        ChatModel room = docs.elementAt(i).data() as ChatModel;
        return ChatRoomCard(
          chat: room,
        );
      },
      separator: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Divider(
          height: 1,
          color: Colors.black.withOpacity(0.08),
        ),
      ),
      query: ChatModel.getRooms(),
      onEmpty: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.chat_bubble,
                color: currentTheme.titleStyle.color?.withOpacity(0.7),
                size: 50,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'No messages'.tr,
                style: currentTheme.titleStyle.copyWith(
                    color: currentTheme.titleStyle.color?.withOpacity(0.8),
                    fontSize: 16),
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
