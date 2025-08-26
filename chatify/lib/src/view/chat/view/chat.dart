import '../../../../chatify.dart';
import '../../common/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import 'input/input.dart';
import 'message/selection/header.dart';
import 'messages.dart';
import 'status.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({
    super.key,
    required this.chat,
    this.layout,
  });

  final Chat chat;
  final ChatLayout? layout;

  static showWithNavigator({
    required BuildContext context,
    required Chat chat,
  }) {
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: {'chat': chat},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagesBloc(chat: chat),
      child: Builder(builder: (context) {
        if (layout != null) {
          return layout!.bodyBuilder!(
            context,
            const Column(
              children: [
                SelectedMessagesHeader(),
                Expanded(
                  child: ChatMessages(),
                ),
                ChatStatusWidget(),
                ChatInputBox(),
              ],
            ),
            chat,
          );
        }
        return Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  CustomIconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icons.arrow_back,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      chat.receiver.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  CustomIconButton(
                    onPressed: () {
                      Scaffold.of(context).closeEndDrawer();
                    },
                    icon: Icons.close,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SelectedMessagesHeader(),
            const Expanded(
              child: ChatMessages(),
            ),
            const ChatStatusWidget(),
            const ChatInputBox(),
          ],
        );
      }),
    );
  }
}
