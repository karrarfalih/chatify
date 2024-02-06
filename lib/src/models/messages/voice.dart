import 'package:chatify/src/enums.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/utils/storage_utils.dart';

class VoiceMessage extends Message {
  final String url;
  final Duration duration;
  final bool isPlayed;
  final UploadAttachment? uploadAttachment;
  final List<double> samples;

  VoiceMessage({
    required this.url,
    required this.duration,
    this.isPlayed = false,
    required this.samples,
    super.id,
    required super.chatId,
    super.sender,
    super.isEdited,
    super.sendAt,
    super.seenBy,
    required super.unSeenBy,
    required super.canReadBy,
    super.deliveredTo,
    super.emojis,
    super.replyId,
    super.replyUid,
    super.isPending,
    this.uploadAttachment,
  }) : super(type: MessageType.voice);

  @override
  Map<String, dynamic> get toJson {
    return {
      'url': url,
      'duration': duration.inMilliseconds,
      'isPlayed': isPlayed,
      'samples': samples,
      ...super.toJson,
    };
  }

  VoiceMessage.fromJson(Map data)
      : url = data['url'],
        duration = Duration(milliseconds: data['duration']),
        isPlayed = data['isPlayed'] ?? false,
        uploadAttachment = null,
        samples = data['samples'] != null
            ? List<double>.from(data['samples'])
            : <double>[],
        super.fromJson(data);

  VoiceMessage copyWith({bool? isPlayed, String? url}) => VoiceMessage(
        url: url ?? this.url,
        duration: duration,
        isPlayed: isPlayed ?? this.isPlayed,
        samples: samples,
        chatId: chatId,
        unSeenBy: unSeenBy,
        id: id,
        sender: sender,
        isEdited: isEdited,
        sendAt: sendAt,
        seenBy: seenBy,
        canReadBy: canReadBy,
        deliveredTo: deliveredTo,
        emojis: emojis,
        replyId: replyId,
        replyUid: replyUid,
        uploadAttachment: uploadAttachment,
      );
}
