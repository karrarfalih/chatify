import 'dart:async';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/utils.dart';
import 'package:chatify/src/utils/cache.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoicePlayerController {
  final String url;
  final int seconds;
  final bool isMe;
  final String user;
  final DateTime sendAt;

  factory VoicePlayerController({
    required String url,
    required int seconds,
    required bool isMe,
    required String user,
    required DateTime sendAt,
  }) {
    final instance = _cache.putIfAbsent(
      url,
      () => VoicePlayerController._(
        url: url,
        seconds: seconds,
        isMe: isMe,
        sendAt: sendAt,
        user: user,
      ),
    );
    if (instance.isLoading == null)
      instance.isLoading = (instance.wasLoading ?? false).obs;
    if (instance.isReady == null)
      instance.isReady = (instance.wasReady ?? false).obs;
    if (instance.remainingTime == null)
      instance.remainingTime =
          (instance.latsRemainingTime ?? VoiceDuration.getDuration(seconds))
              .obs;
    return instance;
  }

  VoicePlayerController._({
    required this.url,
    required this.seconds,
    required this.isMe,
    required this.user,
    required this.sendAt,
  });

  final player = AudioPlayer();

  static final currentPlayer = Rx<VoicePlayerController?>(null);
  static final _cache = <String, VoicePlayerController>{};
  static final speed =
      (Cache.instance.getDouble('voice_player_speed') ?? 1).obs;

  Rx<String>? remainingTime;
  String? latsRemainingTime;
  double maxNoiseHeight = 6.w(), noiseWidth = 26.5.w();
  double maxDurationForSlider = .0000001;
  Rx<bool>? isReady;
  bool? wasReady;
  Rx<bool>? isLoading;
  bool? wasLoading;

  bool isFinished = false;
  AnimationController? progressController;
  AnimationController? playPauseController;
  int lastPositionInSeconds = 0;
  StreamSubscription<Duration>? _durationListener;

  Future<void> init() async {
    if (isReady!.value || isLoading!.value) return;
    isLoading!.value = true;
    try {
      await player.setUrl(url);
      if (player.speed != speed.value) player.setSpeed(speed.value);
      maxDurationForSlider = seconds.toDouble();
      listenToRemainingTime();
      progressController?.addListener(() {
        if (progressController?.isCompleted ?? false) {
          progressController?.reset();
          isFinished = true;
        }
      });
      isReady!.value = true;
    } catch (_) {
      print(_);
    }
    isLoading!.value = false;
  }

  void togglePlay() async {
    player.playing ? stopPlaying() : _startPlaying();
  }

  bool _preventAutoPause = false;

  _startPlaying() async {
    if (currentPlayer.value != this) {
      currentPlayer.value?._preventAutoPause = true;
      currentPlayer.value?.stopPlaying();
      currentPlayer.value = this;
    }
    _preventAutoPause = false;
    playPauseController?.forward();
    player.play().then((value) {
      if (_preventAutoPause) return;
      playPauseController?.reverse();
      player.pause();
      player.seek(Duration.zero);
      progressController?.reset();
      currentPlayer.value = null;
    });
    progressController?.forward();
  }

  stopPlaying() async {
    _preventAutoPause = true;
    playPauseController?.reverse();
    player.pause();
    progressController?.stop();
    isFinished = false;
  }

  void listenToRemainingTime() {
    if (_durationListener != null) return;
    _durationListener = player.createPositionStream().listen((p) {
      final _newRemaingTime1 = p.toString().split('.')[0];
      final _newRemaingTime2 =
          _newRemaingTime1.substring(_newRemaingTime1.length - 5);
      if (_newRemaingTime2 != remainingTime?.value) {
        remainingTime?.value = _newRemaingTime2;
        lastPositionInSeconds = p.inSeconds;
      }
    });
  }

  updateRemainingTime(Duration currentDuration) {
    final _newRemaingTime1 = currentDuration.toString().split('.')[0];
    final _newRemaingTime2 =
        _newRemaingTime1.substring(_newRemaingTime1.length - 5);
    if (_newRemaingTime2 != remainingTime?.value) {
      lastPositionInSeconds = currentDuration.inSeconds;
      latsRemainingTime = remainingTime?.value;
    }
  }

  onChangeSlider(double d) async {
    if (player.playing) togglePlay();
    final duration = isMe ? maxDurationForSlider - d : d;
    progressController?.value = (noiseWidth) * duration / maxDurationForSlider;
    remainingTime?.value = VoiceDuration.getDuration(duration.toInt());
    player.seek(Duration(seconds: duration.toInt()));
  }

  void toggleSpeed() {
    if (speed.value == 1)
      speed.value = 1.5;
    else if (speed.value == 1.5)
      speed.value = 2;
    else if (speed.value == 2) speed.value = 1;

    progressController!.duration = Duration(seconds: seconds ~/ speed.value);
    if (progressController!.isAnimating) progressController!.forward();
    player.setSpeed(speed.value);
    Cache.instance.setDouble('voice_player_speed', speed.value);
  }

  disposeControllers() {
    progressController?.dispose();
    progressController = null;
    playPauseController?.dispose();
    playPauseController = null;
    _durationListener?.cancel();
    _durationListener = null;
    latsRemainingTime = remainingTime?.value;
    remainingTime?.dispose();
    remainingTime = null;
    wasReady = isReady!.value;
    isReady?.dispose();
    isReady = null;
    wasLoading = isLoading!.value;
    isLoading?.dispose();
    isLoading = null;
  }
}
