import '../../../../../domain/models/messages/message.dart';
import '../../../bloc/bloc.dart';

import 'listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageSelectionWidget extends StatelessWidget {
  const MessageSelectionWidget({
    super.key,
    required this.message,
    required this.index,
    required this.child,
  });

  final Message message;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SelectableMessage(
      key: ValueKey(message.content.id),
      index: index,
      message: message,
      child: BlocSelector<MessagesBloc, MessagesState, Map<String, Message>>(
          selector: (state) => state.selectedMessages,
          builder: (context, selectedMessages) {
            final isSelected = selectedMessages.containsKey(message.content.id);
            return ColoredBox(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  if (selectedMessages.isNotEmpty) {
                    context
                        .read<MessagesBloc>()
                        .add(MessageToggleSelection(message));
                  }
                },
                onLongPress: () {
                  context
                      .read<MessagesBloc>()
                      .add(MessageToggleSelection(message));
                  context
                      .read<MessagesBloc>()
                      .add(MessagesSelectionModeChanged(true));
                },
                onLongPressEnd: (details) {
                  context
                      .read<MessagesBloc>()
                      .add(MessagesSelectionModeChanged(false));
                },
                onLongPressCancel: () {
                  context
                      .read<MessagesBloc>()
                      .add(MessagesSelectionModeChanged(false));
                },
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    PopScope(
                      canPop: selectedMessages.isEmpty,
                      onPopInvokedWithResult: (didPop, _) {
                        context.read<MessagesBloc>().add(MessageDeselectAll());
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: selectedMessages.isNotEmpty ? 40 : 0,
                        height: 20,
                        child: Center(
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(child: child),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
