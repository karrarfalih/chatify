import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/send_at.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/utils.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:chatify/src/ui/common/rotated_widget.dart';
import 'package:chatify/src/utils/storage_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import './noises.dart';

class VoiceMessageWidget extends StatefulWidget {
  const VoiceMessageWidget({
    Key? key,
    required this.user,
    required this.meBgColor,
    this.contactBgColor = const Color(0xffffffff),
    required this.contactFgColor,
    this.mePlayIconColor = Colors.black,
    this.contactPlayIconColor = Colors.black26,
    this.meFgColor = const Color(0xffffffff),
    this.onSeek,
    required this.message,
    required this.chatController,
    required this.width,
  }) : super(key: key);

  final Color meBgColor,
      meFgColor,
      contactBgColor,
      contactFgColor,
      mePlayIconColor,
      contactPlayIconColor;
  final Function()? onSeek;
  final String user;
  final VoiceMessage message;
  final ChatController chatController;
  final double width;

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget>
    with TickerProviderStateMixin {
  late final VoicePlayerController player;
  late final double maxNoiseHeight, noiseWidth;
  double maxDurationForSlider = .0000001;
  late final VoiceMessage message;
  late final bool isMe;
  late final UploadAttachment? attachment;

  @override
  void initState() {
    width = widget.width;
    maxNoiseHeight = 6.w();
    noiseWidth = 25.w();
    message = widget.message;
    isMe = message.isMine;
    attachment = message.uploadAttachment;
    player = VoicePlayerController(
      message: message,
      user: widget.user,
    );

    player.playPauseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: player.player.playing ? 1 : 0,
    );
    player.progressController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: noiseWidth,
      duration: Duration(
        seconds: (player.seconds ~/ VoicePlayerController.speed.value) + 1,
      ),
      value: (player.lastPositionInSeconds / player.seconds) * noiseWidth,
    );
    if (player.player.playing) {
      player.progressController!
          .forward()
          .then((value) => player.progressController!.reset());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        constraints: BoxConstraints(maxWidth: 70.w()),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _playButton(context),
                  const SizedBox(width: 8),
                  _durationWithNoise(context),
                  const SizedBox(width: 8),
                ],
              ),
              SendAtWidget(
                message: message,
                isSending: message.uploadAttachment != null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _playButton(BuildContext context) => InkWell(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMe ? widget.meFgColor : widget.contactFgColor,
          ),
          width: 40,
          height: 40,
          child: InkWell(
            onTap: () async {
              if (attachment != null) {
                attachment!.cancel();
              }
              if (!player.isReady!.value) {
                await player.init();
              }
              player.togglePlay();
            },
            child: ValueListenableBuilder<VoiceStatus>(
              valueListenable: player.status,
              builder: (context, status, child) {
                if (attachment != null) {
                  return GestureDetector(
                    onTap: () {
                      attachment!.cancel();
                      widget.chatController.pendingMessages.value
                          .remove(message);
                      widget.chatController.pendingMessages.refresh();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedRotatingWidget(
                          duration: Duration(milliseconds: 3000),
                          child: KrStreamBuilder<TaskSnapshot>(
                            stream: attachment!.task.snapshotEvents,
                            onLoading: Container(
                              padding: EdgeInsets.all(4),
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 2.5,
                                color: isMe
                                    ? widget.meBgColor
                                    : widget.contactBgColor,
                              ),
                            ),
                            builder: (snapshot) {
                              return Container(
                                padding: EdgeInsets.all(4),
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: snapshot.bytesTransferred /
                                      snapshot.totalBytes,
                                  strokeWidth: 2.5,
                                  color: isMe
                                      ? widget.meBgColor
                                      : widget.contactBgColor,
                                ),
                              );
                            },
                          ),
                        ),
                        Icon(Icons.close_rounded),
                      ],
                    ),
                  );
                }
                if (status == VoiceStatus.downloading) {
                  return GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTap: player.cancel,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedRotatingWidget(
                          duration: Duration(milliseconds: 3000),
                          child: ValueListenableBuilder<double>(
                            valueListenable: player.progress,
                            builder: (context, progress, child) {
                              return Container(
                                padding: EdgeInsets.all(4),
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2.5,
                                  color: isMe
                                      ? widget.meBgColor
                                      : widget.contactBgColor,
                                ),
                              );
                            },
                          ),
                        ),
                        Icon(Icons.close_rounded),
                      ],
                    ),
                  );
                }
                if (status == VoiceStatus.loading) {
                  return Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                              isMe ? widget.meBgColor : widget.contactBgColor,
                        ),
                      ),
                      Center(child: Icon(Icons.close_rounded)),
                    ],
                  );
                }
                if (status == VoiceStatus.dowload) {
                  return Center(child: Icon(Icons.download_sharp));
                }
                return Center(
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: player.playPauseController!,
                    color: isMe
                        ? widget.mePlayIconColor
                        : widget.contactPlayIconColor,
                    size: 22,
                  ),
                );
              },
            ),
          ),
        ),
      );

  _durationWithNoise(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _noise(context),
          SizedBox(height: 1.w()),
          Row(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: player.remainingTime!,
                builder: (context, remainingTime, child) {
                  return Text(
                    remainingTime,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? widget.meFgColor : widget.contactFgColor,
                    ),
                  );
                },
              ),
              Visibility(
                visible: !message.isPlayed,
                child: Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMe ? widget.meFgColor : widget.contactFgColor,
                  ),
                  width: 1.4.w(),
                  height: 1.4.w(),
                ),
              )
            ],
          ),
        ],
      );

  _noise(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final newTHeme = theme.copyWith(
      sliderTheme: SliderThemeData(
        trackShape: CustomTrackShape(),
        thumbShape: SliderComponentShape.noThumb,
        minThumbSeparation: 0,
      ),
    );
    final count = (50 * noiseWidth ~/ 50.w());
    return Theme(
      data: newTHeme,
      child: SizedBox(
        height: 15,
        width: noiseWidth,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Noises(
              count: count,
              isMe: isMe,
              samples: message.samples,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: player.isReady!,
              builder: (context, isReady, child) {
                if (isReady)
                  return AnimatedBuilder(
                    animation: CurvedAnimation(
                      parent: player.progressController!,
                      curve: Curves.ease,
                    ),
                    builder: (context, child) {
                      return Positioned(
                        left: player.progressController!.value,
                        child: child!,
                      );
                    },
                    child: Container(
                      width: noiseWidth,
                      height: 6.w(),
                      color: isMe
                          ? widget.meBgColor.withOpacity(.6)
                          : widget.contactBgColor.withOpacity(.6),
                    ),
                  );
                else if (message.isPlayed) {
                  return Container(
                    width: noiseWidth,
                    height: 6.w(),
                    color: isMe
                        ? widget.meBgColor.withOpacity(.6)
                        : widget.contactBgColor.withOpacity(.6),
                  );
                } else
                  return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// document will be added
class CustomTrackShape extends RoundedRectSliderTrackShape {
  /// document will be added
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 10;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

String doubleToString(double value) {
  String stringValue = value.toString();
  if (value == value.toInt()) {
    return value.toInt().toString();
  }
  if (stringValue.endsWith('0')) {
    stringValue = stringValue.substring(0, stringValue.length - 1);
  }

  return stringValue;
}
