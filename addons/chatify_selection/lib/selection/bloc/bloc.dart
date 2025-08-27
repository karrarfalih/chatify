import 'package:chatify/chatify.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'event.dart';
part 'state.dart';

class SelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  SelectionBloc(Chat chat) : super(const SelectionState.initial()) {
    final messageRepo = Chatify.messageRepo(chat);
    on<SelectionEvent>((event, emit) async {
      switch (event) {
        case SelectionModeChanged():
          emit(state.copyWith(isSelectionMode: event.isSelectionMode));
        case SelectionChanged():
          emit(state.copyWith(selectedMessages: event.selectedMessages));
        case SelectionToggle():
          final selected = Map<String, Message>.from(state.selectedMessages);
          if (selected.containsKey(event.message.content.id)) {
            selected.remove(event.message.content.id);
          } else {
            selected[event.message.content.id] = event.message;
          }
          emit(state.copyWith(selectedMessages: selected));
        case SelectionDeselectAll():
          emit(state.copyWith(selectedMessages: {}, isSelectionMode: false));
        case SelectionDelete():
          final messages = state.selectedMessages.values.toList();
          final isMutiple = messages.length > 1;
          final canDeleteForAll = messages.every(
            (e) => e.isMine && e.content is! DeletedMessage,
          );
          final deleteForAll = await showChatConfirmDialog(
            context: Get.context!,
            message: isMutiple
                ? 'Are you sure you want to delete these messages?'.tr
                : 'Are you sure you want to delete this message?'.tr,
            title: isMutiple
                ? 'Delete ${messages.length} messages'.trArgs([
                    messages.length.toString(),
                  ])
                : 'Delete message',
            textOK: 'Delete'.tr,
            showDeleteForAll: canDeleteForAll,
          );
          if (deleteForAll == null) return;
          for (final msg in messages) {
            messageRepo.delete(msg.content.id, deleteForAll == false);
          }
          add(SelectionDeselectAll());
      }
    });
  }
}
