part of 'bloc.dart';

class ReplyState extends Equatable {
  final Message? replying;

  const ReplyState({this.replying});

  const ReplyState.initial() : this();
  
  ReplyState copyWith({Message? replying}) => ReplyState(replying: replying);

  @override
  List<Object?> get props => [replying];
}
