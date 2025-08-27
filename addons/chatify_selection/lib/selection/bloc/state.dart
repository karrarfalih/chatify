part of 'bloc.dart';

final class SelectionState extends Equatable {
  final Map<String, Message> selectedMessages;
  final bool isSelectionMode;

  const SelectionState({
    required this.selectedMessages,
    required this.isSelectionMode,
  });

  const SelectionState.initial()
    : this(selectedMessages: const {}, isSelectionMode: false);

  SelectionState copyWith({
    Map<String, Message>? selectedMessages,
    bool? isSelectionMode,
  }) {
    return SelectionState(
      selectedMessages: selectedMessages ?? this.selectedMessages,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  List<Object?> get props => [selectedMessages, isSelectionMode];
}
