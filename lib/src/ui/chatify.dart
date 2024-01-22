import 'package:chatify/chatify.dart';
import 'package:flutter/material.dart';

class ChatifyWraper extends StatefulWidget {
  const ChatifyWraper({super.key, required this.child, this.theme});

  final Widget child;
  final ChatifyThemeData? theme;

  @override
  State<ChatifyWraper> createState() => _ChatifyWraperState();
}

class _ChatifyWraperState extends State<ChatifyWraper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Chatify.datasource.updateUserStatus(state == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) {
    Chatify.theme = widget.theme ?? ChatifyTheme.of(context);
    return widget.child;
  }
}
