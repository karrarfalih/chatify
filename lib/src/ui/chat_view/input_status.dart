import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/common/expanded_section.dart';
import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

class UsersInputStatus extends StatelessWidget {
  const UsersInputStatus({
    super.key,
    required this.chatId,
    required this.users,
  });

  final String chatId;
  final List<ChatifyUser> users;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: KrStreamBuilder<List<MapEntry<ChatifyUser, ChatStatus>>>(
        key: ValueKey('chat status'),
        stream: Rx.combineLatestList(
          users.withoutMe.map(
            (user) => Chatify.datasource
                .getChatStatus(user.id, chatId)
                .map((e) => MapEntry(user, e)),
          ),
        ),
        onLoading: SizedBox.shrink(),
        builder: (statuses) {
          return KrExpandedSection(
            expand: statuses.any((e) => e.value != ChatStatus.none),
            duration: Duration(milliseconds: 600),
            child: SizedBox(
              height: 35,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutQuad,
                switchOutCurve: Curves.easeInQuad,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      alignment: Alignment.bottomLeft,
                      child: child,
                    ),
                  );
                },
                child: getUserChatStatusWidget(
                  context,
                  statuses,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  getUserChatStatusWidget(
    BuildContext context,
    List<MapEntry<ChatifyUser, ChatStatus>> statuses,
  ) {
    if (statuses.every((e) => e.value == ChatStatus.none))
      return SizedBox.shrink();
    var status = statuses.firstWhere((e) => e.value != ChatStatus.none).value;
    if (statuses.any((e) => e.value == ChatStatus.typing)) {
      status = ChatStatus.typing;
    }
    final users = statuses
        .where((e) => e.value != ChatStatus.none)
        .map((e) => e.key)
        .toList();
    switch (status) {
      case ChatStatus.typing:
        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            key: ValueKey('typing_user_status'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UsersProfile(
                users: users,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Lottie.asset(
                  'assets/lottie/typing.json',
                  package: 'chatify',
                  fit: BoxFit.fitHeight,
                  height: 18,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.color(
                        const ['**'],
                        value: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case ChatStatus.recording:
        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            key: ValueKey('recording_user_status'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UsersProfile(
                users: users,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Transform.scale(
                  scale: 1.4,
                  child: Lottie.asset(
                    'assets/lottie/recording.json',
                    package: 'chatify',
                    fit: BoxFit.fitHeight,
                    height: 30,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(
                          const ['**'],
                          value: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case ChatStatus.sendingMedia:
        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            key: ValueKey('sending_media_user_status'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UsersProfile(
                users: users,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Lottie.asset(
                  'assets/lottie/three_dots.json',
                  package: 'chatify',
                  height: 30,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.color(
                        const ['**'],
                        value: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case ChatStatus.attend:
        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            key: ValueKey('attend_user_status'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UsersProfile(
                users: users,
              ),
            ],
          ),
        );
      case ChatStatus.none:
        return SizedBox(
          key: ValueKey('none_user_status'),
        );
    }
  }
}

class _UsersProfile extends StatelessWidget {
  const _UsersProfile({
    required this.users,
  });

  final List<ChatifyUser> users;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...users.map(
          (e) => Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: CustomImage(
              url: e.profileImage,
              width: 30,
              height: 30,
              radius: 30,
              fit: BoxFit.cover,
              onError: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
