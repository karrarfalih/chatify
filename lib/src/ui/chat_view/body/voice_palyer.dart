import 'dart:ui';

import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/voice_message.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:chatify/src/utils/colors_utils.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CurrentVoicePlayer extends StatefulWidget {
  const CurrentVoicePlayer({super.key});

  @override
  State<CurrentVoicePlayer> createState() => _CurrentVoicePlayerState();
}

class _CurrentVoicePlayerState extends State<CurrentVoicePlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController playPauseController;

  @override
  void initState() {
    playPauseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder<VoicePlayerController?>(
      valueListenable: VoicePlayerController.currentPlayer,
      builder: (context, player, child) {
        player?.playPauseController?.addListener(() {
          if (VoicePlayerController.currentPlayer.value?.player.playing ??
              false) {
            playPauseController.forward();
          } else {
            playPauseController.reverse();
          }
        });

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 170),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
          child: player == null
              ? SizedBox.shrink(
                  key: ValueKey('empty_player'),
                )
              : ClipRRect(
                  key: ValueKey('floating_player'),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 20,
                              sigmaY: 20,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Row(
                            children: [
                              KrStreamBuilder<Duration>(
                                stream: player.player.positionStream,
                                builder: (duration) {
                                  player.updateRemainingTime(duration);
                                  final w = (screenWidth *
                                          (duration.inMilliseconds /
                                              (player.player.duration
                                                      ?.inMilliseconds ??
                                                  (player.seconds * 1000))))
                                      .withRange(0, screenWidth);
                                  return Container(
                                    color: Colors.black38,
                                    width: w.isNaN || w.isInfinite ? 0 : w,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.maxFinite,
                        color: Chatify.theme.primaryColor
                            .darken(0.6)
                            .withOpacity(0.7),
                        height: 35,
                        child: Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              onPressed: player.togglePlay,
                              icon: AnimatedIcon(
                                icon: AnimatedIcons.play_pause,
                                progress: playPauseController,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            Text(
                              player.user,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1,
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            if (player.message.sendAt != null)
                              Text(
                                player.message.sendAt!
                                        .format(context, 'MMM EEE') +
                                    ' at ' +
                                    player.message.sendAt!
                                        .format(context, 'h:mm a'),
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  height: 1,
                                ),
                              ),
                            Spacer(),
                            InkWell(
                              onTap: player.toggleSpeed,
                              child: ValueListenableBuilder<double>(
                                valueListenable: VoicePlayerController.speed,
                                builder: (context, speed, child) {
                                  return AnimatedContainer(
                                    key: ValueKey('speed_button'),
                                    duration: Duration(milliseconds: 200),
                                    height: 22,
                                    alignment: Alignment.center,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      color: speed != 1 ? Colors.white : null,
                                    ),
                                    child: Text(
                                      doubleToString(speed) + 'X',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: speed != 1
                                            ? Chatify.theme.primaryColor
                                            : Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              onPressed: () {
                                player.stopPlaying();
                                VoicePlayerController.currentPlayer.value =
                                    null;
                              },
                              icon: Icon(
                                Iconsax.close_circle,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
