import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:chatify/src/view/chat/bloc/bloc.dart';
import 'package:chatify/src/domain/models/messages/message.dart';

class SwipeToReply extends StatelessWidget {
  const SwipeToReply({
    super.key,
    required this.message,
    required this.child,
  });

  final Message message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SwipeableTile.swipeToTrigger(
      behavior: HitTestBehavior.translucent,
      isElevated: false,
      color: Colors.transparent,
      swipeThreshold: 0.2,
      direction: message.isMine
          ? SwipeDirection.startToEnd
          : SwipeDirection.endToStart,
      onSwiped: (direction) {
        context.read<MessagesBloc>().add(MessageReply(message));
      },
      backgroundBuilder: (context, direction, progress) {
        bool triggered = false;
        return AnimatedBuilder(
          animation: progress,
          builder: (_, __) {
            if (progress.value > 0.9999 && !triggered) {
              triggered = true;
            }
            if (progress.value < 0.2) {
              return const SizedBox();
            }
            return Container(
              alignment: message.isMine
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 6.0,
                  end: 6,
                ),
                child: Animate(
                  effects: const [
                    FadeEffect(),
                    ScaleEffect(),
                  ],
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Transform.flip(
                            flipX: true,
                            child: Icon(
                              Icons.reply,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      if (progress.value < 1 && !triggered)
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            value: progress.value,
                            strokeWidth: 2,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                          ),
                        )
                      else
                        Animate(
                          effects: const [
                            ScaleEffect(
                              curve: Curves.easeOutBack,
                              duration: Duration(milliseconds: 400),
                            ),
                          ],
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      // confirmSwipe: (direction) async => false,
      key: ValueKey('dismissible-${message.content.id}'),
      child: child,
    );
  }
}
