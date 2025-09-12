import 'package:chatify/chatify.dart';

final class VoiceMessage extends MessageContent {
  final Duration duration;
  final bool isPlayed;
  final List<double> samples;

  VoiceMessage({
    required String url,
    required this.duration,
    required this.isPlayed,
    required this.samples,
  }) : super(content: 'Voice message', url: url, type: 'VoiceMessage');

  VoiceMessage.fromJson(super.json, super.id)
      : duration = json['duration'],
        isPlayed = json['isPlayed'],
        samples = json['samples'],
        super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'isPlayed': isPlayed,
      'samples': samples,
      ...super.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, duration, isPlayed, samples, ...super.props];
}
