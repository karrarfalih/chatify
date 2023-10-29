import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/send_at.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/controller.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:chatify/src/ui/common/rotated_widget.dart';
import 'package:chatify/src/utils/storage_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
  late final double noiseWidth;
  double maxDurationForSlider = .0000001;
  late final VoiceMessage message;
  late final bool isMe;
  late final UploadAttachment? attachment;
  late final AnimationController playPauseController;
  late final AnimationController progressController;

  @override
  void initState() {
    noiseWidth = 110;
    message = widget.message;
    isMe = message.isMine;
    attachment = message.uploadAttachment;
    player = VoicePlayerController(
      message: message,
      user: widget.user,
    );

    playPauseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: player.player.playing ? 1 : 0,
    );
    progressController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: noiseWidth,
      duration: Duration(
        milliseconds:
            (player.milliseconds ~/ VoicePlayerController.speed.value),
      ),
      value: (player.lastPositionInMilliSeconds / player.milliseconds) *
          noiseWidth,
    );
    player.playPauseController = playPauseController;
    player.progressController = progressController;
    if (player.player.playing) {
      player.progressController!
          .forward()
          .then((value) => player.progressController!.reset());
    }
    super.initState();
  }

  @override
  void dispose() {
    playPauseController.dispose();
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        constraints: BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 0, top: 8),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _playButton(context),
                        const SizedBox(width: 6),
                        Align(
                          alignment: AlignmentDirectional.bottomEnd,
                          child: _durationWithNoise(context),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                right: 10,
                child: SendAtWidget(
                  message: message,
                  isSending: message.uploadAttachment != null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _playButton(BuildContext context) => InkWell(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: OverflowBox(
                  minWidth: 65,
                  minHeight: 65,
                  maxHeight: 65,
                  maxWidth: 65,
                  child: KrStreamBuilder<bool>(
                    stream: player.player.playingStream,
                    builder: (playing) {
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 1000),
                        child: !playing
                            ? SizedBox(
                                width: 65,
                                height: 65,
                                key: ValueKey('not-playing${message.id}'),
                              )
                            : Lottie.asset(
                                'assets/lottie/playing.json',
                                key: ValueKey('playing${message.id}'),
                                package: 'chatify',
                                fit: BoxFit.cover,
                                height: 65,
                                delegates: LottieDelegates(
                                  values: [
                                    ValueDelegate.color(
                                      const ['**'],
                                      value: isMe
                                          ? widget.meFgColor
                                          : widget.contactFgColor,
                                    ),
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
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
                child: Stack(
                  children: [
                    ValueListenableBuilder<VoiceStatus>(
                      valueListenable: player.status,
                      builder: (context, status, child) {
                        final color =
                            isMe ? widget.meBgColor : widget.contactBgColor;
                        if (attachment != null) {
                          return GestureDetector(
                            onTap: () {
                              attachment!.cancel();
                              widget.chatController.pending.remove(message);
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
                                        color: color,
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
                                          color: color,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.close_rounded,
                                  color: color,
                                ),
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
                                          color: color,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.close_rounded,
                                  color: color,
                                ),
                              ],
                            ),
                          );
                        }
                        if (status == VoiceStatus.loading) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: color,
                                ),
                              ),
                              Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  color: color,
                                ),
                              ),
                            ],
                          );
                        }
                        if (status == VoiceStatus.dowload) {
                          return Center(
                            child: Icon(
                              Icons.download_sharp,
                              color: color,
                            ),
                          );
                        }
                        return Center(
                          child: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: player.playPauseController!,
                            color: color,
                            size: 22,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  _durationWithNoise(BuildContext context) => SizedBox(
        width: noiseWidth + 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 6),
            _noise(context),
            SizedBox(height: 4),
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
                    width: 5,
                    height: 5,
                  ),
                ),
              ],
            ),
          ],
        ),
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
    return Theme(
      data: newTHeme,
      child: SizedBox(
        height: 15,
        width: noiseWidth,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Noises(
              count: 30,
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
                      height: 15,
                      color: isMe
                          ? widget.meBgColor.withOpacity(.6)
                          : widget.contactBgColor.withOpacity(.6),
                    ),
                  );
                else if (message.isPlayed) {
                  return Container(
                    width: noiseWidth,
                    height: 15,
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

class CustomTrackShape extends RoundedRectSliderTrackShape {
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
