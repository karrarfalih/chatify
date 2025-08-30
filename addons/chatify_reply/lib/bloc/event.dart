part of 'bloc.dart';

sealed class SelectionEvent {}

abstract class ReplyEvent {}

class ReplyStart extends ReplyEvent {
  final Message message;
  ReplyStart(this.message);
}

class ReplyCancel extends ReplyEvent {}