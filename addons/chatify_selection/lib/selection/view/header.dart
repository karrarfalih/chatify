import 'package:chatify/chatify.dart';
import 'package:chatify_selection/selection/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SelectedMessagesHeader extends StatelessWidget {
  const SelectedMessagesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    return BlocSelector<SelectionBloc, SelectionState, Map<String, Message>>(
      selector: (state) => state.selectedMessages,
      builder: (context, selecetdMessages) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: selecetdMessages.isEmpty
              ? const SizedBox.shrink(key: ValueKey('no-selected-messages'))
              : Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    key: const ValueKey('selected-messages-header'),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        onTap: () {
                          context.read<SelectionBloc>().add(
                            SelectionDeselectAll(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(
                            start: 16,
                            end: 16,
                            top: 12,
                            bottom: 12,
                          ),
                          child: Icon(Icons.close, color: color),
                        ),
                      ),
                      AnimatedFlipCounter(
                        value: selecetdMessages.length,
                        duration: const Duration(milliseconds: 200),
                        textStyle: TextStyle(fontSize: 16, color: color),
                      ),
                      Text(
                        ' ${'Selected'.tr}',
                        style: TextStyle(fontSize: 16, color: color),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          context.read<SelectionBloc>().add(SelectionDelete());
                        },
                        icon: Icon(Iconsax.trash, color: color),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
