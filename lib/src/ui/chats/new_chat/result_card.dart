import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/utils/extensions.dart';
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
              width: 50,
              height: 50,
              radius: 50,
              fit: BoxFit.cover,
              onError: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.primaries
                          .elementAt(user.name.getPositionOfFirstLetter())
                          .withOpacity(0.6),
                      Colors.primaries
                          .elementAt(user.name.getPositionOfFirstLetter()),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              user.name,
              style: TextStyle(
                color: Chatify.theme.recentChatsForegroundColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
