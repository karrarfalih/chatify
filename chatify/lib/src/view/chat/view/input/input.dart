import '../../../../helpers/extensions.dart';
import '../record/view/record.dart';
import '../../../common/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';
import 'add.dart';
import 'reply.dart';

final _border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide.none,
);

class ChatInputBox extends StatefulWidget {
  const ChatInputBox({super.key});

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final textFocus = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  bool isShiftPressing = false;

  void _onSend() {
    textController.clear();
    context.read<MessagesBloc>().add(MessagesSendText());
  }

  void _handleKeyPress(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.shiftLeft) {
      isShiftPressing = event is KeyDownEvent;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (isShiftPressing && event is KeyDownEvent) {
        textController.text += '\n';
      }
      if (!isShiftPressing && event is KeyUpEvent) {
        _onSend();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessagesBloc, MessagesState>(
      listenWhen: (previous, current) =>
          previous.textMessage != current.textMessage,
      listener: (context, state) {
        textController.text = state.textMessage;
        if (state.textMessage.isNotEmpty) {
          textFocus.requestFocus();
        }
      },
      child: Column(
        children: [
          Divider(
            height: 1,
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.16),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 6,
                end: 16,
                top: 12,
                bottom: 16,
              ),
              child: BlocSelector<MessagesBloc, MessagesState, bool>(
                  selector: (state) => state.isRecording,
                  builder: (context, isRecording) {
                    if (isRecording) {
                      return const ChatRecordInput();
                    }
                    return Row(
                      children: [
                        const AddAttachmentButton(),
                        const SizedBox(width: 4),
                        Expanded(
                          child: KeyboardListener(
                            focusNode: focusNode,
                            onKeyEvent: _handleKeyPress,
                            child: BlocSelector<MessagesBloc, MessagesState,
                                    String>(
                                selector: (state) => state.textMessage,
                                builder: (context, text) {
                                  return Directionality(
                                    textDirection: text.directionByLanguage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerLowest,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                          )),
                                      child: Column(
                                        children: [
                                          const ChatReplyEdit(),
                                          TextField(
                                            controller: textController,
                                            focusNode: textFocus,
                                            maxLines: 5,
                                            minLines: 1,
                                            textInputAction:
                                                TextInputAction.unspecified,
                                            keyboardType:
                                                TextInputType.multiline,
                                            autofocus: true,
                                            onChanged: (value) => context
                                                .read<MessagesBloc>()
                                                .add(
                                                    MessagesTextChanged(value)),
                                            maxLength: 1000,
                                            buildCounter: (context,
                                                    {required currentLength,
                                                    required isFocused,
                                                    required maxLength}) =>
                                                const SizedBox.shrink(),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal: 16,
                                              ),
                                              constraints: const BoxConstraints(
                                                minHeight: 40,
                                              ),
                                              hintText: 'Type a message',
                                              isDense: true,
                                              border: _border,
                                              enabledBorder: _border,
                                              focusedBorder: _border,
                                              errorBorder: _border,
                                              disabledBorder: _border,
                                              focusedErrorBorder: _border,
                                              hoverColor: Colors.transparent,
                                              suffixIcon: BlocSelector<
                                                      MessagesBloc,
                                                      MessagesState,
                                                      bool>(
                                                  selector: (state) => state
                                                      .textMessage.isNotEmpty,
                                                  builder:
                                                      (context, isNotEmpty) {
                                                    return AnimatedSwitcher(
                                                      duration: const Duration(
                                                          milliseconds: 200),
                                                      transitionBuilder:
                                                          (child, animation) =>
                                                              FadeTransition(
                                                        opacity: animation,
                                                        child: ScaleTransition(
                                                          scale: animation,
                                                          child: child,
                                                        ),
                                                      ),
                                                      child: isNotEmpty
                                                          ? Transform.flip(
                                                              flipX: text
                                                                  .isContainArabic,
                                                              child:
                                                                  CustomIconButton(
                                                                key: ValueKey(
                                                                    isNotEmpty),
                                                                onPressed:
                                                                    _onSend,
                                                                svg: 'send',
                                                              ),
                                                            )
                                                          : CustomIconButton(
                                                              key: ValueKey(
                                                                  isNotEmpty),
                                                              onPressed: () {
                                                                context
                                                                    .read<
                                                                        MessagesBloc>()
                                                                    .add(
                                                                      MessagesRecordStart(),
                                                                    );
                                                              },
                                                              svg: 'mic',
                                                            ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
