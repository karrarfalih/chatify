import 'package:chat/models/user.dart';
import 'package:chat/ui/common/user_image.dart';
import 'package:flutter/material.dart';

class NewMessageCard extends StatelessWidget {
  const NewMessageCard(
      {Key? key,
      required this.user,
      required this.onPressed,
      this.actionButton})
      : super(key: key);

  final ChatUser user;
  final Function() onPressed;
  final Widget Function(ChatUser)? actionButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: IgnorePointer(
              ignoring: actionButton != null,
              child: UserAvatar(uid: user.id, width: 56, height: 56, onTap: (e) async {
                await onPressed();
              },),
            ),
          ),
          if (actionButton != null) actionButton!(user)
        ],
      ),
    );
  }
}
