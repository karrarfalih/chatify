import 'package:chatify/chatify.dart';
import 'package:chatify_selection/selection/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';

// Use local selection implementation
import 'package:chatify_selection/selection/view/header.dart' as sel;
import 'package:chatify_selection/selection/view/listener.dart' as sel;
import 'package:chatify_selection/selection/view/message.dart' as sel;

class SelectionAddon extends ChatAddon {
  const SelectionAddon();

  @override
  List<HeaderContribution> buildHeaders(BuildContext c, Chat chat) => [
    HeaderContribution(
      id: 'selection_header',
      layer: Layer.modal,
      priority: 0,
      isVisible: (_) => true, // internal widget handles visibility
      builder: (_) => const sel.SelectedMessagesHeader(),
    ),
  ];

  @override
  Widget wrapMessagesList(BuildContext c, Chat chat, Widget child) {
    return sel.MessagesSelectionListener(child: child);
  }

  @override
  Widget wrapMessage(
    BuildContext c,
    Chat chat,
    Message m,
    int i,
    Widget child,
  ) {
    return sel.MessageSelectionWidget(message: m, index: i, child: child);
  }

  @override
  Widget wrapChat(BuildContext c, Chat chat, Widget child) {
    return BlocProvider(
      create: (context) => SelectionBloc(chat),
      child: child,
    );
  }
}
