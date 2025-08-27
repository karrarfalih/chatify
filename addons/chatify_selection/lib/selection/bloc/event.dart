part of 'bloc.dart';

sealed class SelectionEvent {}

final class SelectionModeChanged extends SelectionEvent {
  final bool isSelectionMode;
  SelectionModeChanged(this.isSelectionMode);
}

final class SelectionChanged extends SelectionEvent {
  final Map<String, Message> selectedMessages;
  SelectionChanged(this.selectedMessages);
}

final class SelectionToggle extends SelectionEvent {
  final Message message;
  SelectionToggle(this.message);
}

final class SelectionDeselectAll extends SelectionEvent {}

final class SelectionDelete extends SelectionEvent {}
