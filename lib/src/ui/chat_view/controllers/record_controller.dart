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
  final micPos = Offset(0, 0).obs;
  final micLockPos = Offset(0, 0).obs;

  Timer? _micRadiusTimer;
  Timer? _micLockTimer;
  double _minAmplitude = -30;
  final isLocked = false.obs;

  record() async {
    if (await _record.hasPermission()) {
      Directory documents = await getApplicationDocumentsDirectory();
      await _record.start(
        path:
            Platform.isIOS ? '${documents.path}/${Uuid.generate()}.m4a' : null,
        encoder: AudioEncoder.aacLc,
      );
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => seconds.value++);
    isRecording.value = true;
    micPos.value = Offset(0, 0);
    micRadius.value = 80.0;
    isLocked.value = false;
    _minAmplitude = 0;
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
    isLocked.value = true;
    micPos.value = Offset.zero;
    _micLockTimer?.cancel();
    micLockPos.value = Offset.zero;
  }

  stopRecord([bool submit = true]) async {
    if (!isRecording.value) return;
    _micRadiusTimer?.cancel();
    _micLockTimer?.cancel();
    isRecording.value = false;
    micLockPos.value = Offset.zero;
    if (micPos.value.dx > -150 && seconds.value > 1 && submit) {
      final pendingMsg = Message(
        id: 'id',
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
      _timer?.cancel();
      path = await _record.stop();
      final file = await File(path!).readAsBytes();
      final id = Uuid.generate();
      final url =
          await uploadAttachment(file, 'chats/${controller.chat.id}/$id.m4a');
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
      controller.pendingMessages.value.remove(pendingMsg);
      controller.pendingMessages.value =
          controller.pendingMessages.value.toList();
    }
  }

  void dispose() {
    _timer?.cancel();
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
