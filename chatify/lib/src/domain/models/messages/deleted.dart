part of 'content.dart';

final class DeletedMessage extends MessageContent {
  DeletedMessage({required super.id})
      : super(content: 'Deleted message', type: 'TextMessage');

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
    };
  }

  @override
  List<Object?> get props => [id];
}
