import 'package:chatify/chatify.dart';
import 'package:chatify_reply/bloc/bloc.dart';
import 'package:chatify_reply/view/expanded_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ReplyPreview extends StatelessWidget {
  const ReplyPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReplyBloc, ReplyState>(
      buildWhen: (previous, current) =>
          previous.replying != current.replying,
      builder: (context, state) {
        final reply = state.replying;
        final isMine = reply?.isMine ?? false;
        final sender = reply?.sender;
        final hasAction = reply != null;
        final content = reply?.content.content ?? '';
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
                    context.read<ReplyBloc>().add(ReplyCancel());
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
