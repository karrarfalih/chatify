import 'package:chatify/src/ui/chat_view/message/widgets/voice/controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/utils.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import './noises.dart';

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({
    Key? key,
    required this.audioSrc,
    required this.user,
    required this.me,
    required this.sendAtWidget,
    required this.meBgColor,
    required this.sendAt,
    this.contactBgColor = const Color(0xffffffff),
    required this.contactFgColor,
    this.mePlayIconColor = Colors.black,
    this.contactPlayIconColor = Colors.black26,
    this.meFgColor = const Color(0xffffffff),
    this.played = false,
    this.onPlay,
    this.onSeek,
    required this.height,
    required this.width,
    required this.duration,
    this.isLoading = false,
  }) : super(key: key);

  final String audioSrc;
  final Color meBgColor,
      meFgColor,
      contactBgColor,
      contactFgColor,
      mePlayIconColor,
      contactPlayIconColor;
  final bool played, me;
  final Function()? onPlay;
  final double height;
  final double width;
  final Duration duration;
  final bool isLoading;
  final Widget sendAtWidget;
  final Function()? onSeek;
  final DateTime sendAt;
  final String user;

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage>
    with TickerProviderStateMixin {
  late final VoicePlayerController player;
  late final double maxNoiseHeight, noiseWidth;
  double maxDurationForSlider = .0000001;

  @override
  void initState() {
    player = VoicePlayerController(
      url: widget.audioSrc,
      seconds: widget.duration.inSeconds,
      isMe: widget.me,
      sendAt: widget.sendAt,
      user: widget.user,
    );
    width = widget.width;
    height = widget.height;
    maxNoiseHeight = 6.w();
    noiseWidth = ((player.seconds / 30).withRange(0.2, 1) * 40).w() + 10.w();
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
  void dispose() {
    player.disposeControllers();
    super.dispose();
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
              widget.sendAtWidget,
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
            color: widget.me ? widget.meFgColor : widget.contactFgColor,
          ),
          width: 40,
          height: 40,
          child: InkWell(
            onTap: () async {
              if (!player.isReady!.value) {
                await player.init();
              }
              player.togglePlay();
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: player.isLoading!,
              builder: (context, isLoading, child) {
                return isLoading
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        width: 10,
                        height: 0,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: widget.me
                              ? widget.meBgColor
                              : widget.contactBgColor,
                        ),
                      )
                    : Center(
                        child: AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          progress: player.playPauseController!,
                          color: widget.me
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
          SizedBox(height: .3.w()),
          Row(
            children: [
              if (!widget.played) ...[
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.me ? widget.meFgColor : widget.contactFgColor,
                  ),
                  width: 1.w(),
                  height: 1.w(),
                )
              ],
              ValueListenableBuilder<String>(
                valueListenable: player.remainingTime!,
                builder: (context, remainingTime, child) {
                  return Text(
                    remainingTime,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          widget.me ? widget.meFgColor : widget.contactFgColor,
                    ),
                  );
                },
              ),
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
            widget.me
                ? Noises(
                    count: count,
                    isMe: true,
                  )
                : Noises(
                    count: count,
                    isMe: false,
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
                      color: widget.me
                          ? widget.meBgColor.withOpacity(.4)
                          : widget.contactBgColor.withOpacity(
                              !widget.played ? 0 : .35,
                            ),
                    ),
                  );
                else if (widget.played)
                  return Container(
                    width: noiseWidth,
                    height: 6.w(),
                    color: widget.me
                        ? widget.meBgColor.withOpacity(.4)
                        : widget.contactBgColor.withOpacity(
                            !widget.played ? 0 : .35,
                          ),
                  );
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
