import '../../../../../domain/models/messages/message.dart';
import '../../../bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesSelectionListener extends StatefulWidget {
  const MessagesSelectionListener({super.key, required this.child});

  final Widget child;

  @override
  State<MessagesSelectionListener> createState() =>
      _MessagesSelectionListenerState();
}

class _MessagesSelectionListenerState extends State<MessagesSelectionListener> {
  final _key = GlobalKey();

  Offset offset = Offset.zero;
  bool isRemove = false;
  Map<int, Message> addedMessages = {};

  Map<String, Message> initialSelecetdMessages = {};

  _detectTapedItem(PointerEvent event) {
    if (!context.read<MessagesBloc>().state.isSelectionMode) return;
    final bloc = context.read<MessagesBloc>();
    final RenderBox box =
        _key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is SelectedMessage) {
          final initialList =
              Map<String, Message>.from(bloc.state.selectedMessages);
          final selectedMessages =
              Map<String, Message>.from(bloc.state.selectedMessages);
          bool isScrollUp = offset.dy > local.dy;
          addedMessages.putIfAbsent(target.index, () => target.message);
          addedMessages.removeWhere(
            (key, value) =>
                isScrollUp ? key > target.index : key < target.index,
          );
          if (isRemove) {
            selectedMessages.addAll(initialSelecetdMessages);
            selectedMessages.removeWhere(
              (key, value) => addedMessages.containsValue(value),
            );
          } else {
            selectedMessages.clear();
            selectedMessages.addAll(
              addedMessages
                  .map((key, value) => MapEntry(value.content.id, value)),
            );
            selectedMessages.addAll(initialSelecetdMessages);
          }
          if (initialList.length != selectedMessages.length) {
            bloc.add(MessageSelectionChanged(selectedMessages));
          }
        }
      }
    }
  }

  _detectStart(PointerEvent event) {
    addedMessages.clear();
    initialSelecetdMessages =
        context.read<MessagesBloc>().state.selectedMessages;
    final RenderBox box =
        _key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
    offset = box.globalToLocal(event.position);
    final result = BoxHitTestResult();
    if (box.hitTest(result, position: offset)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is SelectedMessage) {
          isRemove =
              initialSelecetdMessages.containsKey(target.message.content.id);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: _key,
      onPointerMove: _detectTapedItem,
      onPointerDown: _detectStart,
      onPointerUp: (event) {
        context.read<MessagesBloc>().add(MessagesSelectionModeChanged(false));
      },
      child: widget.child,
    );
  }
}

class SelectableMessage extends SingleChildRenderObjectWidget {
  final int index;
  final Message message;

  const SelectableMessage({
    required Widget super.child,
    required this.index,
    required this.message,
    super.key,
  });

  @override
  SelectedMessage createRenderObject(BuildContext context) {
    return SelectedMessage(index, message);
  }

  @override
  void updateRenderObject(BuildContext context, SelectedMessage renderObject) {
    renderObject.index = index;
  }
}

class SelectedMessage extends RenderProxyBox {
  int index;
  Message message;

  SelectedMessage(this.index, this.message);
}
