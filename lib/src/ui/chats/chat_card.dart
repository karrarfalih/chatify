import 'dart:math';

import 'package:chatify/src/assets/date_format.dart';
import 'package:chatify/src/assets/image.dart';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:flutter/material.dart';
import 'package:kr_builder/kr_builder.dart';
import 'package:kr_builder/shimmer_bloc.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.user,
    required this.chat,
    this.margin,
  }) : super(key: key);
  final ChatifyUser user;
  final Chat chat;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomImage(
              url: chat.imageUrl ?? user.profileImage ?? '',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(height: 1),
                          ),
                          Text(
                            chat.updatedAt?.format(
                                  context,
                                  DateTime.now()
                                              .difference(chat.updatedAt!)
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
                          stream: Chatify.datasource.lastMessageStream(chat.id),
                          onLoading: const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: ShimmerBloc(size: Size(200, 18), radius: 5),
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
                          stream:
                              Chatify.datasource.unSeenMessagesCount(chat.id),
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
                                color: ChatifyTheme.of(context).primaryColor,
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
    );
  }
}
