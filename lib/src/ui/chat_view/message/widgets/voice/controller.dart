import 'dart:async';
import 'dart:io';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/cache.dart';
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
  VoiceMessage message;

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
    if (instance.isReady == null)
      instance.isReady = (instance.wasReady ?? false).obs;
    if (instance.remainingTime == null)
      instance.remainingTime = (instance.latsRemainingTime ??
              message.duration.inSeconds.toDurationString)
          .obs;
    instance.message = message;
    return instance;
  }

  VoicePlayerController._({
    required this.user,
    required this.message,
  }) {
    download();
  }

  String get url => message.url;
  int get milliseconds => message.duration.inMilliseconds;
  bool get isMe => message.isMine;

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
  double noiseWidth = 110;
  double maxDurationForSlider = .0000001;
  Rx<bool>? isReady;
  bool? wasReady;
  bool? wasLoading;

  AnimationController? progressController;
  AnimationController? playPauseController;
  int lastPositionInMilliSeconds = 0;
  StreamSubscription<Duration>? _durationListener;
  VoicePlayerController? _nextPlayer;

  final isDownloaded = Completer<bool>();

  StreamSubscription? stream;
  download() async {
    if (url.isEmpty) return;
    progress.value = 0;
    StreamSubscription? stream;
    final _config = Config('voices', fileService: VoiceFileService());
    final voiceCache = CacheManager(_config);
    stream = voiceCache.getFileStream(url, withProgress: true).listen(
      (e) async {
        if (e is DownloadProgress) {
          status.value = VoiceStatus.downloading;
          progress.value = e.progress ?? 0;
        } else if (e is FileInfo) {
          file = e.file;
          status.value = VoiceStatus.ready;
          stream?.cancel();
          isDownloaded.complete(true);
        }
      },
      onError: (e) {
        status.value = VoiceStatus.dowload;
        stream?.cancel();
        isDownloaded.complete(false);
      },
    );
  }

  cancel() {
    stream?.cancel();
    if (file == null) {
      status.value = VoiceStatus.dowload;
    } else {
      status.value = VoiceStatus.ready;
    }
  }

  bool isBusy = false;
  Future<void> init() async {
    if (isReady!.value || isBusy) return;
    status.value = VoiceStatus.loading;
    isBusy = true;
    try {
      if (file == null) {
        await download();
        final downlaoded = await isDownloaded.future;
        if (!downlaoded) {
          isBusy = false;
          return;
        }
      }
      await player.setFilePath(file!.path);
      if (player.speed != speed.value) player.setSpeed(speed.value);
      maxDurationForSlider = milliseconds / 1000;
      listenToRemainingTime();
      progressController?.addListener(() {
        if (progressController?.isCompleted ?? false) {
          progressController?.reset();
        }
      });
      isReady!.value = true;
    } catch (_) {
      status.value = VoiceStatus.dowload;
      isBusy = false;
      return;
    }
    status.value = VoiceStatus.ready;
    isBusy = false;
  }

  void togglePlay() async {
    player.playing ? stopPlaying() : _startPlaying();
  }

  bool _preventAutoPause = false;

  _startPlaying() async {
    if (!message.isPlayed && !isMe) {
      Chatify.datasource.addMessage(message.copyWith(isPlayed: true), null);
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
    final animationDuration =
        Duration(milliseconds: milliseconds ~/ speed.value);
    if (progressController?.duration?.compareTo(animationDuration) != 0) {
      progressController?.duration =
          Duration(milliseconds: milliseconds ~/ speed.value);
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
    remainingTime?.value = (milliseconds / 1000).round().toDurationString;
  }

  void listenToRemainingTime() {
    if (_durationListener != null) return;
    _durationListener = player.createPositionStream().listen((p) {
      remainingTime?.value = p.inSeconds.toDurationString;
      lastPositionInMilliSeconds = p.inMilliseconds;
    });
  }

  updateRemainingTime(Duration currentDuration) {
    lastPositionInMilliSeconds = currentDuration.inMilliseconds;
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

    progressController!.duration =
        Duration(milliseconds: milliseconds ~/ speed.value);
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
  }
}
