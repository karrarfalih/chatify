import 'dart:async';
import '../../../core/chatify.dart';
import '../../../core/addons_registry.dart';
import '../../../helpers/nullable.dart';
import '../../../core/composer.dart';
import '../../../core/registery.dart';
import '../../common/confirm.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart' hide Transition;
import 'package:rxdart/rxdart.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/messages/message.dart';
import '../../../domain/models/messages/content.dart';
import '../../../helpers/paginated_result.dart';
import '../../../domain/message_repo.dart';
import '../../../core/task.dart';

part 'event.dart';
part 'state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  late final MessageRepo messageRepo;
  final Chat chat;

  final int pageSize = 20;

  StreamSubscription<PaginatedResult<Message>>? _messagesSubscription;
  StreamSubscription<ChatStatus>? _statusSubscription;

  MessagesBloc({
    required this.chat,
  }) : super(const MessagesState.initial()) {
    MessageProviderRegistry.instance.ensureInitialized();
    messageRepo = Chatify.messageRepo(chat);
    on<MessagesEvent>((event, emit) async {
      switch (event) {
        case MessagesComposerResultsPicked():
          for (final r in event.results) {
            if (r is MediaComposerResult) {
              add(MessagesSendMessage(r.message, composerResult: r));
            } else {
              add(MessagesSendMessage(r.message));
            }
          }
        case MessagesStatusUpdated():
          emit(state.copyWith(status: event.status));
        case MessagesUpdated():
          final unseenMessages =
              event.messages.items.where((message) => !message.isSeen).toList();
          emit(state.copyWith(messages: event.messages));
          for (final e in unseenMessages) {
            messageRepo.markAsSeen(e.content.id);
            add(MessagesRemoveMessageFromQueue(e.content.id));
          }
        case MessagesLoadMore():
          break;
        case MessagesFocus():
          emit(state.copyWith(
            focusedMessage:
                event.isShown ? event.message.nl : const Nullable.nl(),
          ));
        case MessageCopy():
          Clipboard.setData(ClipboardData(text: event.message.content.content));
        case MessageDelete():
          await delete([event.message]);
        case MessageEdit():
          emit(state.copyWith(
            editingMessage: event.message.nl,
            textMessage: event.message.content.content,
          ));
        case MessageCancel():
          MessageTaskRegistry.instance.cancelUpload(event.message.content.id);
          add(MessagesRemoveMessageFromQueue(event.message.content.id));
          break;

        case MessagesSendMessage():
          if (state.editingMessage.value != null) {
            messageRepo.update(
                event.message.content, state.editingMessage.value!.content.id);
            emit(state.copyWith(
              editingMessage: const Nullable.nl(),
              textMessage: '',
            ));
            return;
          }
          add(MessagesAddMessageToPending(event.message));
          String? url;
          if (event.composerResult != null) {
            url = await sendMessageWithAttachment(event.composerResult!);
            if (url == null) {
              return;
            }
          }
          final metadata = ChatAddonsRegistry.instance.chatAddons
              .fold<Map<String, dynamic>>(<String, dynamic>{}, (acc, addon) {
            return {
              ...acc,
              ...addon.buildOutgoingMetadata(chat),
            };
          });
          final result = await messageRepo.add(
            event.message,
            attachmentUrl: url,
            metadata: metadata,
          );
          if (result.hasError) {
            add(MessagesAddMessageToFailed(event.message.id));
          }
          if (!result.hasError) {
            for (final addon in ChatAddonsRegistry.instance.chatAddons) {
              addon.onMessageSent(chat);
            }
          }
        case MessagesTextChanged():
          emit(state.copyWith(textMessage: event.text));
        case MessagesRecordStart():
          emit(state.copyWith(isRecording: true));
        case MessagesRecordStop():
          emit(state.copyWith(isRecording: false));
        case MessageReaction():
          messageRepo.addReaction(event.messageId, event.emoji);
        case MessagesSendText():
          final raw = _cleanMessage(state.textMessage);
          if (raw.isNotEmpty) {
            final textProviders = MessageProviderRegistry.instance.providers
                .where((e) => e.supportsTextInput);
            for (final provider in textProviders) {
              final created = provider.createFromText(raw);
              if (created != null) {
                add(MessagesSendMessage(created));
              }
            }
          }
          emit(state.copyWith(textMessage: ''));
        case MessagesCancelSendingMessage():
          add(MessagesRemoveMessageFromQueue(event.message.content.id));
        case MessagesRetrySendingMessage():
          break;
        // final msg = event.message.message;
        // final url = await sendMessageWithAttachment(msg);
        // if (url != null) {
        //   await messageRepo.addWithAttachment(
        //     msg,
        //     state.replyingMessage.isNull
        //         ? null
        //         : ReplyMessage(
        //             id: msg.id,
        //             message: state.replyingMessage.value!.message.content,
        //             sender: state.replyingMessage.value!.sender,
        //             sentAt: DateTime.now(),
        //             isMine: true,
        //           ),
        //     attachmentUrl: url,
        //   );
        // } else {
        //   add(MessagesSendMessage(msg));
        // }
        case MessagesAddMessageToPending():
          emit(state.copyWith(
            pendingMessages: [
              ...state.pendingMessages,
              if (state.pendingMessages
                  .every((e) => e.content.id != event.message.id))
                Message(
                  sender: chat.sender,
                  sentAt: DateTime.now(),
                  content: event.message,
                ),
            ],
            failedMessages: state.failedMessages
                .where((e) => e.content.id != event.message.id)
                .toList(),
          ));
        case MessagesAddMessageToFailed():
          emit(state.copyWith(
            failedMessages: [
              ...state.failedMessages,
              if (state.pendingMessages.any((e) => e.content.id == event.id))
                state.pendingMessages
                    .firstWhere((e) => e.content.id == event.id),
            ],
            pendingMessages: state.pendingMessages
                .where((e) => e.content.id != event.id)
                .toList(),
          ));
        case MessagesRemoveMessageFromQueue():
          emit(state.copyWith(
            failedMessages: state.failedMessages
                .where((e) => e.content.id != event.id)
                .toList(),
            pendingMessages: state.pendingMessages
                .where((e) => e.content.id != event.id)
                .toList(),
          ));
      }
    });
    on<MessagesLoadMore>(
      (event, emit) {
        messageRepo.loadMore();
      },
      transformer: (events, mapper) => events
          .throttleTime(const Duration(milliseconds: 300), trailing: true)
          .asyncExpand(mapper),
    );

    _messagesSubscription = messageRepo.messagesStream().listen((messages) {
      add(MessagesUpdated(messages));
    });
    _statusSubscription = messageRepo.getStatus().listen((status) {
      add(MessagesStatusUpdated(status));
    });
  }

  Future<String?> sendMessageWithAttachment(MediaComposerResult result) async {
    final res = await MessageTaskRegistry.instance.startUpload(
      id: result.message.id,
      bytes: result.bytes,
      chatId: chat.id,
      storageFolder: result.storageFolder ?? 'media',
      fileName: result.fileName ?? result.message.id,
    );
    if (!res.isCanceled && res.url == null) {
      add(MessagesAddMessageToFailed(result.message.id));
    } else if (res.isCanceled) {
      add(MessagesRemoveMessageFromQueue(result.message.id));
    }
    return res.url;
  }

  delete(List<Message> messages) async {
    final isMutiple = messages.length > 1;
    final canDeleteForAll =
        messages.every((e) => e.isMine && e.content is! DeletedMessage);
    final deleteForAll = await showChatConfirmDialog(
      context: Get.context!,
      message: isMutiple
          ? 'Are you sure you want to delete these messages?'.tr
          : 'Are you sure you want to delete this message?'.tr,
      title: isMutiple
          ? 'Delete ${messages.length} messages'
              .trArgs([messages.length.toString()])
          : 'Delete message',
      textOK: 'Delete'.tr,
      showDeleteForAll: canDeleteForAll,
    );
    if (deleteForAll == null) return;
    for (final msg in messages) {
      messageRepo.delete(msg.content.id, deleteForAll == false);
    }
  }

  String _cleanMessage(String message) {
    return message
        .trim()
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }

  @override
  void onTransition(Transition<MessagesEvent, MessagesState> transition) {
    super.onTransition(transition);
    final text = transition.nextState.textMessage;
    final hasPendingMedia = transition.nextState.pendingMessages.any((e) {
      final provider = MessageProviderRegistry.instance.getByMessage(e.content);
      return provider?.isMedia ?? false;
    });
    messageRepo.updateStatus(
      text.isNotEmpty
          ? ChatStatus.typing
          : hasPendingMedia
              ? ChatStatus.sendingMedia
              : ChatStatus.none,
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _statusSubscription?.cancel();
    messageRepo.dispose();
    messageRepo.updateStatus(ChatStatus.none);
    return super.close();
  }
}
