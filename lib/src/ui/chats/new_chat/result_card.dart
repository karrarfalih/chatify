import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:flutter/material.dart';

class UserResultCard extends StatelessWidget {
  const UserResultCard({
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
              fit: BoxFit.cover,
              onError: const Icon(Icons.person, color: Colors.grey),
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
