import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/ui/chats/search/search.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatSearch extends StatelessWidget {
  const ChatSearch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Chatify.theme;
    return Container(
      height: 55,
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: SizedBox(
        height: 48,
        child: TextButton(
          onPressed: () {
            Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.recentChatsForegroundColor.withOpacity(0.05),
            padding: EdgeInsets.zero,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Iconsax.search_normal,
                  size: 18,
                  color: theme.recentChatsForegroundColor.withOpacity(0.5),
                ),
              ),
              Text(
                localization(context).search,
                style: TextStyle(
                  color: theme.recentChatsForegroundColor.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
