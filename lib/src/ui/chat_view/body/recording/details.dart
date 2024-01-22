import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';

class ChatRecordDetails extends StatelessWidget {
  const ChatRecordDetails({
    Key? key,
    required this.chat,
    required this.controller,
  }) : super(key: key);
  final Chat chat;
  final VoiceRecordingController controller;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 500, height: 50),
      child: Row(
        children: [
          SizedBox(
            width: 16,
          ),
          RecordingCircle(),
          SizedBox(
            width: 16,
          ),
          SizedBox(
            width: 70,
            child: ValueListenableBuilder<int>(
              valueListenable: controller.seconds,
              builder: (contex, seconds, child) {
                return Text(
                  seconds.toDurationString,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Chatify.theme.chatForegroundColor,
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: controller.isLocked,
            builder: (contex, isLocked, _) {
              if (isLocked) return SizedBox.shrink();
              return Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Chatify.theme.chatForegroundColor.withOpacity(0.6),
                  ),
                  Text(
                    localization(context).slideToCancel,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 16,
                      color: Chatify.theme.chatForegroundColor.withOpacity(0.7),
                    ),
                    maxLines: 1,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class RecordingCircle extends StatefulWidget {
  @override
  _RecordingCircleState createState() => _RecordingCircleState();
}

class _RecordingCircleState extends State<RecordingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
}
