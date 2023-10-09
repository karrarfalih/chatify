import 'package:chatify/src/theme/theme_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatSearch extends StatelessWidget {
  const ChatSearch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ChatifyTheme.of(context);
    return Container(
      height: 55,
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: SizedBox(
        height: 48,
        child: TextFormField(
          style: TextStyle(),
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.bottom,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search',
            enabled: true,
            hintStyle: TextStyle(
              color: theme.recentChatsForegroundColor.withOpacity(0.5),
            ),
            isDense: true,
            filled: true,
            fillColor: theme.recentChatsForegroundColor.withOpacity(0.05),
            prefixIcon: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Iconsax.search_normal,
                  color: theme.recentChatsForegroundColor.withOpacity(0.7),
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.recentChatsForegroundColor.withOpacity(0.1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
