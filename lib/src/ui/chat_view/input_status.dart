import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

class UsersInputStatus extends StatefulWidget {
  const UsersInputStatus({
    super.key,
    required this.chatId,
    required this.users,
    required this.child,
  });

  final String chatId;
  final List<ChatifyUser> users;
  final Widget child;

  @override
  State<UsersInputStatus> createState() => _UsersInputStatusState();
}

class _UsersInputStatusState extends State<UsersInputStatus> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KrStreamBuilder<List<MapEntry<ChatifyUser, ChatStatus>>>(
      key: ValueKey('chat status'),
      stream: Rx.combineLatestList(
        widget.users.withoutMe.map(
          (user) => Chatify.datasource
              .getChatStatus(user.id, widget.chatId)
              .map((e) => MapEntry(user, e)),
        ),
      ),
      onEmpty: widget.child,
      onLoading: widget.child,
      builder: (statuses) {
        if (statuses.isEmpty ||
            statuses.every((e) => e.value == ChatStatus.none))
          return widget.child;
        return SizedBox(
          height: 25,
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
        );
      },
    );
  }

  getUserChatStatusWidget(
    BuildContext context,
    List<MapEntry<ChatifyUser, ChatStatus>> statuses,
  ) {
    if (statuses.every((e) => e.value == ChatStatus.none))
      return SizedBox.shrink();
    var status = ChatStatus.none;

    status = statuses.firstWhere((e) => e.value != ChatStatus.none).value;
    if (statuses.any((e) => e.value == ChatStatus.typing)) {
      status = ChatStatus.typing;
    }

    // TODO: Add users names
    // var users = statuses
    //     .where((e) => e.value != ChatStatus.none)
    //     .map((e) => e.key)
    //     .toList();
    final theme = ChatifyTheme.of(context);
    switch (status) {
      case ChatStatus.typing:
        return Row(
          key: ValueKey('typing_user_status'),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              localization(context).typing,
              style: TextStyle(
                color: theme.chatForegroundColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
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
        );
      case ChatStatus.recording:
        return Row(
          key: ValueKey('recording_user_status'),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              localization(context).recording,
              style: TextStyle(
                color: theme.chatForegroundColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: Transform.scale(
                scale: 1.5,
                child: Lottie.asset(
                  'assets/lottie/recording.json',
                  package: 'chatify',
                  fit: BoxFit.fitHeight,
                  height: 25,
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
        );
      case ChatStatus.sendingMedia:
        return Row(
          key: ValueKey('sending_media_user_status'),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              localization(context).sending,
              style: TextStyle(
                color: theme.chatForegroundColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              child: Transform.scale(
                scale: 1.3,
                child: Lottie.asset(
                  'assets/lottie/three_dots.json',
                  package: 'chatify',
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
        );
      default:
        return SizedBox(
          key: ValueKey('none_user_status'),
        );
    }
  }
}
