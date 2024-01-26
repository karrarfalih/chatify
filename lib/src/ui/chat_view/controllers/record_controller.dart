part of 'chat_controller.dart';

class VoiceRecordingController {
  final ChatController controller;

  VoiceRecordingController(this.controller);

  final isRecording = false.obs;

  Timer? _timer;
  final seconds = 0.obs;
  late Record _record;
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
  List<double> samples = [];

  DateTime? recordStart;

  record() async {
    if (isRecording.value) return;
    _record = Record();
    Chatify.datasource
        .updateChatStatus(ChatStatus.recording, controller.chat.id);
    isRecording.value = true;
    micPos.value = Offset.zero;
    micLockPos.value = Offset.zero;
    micRadius.value = 80.0;
    isLocked.value = false;
    _minAmplitude = 0;
    seconds.value = 0;
    samples.clear;
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
    Directory dir = Directory('${documents.path}/recorded_voices');
    await dir.create(recursive: true);
    await _record.start(
      path: Platform.isIOS ? '${documents.path}/${Uuid.generate()}.aac' : null,
      encoder: AudioEncoder.aacLc,
    );
    recordStart = DateTime.now();

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
        samples.add(value.current);
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
      stopRecord(false);
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
    try {
      isRecording.value = false;
      _micRadiusTimer?.cancel();
      _micLockTimer?.cancel();
      _timer?.cancel();
      if (micPos.value.dx > -150 && seconds.value >= 1 && submit) {
        final id = Uuid.generate();
        path = await _record.stop();
        final file = File(path!);
        final uint8List = await File(path!).readAsBytes();
        final attachment = uploadAttachment(
          uint8List,
          'chats/${controller.chat.id}/$id.${file.path.split('.').last}',
        );
        final pendingMsg = VoiceMessage(
          id: id,
          chatId: controller.chat.id,
          url: '',
          duration: Duration(
            milliseconds:
                DateTime.now().difference(recordStart!).inMilliseconds,
          ),
          unSeenBy: controller.chat.members
              .where((e) => e != Chatify.currentUserId)
              .toList(),
          uploadAttachment: attachment,
          samples: samples,
          canReadBy: controller.chat.members,
        );
        controller.pending.add(pendingMsg);
        final url = await attachment.url;
        if (url == null) {
          controller.pending.remove(pendingMsg);
          return;
        }
        Chatify.datasource.addMessage(
          pendingMsg.copyWith(url: url),
          controller.receivers,
        );
        Chatify.datasource.addChat(controller.chat);
      }
    } finally {
      Chatify.datasource.updateChatStatus(ChatStatus.none, controller.chat.id);
      _record.dispose();
    }
  }

  void dispose() {
    _timer?.cancel();
    _micRadiusTimer?.cancel();
    _micLockTimer?.cancel();
    isRecording.dispose();
    if (isRecording.value) stopRecord(false);
    seconds.dispose();
    micRadius.dispose();
    micPos.dispose();
    micLockPos.dispose();
    isLocked.dispose();
  }
}
