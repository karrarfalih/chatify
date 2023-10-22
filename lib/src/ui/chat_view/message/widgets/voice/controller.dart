import 'dart:async';
import 'dart:io';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/cache.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/utils.dart';
import 'package:chatify/src/utils/cache.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';

enum VoiceStatus {
  dowload,
  downloading,
  loading,
  ready,
}

class VoicePlayerController {
  final String user;
  final VoiceMessage message;

  factory VoicePlayerController({
    required VoiceMessage message,
    required String user,
  }) {
    final instance = _cache.putIfAbsent(
      message.id,
      () => VoicePlayerController._(
        message: message,
        user: user,
      ),
    );
    if (instance.isLoading == null)
      instance.isLoading = (instance.wasLoading ?? false).obs;
    if (instance.isReady == null)
      instance.isReady = (instance.wasReady ?? false).obs;
    if (instance.remainingTime == null)
      instance.remainingTime = (instance.latsRemainingTime ??
              message.duration.inSeconds.toDurationString)
          .obs;
    return instance;
  }

  VoicePlayerController._({
    required this.user,
    required this.message,
  }) {
    download();
  }

  String get url => message.url;
  int get seconds => message.duration.inSeconds;
  bool get isMe => Chatify.currentUserId == message.sender;

  final player = AudioPlayer();

  static final currentPlayer = Rx<VoicePlayerController?>(null);
  static final _cache = <String, VoicePlayerController>{};
  static final speed =
      (Cache.instance.getDouble('voice_player_speed') ?? 1).obs;

  final Rx<double> progress = .0.obs;
  final Rx<VoiceStatus> status = VoiceStatus.ready.obs;
  File? file;

  Rx<String>? remainingTime;
  String? latsRemainingTime;
  double maxNoiseHeight = 6.w(), noiseWidth = 26.5.w();
  double maxDurationForSlider = .0000001;
  Rx<bool>? isReady;
  bool? wasReady;
  Rx<bool>? isLoading;
  bool? wasLoading;

  AnimationController? progressController;
  AnimationController? playPauseController;
  int lastPositionInSeconds = 0;
  StreamSubscription<Duration>? _durationListener;
  VoicePlayerController? _nextPlayer;

  StreamSubscription? stream;
  download() async {
    if (url.isEmpty) return;
    progress.value = 0;
    StreamSubscription? stream;
    final _config = Config('voices', fileService: VoiceFileService());
    final voiceCache = CacheManager(_config);
    stream =
        voiceCache.getFileStream(url, withProgress: true).listen((e) async {
      if (e is DownloadProgress) {
        status.value = VoiceStatus.downloading;
        progress.value = e.progress ?? 0;
      } else if (e is FileInfo) {
        file = e.file;
        status.value = VoiceStatus.ready;
        stream?.cancel();
      }
    });
  }

  cancel() {
    stream?.cancel();
    if (file == null) {
      status.value = VoiceStatus.dowload;
    } else {
      status.value = VoiceStatus.ready;
    }
  }

  int _numOfTries = 0;
  Future<void> init() async {
    if (isReady!.value || isLoading!.value) return;
    status.value = VoiceStatus.loading;
    isLoading!.value = true;
    try {
      if (file == null) {
        if (_numOfTries == 3) return;
        await download();
        _numOfTries++;
        init();
      }
      await player.setFilePath(file!.path);
      if (player.speed != speed.value) player.setSpeed(speed.value);
      maxDurationForSlider = seconds.toDouble();
      listenToRemainingTime();
      progressController?.addListener(() {
        if (progressController?.isCompleted ?? false) {
          progressController?.reset();
        }
      });
      isReady!.value = true;
    } catch (_) {
      status.value = VoiceStatus.ready;
      isLoading!.value = false;
      return;
    }
    status.value = VoiceStatus.ready;
    isLoading!.value = false;
  }

  void togglePlay() async {
    player.playing ? stopPlaying() : _startPlaying();
  }

  bool _preventAutoPause = false;

  _startPlaying() async {
    if (!message.isPlayed && !isMe) {
      Chatify.datasource.addMessage(message.copyWith(isPlayed: true));
    }
    if (currentPlayer.value != this) {
      currentPlayer.value?._preventAutoPause = true;
      currentPlayer.value?.reset();
      currentPlayer.value = this;
    }
    if (progressController?.value == 0) {
      player.seek(Duration.zero);
    }
    if (player.speed != speed.value) {
      player.setSpeed(speed.value);
    }
    final animationDuration = Duration(seconds: seconds ~/ speed.value);
    if (progressController?.duration?.compareTo(animationDuration) != 0) {
      progressController?.duration = Duration(seconds: seconds ~/ speed.value);
    }
    _preventAutoPause = false;
    playPauseController?.forward();
    player.play().then((value) async {
      if (_preventAutoPause) return;
      playPauseController?.reverse();
      player.pause();
      progressController?.reset();
      currentPlayer.value = null;
      if (_nextPlayer != null) {
        await _nextPlayer!.init();
        _nextPlayer!.togglePlay();
      }
    });
    progressController?.forward();
    if (_nextPlayer == null) {
      final nextMsg = await Chatify.datasource.getNextVoice(message);
      if (nextMsg != null) {
        _nextPlayer = VoicePlayerController(
          message: nextMsg,
          user: user,
        );
      }
    }
  }

  stopPlaying() async {
    _preventAutoPause = true;
    playPauseController?.reverse();
    player.pause();
    progressController?.stop();
  }

  reset() {
    progressController?.reset();
    stopPlaying();
    player.seek(Duration.zero);
    remainingTime?.value = seconds.toDurationString;
  }

  void listenToRemainingTime() {
    if (_durationListener != null) return;
    _durationListener = player.createPositionStream().listen((p) {
      remainingTime?.value = p.inSeconds.toDurationString;
      lastPositionInSeconds = p.inSeconds;
    });
  }

  updateRemainingTime(Duration currentDuration) {
    lastPositionInSeconds = currentDuration.inSeconds;
    latsRemainingTime = remainingTime?.value;
  }

  onChangeSlider(double d) async {
    if (player.playing) togglePlay();
    final duration = isMe ? maxDurationForSlider - d : d;
    progressController?.value = (noiseWidth) * duration / maxDurationForSlider;
    remainingTime?.value = duration.toInt().toDurationString;
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
    wasReady = isReady?.value;
    isReady?.dispose();
    isReady = null;
    wasLoading = isLoading?.value;
    isLoading?.dispose();
    isLoading = null;
  }
}