part of 'chat_controller.dart';

class VoiceRecordingController {
  final ChatController controller;

  VoiceRecordingController(this.controller);

  final isRecording = false.obs;

  Timer? _timer;
  final seconds = 0.obs;
  final _record = Record();
  String? path;

  final micRadius = 80.0.obs;
  final micPos = Offset.zero.obs;
  final micLockPos = Offset.zero.obs;

  Timer? _micRadiusTimer;
  Timer? _micLockTimer;
  double _minAmplitude = -30;
  final isLocked = false.obs;
  bool isPermissionAsked = false;
  bool isPermissionGranted = false;

  record() async {
    if (isRecording.value) return;
    isRecording.value = true;
    micPos.value = Offset.zero;
    micLockPos.value = Offset.zero;
    micRadius.value = 80.0;
    isLocked.value = false;
    _minAmplitude = 0;
    seconds.value = 0;
    vibrate();
    final startDate = DateTime.now();
    if (!await _record.hasPermission()) {
      stopRecord(false);
      if (isPermissionAsked) {
        ///TODO: show dialog message
      }
      isPermissionAsked = true;
      return;
    }
    if (startDate.difference(DateTime.now()).inSeconds.abs() > 1 &&
        !isPermissionGranted) {
      stopRecord(false);
      isPermissionGranted = true;
      return false;
    }
    isPermissionGranted = true;
    Directory documents = await getApplicationDocumentsDirectory();
    await _record.start(
      path: Platform.isIOS ? '${documents.path}/${Uuid.generate()}.aac' : null,
      encoder: AudioEncoder.aacLc,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => seconds.value++);
    _micRadiusTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!isRecording.value) return;
      _record.getAmplitude().then((value) {
        if (value.current.isInfinite ||
            value.current.isNaN ||
            !value.current.isFinite) return;
        if (value.current < _minAmplitude) {
          _minAmplitude = value.current;
        }
        micRadius.value = (Random().nextInt(10)) +
            60.0 +
            (30 * (_minAmplitude / value.current).withRange(1, 5));
      });
    });
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      _updateLockPos();
      _micLockTimer = Timer.periodic(
        Duration(milliseconds: 1500),
        (timer) => _updateLockPos(),
      );
    });
  }

  setMicPos(Offset offset) {
    if (isLocked.value) return;
    if (offset.distance.round() == micPos.value.distance.round()) return;
    if (offset.dx < -180) {
      controller.voiceController.stopRecord();
    }
    micPos.value = offset;
    if (offset.dy < -90 && offset.dx > -70) {
      _lockThump();
    }
  }

  endMicDarg(Chat chat) {
    if (!isLocked.value) {
      stopRecord();
    }
  }

  _updateLockPos() {
    if (!isRecording.value) return;
    final isZero = micLockPos.value.dy == 0;
    micLockPos.value = Offset(0, isZero ? 1 : 0);
  }

  _lockThump() {
    vibrate();
    isLocked.value = true;
    micPos.value = Offset.zero;
    _micLockTimer?.cancel();
    micLockPos.value = Offset.zero;
  }

  vibrate() {
    if (kDebugMode && Platform.isIOS) {
      return;
    }
    Vibration.hasVibrator().then((canVibrate) {
      if (canVibrate == true) Vibration.vibrate(duration: 10, amplitude: 100);
    });
  }

  stopRecord([bool submit = true]) async {
    if (!isRecording.value) return;
    vibrate();
    isRecording.value = false;
    _micRadiusTimer?.cancel();
    _micLockTimer?.cancel();
    _timer?.cancel();
    if (micPos.value.dx > -150 && seconds.value >= 1 && submit) {
      final id = Uuid.generate();
      final pendingMsg = Message(
        id: id,
        message: 'voice message',
        chatId: controller.chat.id,
        sender: Chatify.currentUserId,
        type: MessageType.voice,
        duration: Duration(seconds: seconds.value),
        unSeenBy: [],
      );
      controller.pendingMessages.value = [
        ...controller.pendingMessages.value,
        pendingMsg,
      ];
      path = await _record.stop();
      final file = File(path!);
      final uint8List = await File(path!).readAsBytes();
      final url = await uploadAttachment(
        uint8List,
        'chats/${controller.chat.id}/$id.${file.path.split('.').last}',
      );
      if (url == null) return;
      await Chatify.datasource.addMessage(
        Message(
          id: id,
          message: 'voice message',
          chatId: controller.chat.id,
          sender: Chatify.currentUserId,
          attachment: url,
          type: MessageType.voice,
          duration: Duration(seconds: seconds.value),
          unSeenBy: controller.chat.members
              .where((e) => e != Chatify.currentUserId)
              .toList(),
        ),
      );
      // controller.pendingMessages.value.remove(pendingMsg);
      // controller.pendingMessages.value =
      //     controller.pendingMessages.value.toList();
    }
  }

  void dispose() {
    _timer?.cancel();
    _micRadiusTimer?.cancel();
    _micLockTimer?.cancel();
    _record.dispose();
    isRecording.dispose();
    seconds.dispose();
    _record.dispose();
    micRadius.dispose();
    micPos.dispose();
    micLockPos.dispose();
    isLocked.dispose();
  }
}
