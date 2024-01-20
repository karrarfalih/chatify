import 'dart:async';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/cupertino.dart';

class TimerRefresher extends StatefulWidget {
  const TimerRefresher({
    super.key,
    required this.lastSeen,
    required this.isActive,
  });

  final DateTime? lastSeen;
  final bool isActive;

  @override
  State<TimerRefresher> createState() => _TimerRefresherState();
}

class _TimerRefresherState extends State<TimerRefresher> {
  Timer? timer;

  initTimer() async {
    timer?.cancel();
    if (widget.lastSeen == null || widget.isActive) return;
    await Future.delayed(
      Duration(seconds: widget.lastSeen!.second - DateTime.now().second),
    );
    if (mounted) setState(() {});
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    initTimer();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initTimer();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.isActive
          ? localization(context).online
          : widget.lastSeen == null
              ? localization(context).lastSeenLongTime
              : widget.lastSeen!.agoLocalized(context),
      style: TextStyle(
        color: Chatify.theme.chatForegroundColor.withOpacity(
              widget.isActive ? 1 : 0.5,
            ),
        fontSize: 11,
        height: 1,
      ),
    );
  }
}
