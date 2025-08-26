import 'package:chatify/src/view/common/expanded_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:chatify/src/view/chat/bloc/bloc.dart';
import 'package:chatify/src/view/chat/view/message/widgets/bubble.dart';
import 'package:chatify/src/domain/models/chat.dart';

class ChatStatusWidget extends StatelessWidget {
  const ChatStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MessagesBloc, MessagesState, ChatStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          return ExpandedSection(
            expand: status != ChatStatus.none,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: MessageBubble(
                  isFirst: true,
                  isLast: true,
                  isMine: false,
                  isError: false,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: switch (status) {
                      ChatStatus.typing => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          child: Lottie.asset(
                            'assets/typing.json',
                            package: 'chatify',
                            fit: BoxFit.fitHeight,
                            height: 18,
                            delegates: LottieDelegates(
                              values: [
                                ValueDelegate.color(
                                  const ['**'],
                                  value: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ChatStatus.recording => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Transform.scale(
                            scale: 1.5,
                            child: Lottie.asset(
                              'assets/recording.json',
                              package: 'chatify',
                              fit: BoxFit.fitHeight,
                              height: 25,
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.color(
                                    const ['**'],
                                    value: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ChatStatus.sendingMedia => Container(
                          key: const ValueKey('sending_media_user_status'),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.scale(
                            scale: 1.3,
                            child: Lottie.asset(
                              'assets/three_dots.json',
                              package: 'chatify',
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.color(
                                    const ['**'],
                                    value: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      _ => const SizedBox.shrink(
                          key: ValueKey('none_user_status'),
                        )
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }
}
