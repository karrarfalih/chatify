import 'package:chatify/src/voice_player/src/contact_noise.dart';
import 'package:chatify/src/voice_player/src/helpers/utils.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:just_audio/just_audio.dart' as jsAudio;
import './helpers/widgets.dart';
import './noises.dart';
import 'duration.dart';
import 'helpers/colors.dart';

jsAudio.AudioPlayer? currentPlayer;

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({
    Key? key,
    required this.audioSrc,
    required this.me,
    required this.sendAt,
    this.meBgColor = AppColors.pink,
    this.contactBgColor = const Color(0xffffffff),
    this.contactFgColor = AppColors.pink,
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
  final Widget sendAt;
  final Function()? onSeek;

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage>
    with SingleTickerProviderStateMixin {
  final jsAudio.AudioPlayer player = jsAudio.AudioPlayer();
  double maxNoiseHeight = 6.w(), noiseWidth = 26.5.w();
  double maxDurationForSlider = .0000001;
  bool _isPlaying = false, x2 = false, _audioConfigurationDone = false;
  double duration = 00;
  String _remainingTime = '';
  AnimationController? _controller;
  bool isPlayed = false;
  bool isFinished = false;

  @override
  void initState() {
    width = widget.width;
    height = widget.height;
    maxNoiseHeight = 6.w();
    noiseWidth = 26.5.w();
    if (!widget.isLoading) _setDuration();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _sizerChild(context);
  Widget _sizerChild(BuildContext context) {
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _speed(context),
                  )
                ],
              ),
              widget.sendAt,
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
            onTap: () => !_audioConfigurationDone ? null : togglePlay(),
            child: !_audioConfigurationDone
                ? Container(
                    padding: const EdgeInsets.all(14),
                    width: 10,
                    height: 0,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color:
                          widget.me ? widget.meBgColor : widget.contactBgColor,
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.me
                        ? widget.mePlayIconColor
                        : widget.contactPlayIconColor,
                    size: 22,
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
                Widgets.circle(context, 1.w(),
                    widget.me ? widget.meFgColor : widget.contactFgColor),
                const SizedBox(
                  width: 5,
                ),
              ],
              Text(
                _remainingTime,
                style: TextStyle(
                  fontSize: 10,
                  color: widget.me ? widget.meFgColor : widget.contactFgColor,
                ),
              ),
            ],
          ),
        ],
      );

  /// Noise widget of audio.
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
            widget.me ? const Noises() : const ContactNoise(),
            if (_audioConfigurationDone)
              AnimatedBuilder(
                animation:
                    CurvedAnimation(parent: _controller!, curve: Curves.ease),
                builder: (context, child) {
                  return Positioned(
                    left: _controller!.value,
                    child: Container(
                      width: noiseWidth,
                      height: 6.w(),
                      color: widget.me
                          ? widget.meBgColor.withOpacity(.4)
                          : widget.contactBgColor.withOpacity(
                              !widget.played && !isPlayed ? 0 : .35),
                    ),
                  );
                },
              ),
            Opacity(
              opacity: .0,
              child: Container(
                width: noiseWidth,
                color: Colors.amber.withOpacity(1),
                child: Slider(
                  min: 0.0,
                  max: maxDurationForSlider,
                  onChangeStart: (__) => _stopPlaying(),
                  onChangeEnd: (_) => _startPlaying(),
                  onChanged: (_) => _onChangeSlider(_),
                  value: duration + .0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _speed(BuildContext context) => InkWell(
        onTap: () => _toggle2x(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 3.w(), vertical: 1.6.w()),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.8.w()),
            color: (widget.me ? widget.meFgColor : widget.contactFgColor)
                .withOpacity(.28),
          ),
          width: 9.8.w(),
          child: Text(
            !x2 ? '1X' : '2X',
            style: TextStyle(
                fontSize: 9.8,
                color: (widget.me ? widget.meFgColor : Colors.black)),
          ),
        ),
      );

  void togglePlay() async {
    if (!_isPlaying && widget.onPlay != null) widget.onPlay!();
    _isPlaying ? _stopPlaying() : _startPlaying();
  }

  _startPlaying() async {
    if (!isPlayed) {
      _listenToRemainingTime();
      isPlayed = true;
    }
    player.play().then((value) {
      player.pause();
      player.seek(Duration.zero);
      setState(() => _isPlaying = false);
    });
    setState(() {
      _isPlaying = true;
    });
    _controller!.forward();
  }

  _stopPlaying() async {
    player.pause();
    _controller!.stop();
    isFinished = false;
  }

  void _setDuration() async {
    if (currentPlayer != null) currentPlayer!.pause();
    currentPlayer = player;
    await player.setUrl(widget.audioSrc);
    duration = widget.duration.inSeconds.toDouble();
    maxDurationForSlider = duration;

    /// document will be added
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: noiseWidth,
      duration: Duration(seconds: duration.toInt() + 1),
    );

    /// document will be added
    _controller!.addListener(() {
      if (_controller!.isCompleted) {
        _controller!.reset();
        isFinished = true;
      }
    });
    _remainingTime = VoiceDuration.getDuration(duration.toInt());
    setState(() => _audioConfigurationDone = true);
  }

  void _toggle2x() {
    x2 = !x2;
    _controller!.duration =
        Duration(seconds: x2 ? duration ~/ 2 : duration.toInt());
    if (_controller!.isAnimating) _controller!.forward();
    player.setSpeed(x2 ? 2 : 1);
    setState(() {});
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _listenToRemainingTime() {
    player.createPositionStream().listen((p) {
      final _newRemaingTime1 = p.toString().split('.')[0];
      final _newRemaingTime2 =
          _newRemaingTime1.substring(_newRemaingTime1.length - 5);
      if (_newRemaingTime2 != _remainingTime) {
        setState(() => _remainingTime = _newRemaingTime2);
      }
    });
  }

  /// document will be added
  _onChangeSlider(double d) async {
    if (_isPlaying) togglePlay();
    duration = widget.me ? maxDurationForSlider - d : d;
    _controller?.value = (noiseWidth) * duration / maxDurationForSlider;
    // _remainingTime = VoiceDuration.getDuration(duration.toInt());
    if (widget.onSeek != null) widget.onSeek!();
    setState(() {});
    player.seek(Duration(seconds: duration.toInt()));
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
