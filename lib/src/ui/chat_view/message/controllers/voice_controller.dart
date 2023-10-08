import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:chatify/src/utils/uuid.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecordingController extends ValueNotifier {
  VoiceRecordingController() : super(null) {
    _startTimer();
  }

  Timer? _timer;
  int seconds = 0;
  final record = Record();
  String? path;

  Future<void> _startTimer() async {
    if (await record.hasPermission()) {
      Directory documents = await getApplicationDocumentsDirectory();
      await record.start(
        path:
            Platform.isIOS ? '${documents.path}/${Uuid.generate()}.m4a' : null,
        encoder: AudioEncoder.aacLc,
      );
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _increase());
  }

  void _increase() {
    seconds++;
    notifyListeners();
  }

  Future<void> stop() async {
    _timer?.cancel();
    path = await record.stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    record.dispose();
    super.dispose();
  }
}
