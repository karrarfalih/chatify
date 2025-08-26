import 'package:chatify/src/view/common/expanded_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatify/src/view/chat/bloc/bloc.dart';
import 'package:chatify/src/helpers/extensions.dart';

class ChatReplyEdit extends StatelessWidget {
  const ChatReplyEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(
      buildWhen: (previous, current) =>
          previous.replyingMessage != current.replyingMessage ||
          previous.editingMessage != current.editingMessage,
      builder: (context, state) {
        final reply = state.replyingMessage.value;
        final edit = state.editingMessage.value;
        final isMine = reply?.isMine ?? edit?.isMine ?? false;
        final sender = reply?.sender ?? edit?.sender;
        final hasAction = reply != null || edit != null;
        final content = reply?.content.content ?? edit?.content.content ?? '';
        return ExpandedSection(
          expand: hasAction,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 2,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMine ? 'You' : sender?.name ?? '',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: content.directionByLanguage,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    context.read<MessagesBloc>().add(MessageCancelEditReply());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
