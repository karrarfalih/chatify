import 'package:chatify/src/assets/image.dart';
import 'package:chatify/src/models/models.dart';
import 'package:flutter/material.dart';

class NewMessageCard extends StatelessWidget {
  const NewMessageCard(
      {Key? key,
      required this.user,
      })
      : super(key: key);

  final ChatifyUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: CustomImage(
              url: user.profileImage,
              width: 56,
              height: 56,
              radius: 56,
            ),
          ),
        ],
      ),
    );
  }
}
