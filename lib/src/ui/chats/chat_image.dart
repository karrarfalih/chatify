import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';

class ChatImage extends StatelessWidget {
  const ChatImage({super.key, required this.users, this.imageUrl});

  final List<ChatifyUser> users;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null)
      return UserProfileImage(
        url: imageUrl!,
        firstLetter: users.first.name.substring(0, 1).toUpperCase(),
      );
    if (users.length == 1)
      return UserProfileImage(
        url: users.first.profileImage,
        firstLetter: users.first.name.substring(0, 1).toUpperCase(),
      );
    else {
      return SizedBox(
        height: 50,
        width: 50,
        child: Stack(
          children: [
            PositionedDirectional(
              end: 0,
              top: 0,
              child: UserProfileImage(
                size: 32,
                url: users.first.profileImage,
                firstLetter: users.first.name.substring(0, 1).toUpperCase(),
              ),
            ),
            PositionedDirectional(
              start: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: UserProfileImage(
                  size: 32,
                  url: users[1].profileImage,
                  firstLetter: users[1].name.substring(0, 1).toUpperCase(),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class UserProfileImage extends StatelessWidget {
  const UserProfileImage({
    super.key,
    required this.url,
    required this.firstLetter,
    this.size = 50,
  });
  final String? url;
  final String firstLetter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomImage(
      url: url,
      height: size,
      width: size,
      radius: size,
      fit: BoxFit.cover,
      onError: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.primaries
                  .elementAt(firstLetter.getPositionOfFirstLetter())
                  .withOpacity(0.6),
              Colors.primaries
                  .elementAt(firstLetter.getPositionOfFirstLetter()),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          firstLetter.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: (size / 50) * 26,
          ),
        ),
      ),
    );
  }
}
