import 'package:chatify/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/message/controllers/voice_controller.dart';
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
      constraints: const BoxConstraints.tightFor(width: 500, height: 61),
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
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (contex, value, child) {
                int s = controller.seconds % 60;
                int m = controller.seconds ~/ 60;
                return Text(
                  '$m:${s < 10 ? '0$s' : s}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ChatifyTheme.of(context).chatBackgroundColor,
                  ),
                );
              },
            ),
          ),
          Icon(
            Icons.arrow_back_ios,
            size: 20,
            color:
                ChatifyTheme.of(context).chatBackgroundColor.withOpacity(0.6),
          ),
          Text(
            'Slide to cancel',
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 16,
              color:
                  ChatifyTheme.of(context).chatBackgroundColor.withOpacity(0.7),
            ),
            maxLines: 1,
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
            width: 16,
            height: 16,
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
