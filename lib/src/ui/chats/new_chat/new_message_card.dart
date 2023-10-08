import 'package:chatify/src/assets/image.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:flutter/material.dart';

class NewMessageCard extends StatelessWidget {
  const NewMessageCard({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  final ChatifyUser user;
  final Function(ChatifyUser) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            CustomImage(
              url: user.profileImage,
              width: 56,
              height: 56,
              radius: 56,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              user.name,
              style: TextStyle(
                color: ChatifyTheme.of(context).recentChatsBackgroundColor,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
