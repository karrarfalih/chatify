import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:chatify/src/utils/uuid.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecordingController extends ValueNotifier {
  VoiceRecordingController() : super(null) {
    startTimer();
  }

  bool isRecording = false;
  Duration duration = Duration.zero;

  Timer? timer;
  int current = 0;
  final record = Record();
  String? path;

  Future<void> startTimer() async {
    if (await record.hasPermission()) {
      Directory documents = await getApplicationDocumentsDirectory();

      await record.start(
        path:
            Platform.isIOS ? '${documents.path}/${Uuid.generate()}.m4a' : null,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) => increase());
  }

  void increase() {
    current++;
    duration = Duration(seconds: current);
    notifyListeners();
  }

  Future<void> stop() async {
    isRecording = false;
    notifyListeners();
    timer?.cancel();
    path = await record.stop();
  }

  changeStatus(bool isRecording) {
    isRecording = isRecording;
    notifyListeners();
  }

  setDuration(Duration duration) {
    duration = duration;
    notifyListeners();
  }

  @override
  void dispose() {
    timer?.cancel();
    record.dispose();
    super.dispose();
  }
}
