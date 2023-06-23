import 'dart:async';
import 'dart:io';

import 'package:chatify/models/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/models/audio.dart';
import 'package:chatify/assets/circular_button.dart';
import 'package:chatify/models/chats.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AudioRecordWidget extends StatefulWidget {
  const AudioRecordWidget({Key? key, required this.onClose, required this.chat})
      : super(key: key);
  final Function() onClose;
  final ChatModel chat;
  @override
  State<AudioRecordWidget> createState() => _AudioRecordWidgetState();
}

class _AudioRecordWidgetState extends State<AudioRecordWidget> {
  Timer? timer;
  Rx<Duration> duration = const Duration(seconds: 0).obs;
  int current = 0;
  final record = Record();
  String? path;

  Future<void> startTimer() async {
    if (await record.hasPermission()) {
      Directory documents = await getApplicationDocumentsDirectory();

      await record.start(
        path: GetPlatform.isIOS
            ? '${documents.path}/${const Uuid().v4()}.m4a'
            : null,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) => increase());
  }

  void increase() {
    current++;
    duration.value = Duration(seconds: current);
  }

  Future<void> stop() async {
    isRecording.value = false;
    timer?.cancel();
    path = await record.stop();
  }

  Future<void> submit() async {
    if (isRecording.value) {
      timer?.cancel();
      path = await record.stop();
    }
    AudioMessage.send(widget.chat, await File(path!).readAsBytes(), current);
    widget.onClose();
  }

  RxBool isRecording = true.obs;

  @override
  void dispose() {
    timer?.cancel();
    if (isRecording.value) {
      stop().then((value) => record.dispose());
    } else {
      record.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 500, height: 61),
      child: Row(
        children: [
          CircularButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: widget.onClose,
          ),
          Expanded(
              child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12.5),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(50)),
            child: Row(
              children: [
                const Expanded(
                    child: Text(
                  '··········································································',
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 26, height: 0.85),
                  maxLines: 1,
                )),
                const SizedBox(
                  width: 5,
                ),
                Obx(() {
                  int s = duration.value.inSeconds % 60;
                  int m = duration.value.inMinutes;
                  return Text(
                    '${m < 10 ? '0$m' : m}:${s < 10 ? '0$s' : s}',
                    style: TextStyle(height: 1),
                  );
                }),
              ],
            ),
          )),
          Obx(() {
            return Visibility(
                visible: isRecording.value,
                child: CircularButton(
                    icon: const Icon(Icons.pause_circle_filled_outlined,
                        size: 32),
                    onPressed: stop));
          }),
          Container(
            decoration: const BoxDecoration(
                // color: Theme.of(context).primaryColor,
                shape: BoxShape.circle),
            child: CircularButton(
                onPressed: submit,
                size: 60,
                icon: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    Icons.send,
                    color: currentTheme.primary,
                    size: 26,
                  ),
                )),
          )
        ],
      ),
    );
  }
}
