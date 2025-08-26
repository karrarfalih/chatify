import '../../../../../core/registery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../bloc/bloc.dart';
import '../../../../common/options_builder.dart';
import '../../../../../domain/models/messages/message.dart';

class MessageOptions extends StatelessWidget {
  const MessageOptions({
    super.key,
    required this.child,
    required this.message,
    required this.isSending,
    required this.isFailed,
  });

  final Widget child;
  final Message message;
  final bool isSending;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    return OptionsBuilder(
      onShow: (isShown) {
        context
            .read<MessagesBloc>()
            .add(MessagesFocus(message.content.id, isShown));
      },
      topWidget: isSending
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: ['❤', '😍', '😂', '😢', '👍'].map((e) {
                  return TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 16,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: message.myEmoji == e
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1,
                      ),
                    ),
                    onPressed: () async {
                      Get.back();
                      context
                          .read<MessagesBloc>()
                          .add(MessageReaction(message.content.id, e));
                    },
                  );
                }).toList(),
              ),
            ),
      options: [
        if (isFailed)
          OptionsItem(
            title: 'Retry',
            icon: Iconsax.refresh,
            onSelect: () {
              context
                  .read<MessagesBloc>()
                  .add(MessagesRetrySendingMessage(message));
            },
          )
        else if (isSending)
          OptionsItem(
            title: 'cancel',
            icon: Iconsax.trash,
            iconColor: Colors.red,
            isDestructive: true,
            onSelect: () {
              context.read<MessagesBloc>().add(MessageCancel(message));
            },
          )
        else ...[
          // Base core options
          OptionsItem(
            title: 'Reply',
            icon: Iconsax.undo,
            onSelect: () {
              context.read<MessagesBloc>().add(MessageReply(message));
            },
          ),
          OptionsItem(
            title: 'Delete',
            icon: Iconsax.trash,
            iconColor: Colors.red,
            isDestructive: true,
            onSelect: () {
              context.read<MessagesBloc>().add(MessageDelete(message));
            },
          ),
          // Provider options
          ..._buildProviderOptions(context, message),
        ]
      ],
      applyOpacity: false,
      builder: (showOptions) {
        return GestureDetector(
          onSecondaryTap: showOptions,
          child: Container(
            width: double.maxFinite,
            color: Colors.transparent,
            child: Stack(
              children: [
                BlocSelector<MessagesBloc, MessagesState, String?>(
                  selector: (state) => state.focusedMessage.value,
                  builder: (context, focusedMessage) {
                    if (focusedMessage == null ||
                        focusedMessage != message.content.id) {
                      return const SizedBox.shrink();
                    }
                    return Positioned.fill(
                      child: ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.06),
                      ),
                    );
                  },
                ),
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}

List<OptionsItem> _buildProviderOptions(BuildContext context, Message message) {
  final provider =
      MessageProviderRegistry.instance.getByMessage(message.content);
  if (provider == null) return [];
  final items = <OptionsItem>[];
  if (message.isMine &&
      message.content.runtimeType.toString() == 'TextMessage') {
    items.add(OptionsItem(
      title: 'Edit',
      icon: Iconsax.edit,
      onSelect: () => context.read<MessagesBloc>().add(MessageEdit(message)),
    ));
  }
  if (message.content.runtimeType.toString() == 'TextMessage') {
    items.add(OptionsItem(
      title: 'Copy',
      icon: Iconsax.copy,
      onSelect: () => context.read<MessagesBloc>().add(MessageCopy(message)),
    ));
  }
  return items;
}
