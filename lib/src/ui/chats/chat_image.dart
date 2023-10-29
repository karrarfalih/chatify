import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/common/image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatImage extends StatelessWidget {
  const ChatImage({super.key, required this.users, this.imageUrl});

  final List<ChatifyUser> users;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) return UserprofileImage(url: imageUrl!);
    if (users.length == 1)
      return UserprofileImage(
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
              child: UserprofileImage(
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
                child: UserprofileImage(
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

class UserprofileImage extends StatelessWidget {
  const UserprofileImage(
      {super.key, required this.url, this.firstLetter, this.size = 50});
  final String? url;
  final String? firstLetter;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Chatify.theme.primaryColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            firstLetter!,
            style: TextStyle(
              color: Colors.white,
              fontSize: size / 2,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      );
    }
    return CustomImage(
      url: url,
      height: size,
      width: size,
      radius: size,
      fit: BoxFit.cover,
      onError: const Icon(Icons.person, color: Colors.grey),
    );
  }
}
